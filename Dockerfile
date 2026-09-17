# ---- Stage 1: build frontend (Node 16 avoids the CRA4/webpack4 OpenSSL 3 issue on newer Node) ----
FROM node:16-alpine AS frontend-build
WORKDIR /frontend
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build


# ---- Stage 2: build backend, bundling the frontend build into Spring Boot's static resources ----
FROM eclipse-temurin:21-jdk AS backend-build
WORKDIR /app
COPY gradlew ./
COPY gradle ./gradle
COPY build.gradle settings.gradle ./
COPY src ./src
COPY --from=frontend-build /frontend/build ./src/main/resources/static
RUN chmod +x gradlew && ./gradlew bootJar --no-daemon


# ---- Stage 3: runtime ----
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=backend-build /app/build/libs/OnlineOrder-0.0.1-SNAPSHOT.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
