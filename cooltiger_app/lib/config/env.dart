/// Central place for compile-time configuration.
class Env {
  /// Backend base URL (without trailing slash). Provide at build time using
  /// `--dart-define=COOLTIGER_API_BASE=https://example.com/api/v1`.
  static const apiBaseUrl = String.fromEnvironment(
    'COOLTIGER_API_BASE',
    defaultValue: 'http://localhost:8080/api/v1',
  );
}
