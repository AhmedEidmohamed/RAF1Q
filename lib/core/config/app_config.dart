/// Application Configuration
/// Handles API keys using Environment variables via `--dart-define`
class AppConfig {
  /// Groq API Key
  static const String groqApiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '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',
  );

  /// Secondary Groq API Key (Used in voice chat and general chat services)
  static const String groqChatApiKey = String.fromEnvironment(
    'GROQ_CHAT_API_KEY',
    defaultValue: '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',
  );

  /// ElevenLabs API Key
  static const String elevenLabsApiKey = String.fromEnvironment(
    'ELEVEN_LABS_API_KEY',
    defaultValue: 'sk_3aaa6d7ef1d79cae6aba84a6fcf0fa9f53ac64dd81fac576',
  );

  /// Gemini API Key
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AIzaSy...', // Replace with your real Gemini API key default if needed
  );
}
