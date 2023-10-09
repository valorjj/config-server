FROM eclipse-temurin:17-jdk
ARG JAR_FILE=build/libs/*.jar
COPY ${JAR_FILE} configserver.jar
ENTRYPOINT ["java", "-jar", "/configserver.jar"]
EXPOSE 9296