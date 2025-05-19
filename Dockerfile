# Stage 1: Build stage
FROM maven:3.8-openjdk-11-slim AS build

# Set working directory
WORKDIR /app

# Copy pom.xml first (for better caching)
COPY pom.xml .

# Download dependencies (this layer will be cached if pom.xml doesn't change)
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# Stage 2: Runtime stage
FROM openjdk:11-jre-slim

# Create non-root user for security
RUN addgroup --system spring && adduser --system spring --ingroup spring

# Set working directory
WORKDIR /app

# Copy the JAR from build stage
COPY --from=build /app/target/hello-version-0.0.1.jar app.jar

# Change ownership to spring user
RUN chown spring:spring app.jar

# Switch to non-root user
USER spring

# Expose port 8000
EXPOSE 8000

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]

