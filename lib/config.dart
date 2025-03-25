class Config {
  // Updated to use Kong API Gateway
  static const String apiBaseUrl = 'http://10.0.2.2:8000/api';

  // For Flutter web or emulator use
  static const String localApiBaseUrl = 'http://localhost:8000/api';

  // For production Docker environment
  static const String dockerApiBaseUrl = 'http://kong:8000/api';

  // Helper method to determine which URL to use based on environment
  static String getApiBaseUrl() {
    // This is a simple implementation. In a production app, you would want
    // to determine this based on build flags or environment variables
    const bool isProduction = bool.fromEnvironment('dart.vm.product');

    if (isProduction) {
      return apiBaseUrl;
    } else {
      // For development in docker, use the docker URL
      // This would typically be set by an environment variable
      const useDocker = bool.fromEnvironment('USE_DOCKER', defaultValue: false);
      return useDocker ? dockerApiBaseUrl : localApiBaseUrl;
    }
  }
}
