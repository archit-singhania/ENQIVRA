class Environment {
  static const coreApiUrl = String.fromEnvironment('CORE_API_URL', defaultValue: 'http://localhost:8080/api/v1');
  static const intelligenceApiUrl = String.fromEnvironment('INTELLIGENCE_API_URL', defaultValue: 'http://localhost:8000/api/v1');
}
