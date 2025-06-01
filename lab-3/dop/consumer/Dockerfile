FROM openjdk:17-jdk-slim

WORKDIR /app

COPY target/*.jar consumer.jar

EXPOSE 8082

ENTRYPOINT ["java", "-jar", "consumer.jar"]
