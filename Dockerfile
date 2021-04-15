FROM maven:3.6-jdk-12-slim as BUILD
COPY . /src
WORKDIR /src
RUN mvn install -DskipTests

FROM openjdk:12.0.1-jre-slim-stretch
EXPOSE 8080
WORKDIR /app
ARG JAR=spring-petclinic-2.4.2.jar.BUILD-SNAPSHOT.jar

COPY --from=BUILD /src/target/$JAR /app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
