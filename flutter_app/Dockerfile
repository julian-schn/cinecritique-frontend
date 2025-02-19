# Flutter Build
FROM ghcr.io/cirruslabs/flutter:3.27.3 AS build
WORKDIR /app
COPY . /app
RUN flutter pub get
RUN flutter build web

# Nginx Build / Kopiere Flutter in Nginx
FROM nginx:latest
COPY --from=build /app/build/web /usr/share/nginx/html
# Kopiere externe config in Containter
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 62342
CMD ["nginx", "-g", "daemon off;"]