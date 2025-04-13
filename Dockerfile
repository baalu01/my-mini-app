# Stage 1: Build React frontend
FROM node:18 AS frontend-builder

WORKDIR /app/frontend
COPY frontend/package.json frontend/yarn.lock ./
RUN yarn install

COPY frontend/ . 
RUN npm run build

# Stage 2: Build Java backend (JAR)
FROM gradle:8.4-jdk17 AS backend-builder

WORKDIR /app/backend
COPY backend/ . 
RUN gradle build --no-daemon

# Stage 3: Final runtime image
FROM openjdk:17-slim AS final-image

WORKDIR /app

# Copy built JAR from backend builder
COPY --from=backend-builder /app/backend/build/libs/*.jar app.jar

# Copy React build from frontend builder
COPY --from=frontend-builder /app/frontend/build ./static

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]

SKrr
