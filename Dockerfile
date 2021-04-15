FROM maven:3.6.0-jdk-12

ADD target/spring-petclinic-2.4.2.jar spring-petclinic-2.4.2.jar

ENTRYPOINT ["java", "-jar", "/spring-petclinic-2.4.2.jar"]
