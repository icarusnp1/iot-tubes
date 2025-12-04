class ApiConfig {
  // Base URL for the API
  // For Android Emulator, use 10.0.2.2 instead of 127.0.0.1
  // For Physical Device, use your computer's local IP address (e.g., 192.168.1.100)
  // static const String baseUrl = 'http://10.0.2.2:5000';
  
  // Alternative URLs (uncomment the one you need)
  static const String baseUrl = 'http://192.168.99.253:5000'; // For physical device
  // static const String baseUrl = 'http://127.0.0.1:5000'; // For iOS Simulator
  
  // API Endpoints
  static const String dbCheckEndpoint = '/api/db/check';
  static const String dbRegisterEndpoint = '/api/auth/register';
  
  // Full URLs
  static String get dbCheckUrl => '$baseUrl$dbCheckEndpoint';
  static String get dbRegisterUrl => '$baseUrl$dbRegisterEndpoint';
  
  // Timeout duration
  static const Duration timeoutDuration = Duration(seconds: 10);
}