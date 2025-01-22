# Stage 1: Build the Flutter web app
FROM cirrusci/flutter:latest AS builder

# Create app directory with correct permissions
WORKDIR /app
RUN chown -R cirrus:cirrus /app

# Switch to non-root user
USER cirrus

# Copy dependency files first
COPY --chown=cirrus:cirrus pubspec.* ./

# Install dependencies with specific cache directory permissions
RUN mkdir -p /home/cirrus/.pub-cache && \
    flutter pub get

# Copy the rest of the application code
COPY --chown=cirrus:cirrus . .

# Build the web app
RUN flutter build web

# Stage 2: Serve the app with Nginx
FROM nginx:alpine

# Copy the built web app from the previous stage
COPY --from=builder /app/build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]