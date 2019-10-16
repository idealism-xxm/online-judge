# Step 1. build judger's .so file
FROM gcc:9 AS build-judger-cpp

WORKDIR /online-judge/online-judge-judger

COPY online-judge-judger .
COPY --from=openjdk:8 \
    /usr/local/openjdk-8/include/jni.h \
    /usr/local/openjdk-8/include/linux/jni_md.h \
    /usr/local/include/c++/9.2.0/

RUN make compiler \
    && make executor


# Step 2. build wars of judger and web
FROM maven:3-jdk-8 AS build-project

WORKDIR /online-judge

COPY . .
COPY --from=build-judger-cpp \
    /online-judge/online-judge-judger/target/classes/ \
    online-judge-judger/target/classes/

RUN mvn package -pl online-judge-judger,online-judge-web -am -Dmaven.test.skip=true


# Step 3. build production environment
FROM tomcat:9-jdk8 as build-prod

COPY --from=build-project \
    /online-judge/online-judge-judger/target/online-judge-judger.war \
    /online-judge/online-judge-web/target/online-judge-web.war \
    webapps/