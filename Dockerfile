FROM maven:3.9.5-eclipse-temurin-17 AS build

WORKDIR /app

# Copy từ thư mục websocket
COPY pom.xml ./
COPY websocket/.mvn ./.mvn
COPY websocket/mvnw ./
COPY websocket/mvnw.cmd ./

# Cấp quyền thực thi cho mvnw
RUN chmod +x ./mvnw

# Download dependencies
RUN ./mvnw dependency:go-offline -B

# Copy source code từ websocket/src
COPY websocket/src ./src

# Build application
RUN ./mvnw clean package -DskipTests

# Stage 2: Run
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app

# Copy JAR file từ build stage
COPY --from=build /app/target/*.jar app.jar

# Expose port
EXPOSE 8080

# Environment variable
ENV PORT=8080

# Run application
ENTRYPOINT ["sh", "-c", "java -Dserver.port=${PORT} -Xmx512m -Xms256m -jar app.jar"]