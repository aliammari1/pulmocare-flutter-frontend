# Use Flutter image as build environment
FROM ghcr.io/cirruslabs/flutter:3.16.3 AS builder

# Set working directory
WORKDIR /app

# Copy files
COPY . .

# Get dependencies
RUN flutter pub get

# Build APK
RUN flutter build apk --release

# Final stage for minimal image
FROM alpine:latest

# Set working directory
WORKDIR /app

# Copy the APK from builder
COPY --from=builder /app/build/app/outputs/flutter-apk/app-release.apk ./medapp.apk

# Add APK to volume mount point
VOLUME ["/app/output"]

# Command to copy APK to output volume
CMD ["cp", "medapp.apk", "/app/output/"]