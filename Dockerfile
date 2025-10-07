# Stage 1: Build
FROM maven:3.9.5-eclipse-temurin-17 AS build

WORKDIR /app

# Copy pom.xml từ thư mục websocket
COPY websocket/pom.xml .
COPY websocket/.mvn .mvn
COPY websocket/mvnw .
COPY websocket/mvnw.cmd .

# Download dependencies
RUN mvn dependency:go-offline -B

# Copy source code từ websocket/src
COPY websocket/src ./src

# Build application
RUN mvn clean package -DskipTests

# Stage 2: Run
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

# Copy JAR file từ build stage
COPY --from=build /app/target/*.jar app.jar

# Expose port
EXPOSE 8080

# Environment variable cho port
ENV PORT=8080

# Run application
ENTRYPOINT ["sh", "-c", "java -Dserver.port=${PORT} -Xmx512m -Xms256m -jar app.jar"]