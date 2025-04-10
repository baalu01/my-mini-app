# Stage 1: React Build
FROM node:18 AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package.json frontend/yarn.lock ./
RUN yarn install
COPY frontend/ . 
RUN yarn build

# Stage 2: Spring Boot Build
FROM gradle:8.4-jdk17 AS backend-builder
WORKDIR /app
COPY backend/ ./backend/
WORKDIR /app/backend
RUN gradle bootJar --no-daemon

# Stage 3: Final Image
FROM openjdk:17-slim
WORKDIR /app
COPY --from=backend-builder /app/backend/build/libs/*.jar app.jar
COPY --from=frontend-builder /app/frontend/build ./static
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
