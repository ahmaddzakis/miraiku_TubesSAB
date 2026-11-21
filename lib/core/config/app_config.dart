/// Centralized environment configuration for MIRAIku.
///
/// Uses `--dart-define` compile-time variables when provided, with development
/// defaults so local builds on Windows and Android continue to work seamlessly.
class AppConfig {
  AppConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://zvtxkamtmkqsbgoijroc.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp2dHhrYW10bWtxc2Jnb2lqcm9jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkyNDQyNjYsImV4cCI6MjA5NDgyMDI2Nn0.7aABG8Tk0JBjxzmtZtaq8kwITHTtQ9dpx0CZVwCwlnY',
  );

  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '564994938710-anv76b8tkf8uoobjohct7fohm8f4ovhu.apps.googleusercontent.com',
  );
}
