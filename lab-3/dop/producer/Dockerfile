FROM openjdk:17-jdk-slim

WORKDIR /app

COPY target/*.jar producer.jar

EXPOSE 8081

ENTRYPOINT ["java", "-jar", "producer.jar"]
