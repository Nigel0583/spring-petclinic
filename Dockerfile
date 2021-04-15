FROM maven:3.6-jdk-11-slim as BUILD
COPY . /src
WORKDIR /src

FROM openjdk:11.0.1-jre-slim-stretch
EXPOSE 8090
WORKDIR /app
ARG JAR=spring-petclinic-2.4.2.jar.BUILD-SNAPSHOT.jar

COPY --from=BUILD /src/target/$JAR /app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
