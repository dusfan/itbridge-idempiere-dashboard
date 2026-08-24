/// Compile-time configuration. Nothing here is user data.
class AppConfig {
  /// The iDempiere instance the app talks to. Overridden per build so a
  /// release can ship pointing at production without a visible field:
  ///
  ///   flutter build apk --dart-define=IDEMPIERE_BASE_URL=https://erp.example.com/api/v1
  static const defaultBaseUrl = String.fromEnvironment(
    'IDEMPIERE_BASE_URL',
    defaultValue: 'https://test.idempiere.org/api/v1',
  );

  /// Brand text is rendered as widgets and never baked into the background
  /// image. Renaming the product is a change here and nowhere else -- which
  /// is exactly why the old wordmark could not simply be edited out of a
  /// flattened PNG.
  static const brandName = 'Tourism';
  static const brandTagline = 'Executive Dashboard';

  /// Set false to show the logo mark alone, with no wordmark or tagline.
  static const showBrandText = true;

  /// Reveals the server-URL field inside the login card's "Avance" section.
  /// Turn off for a locked-down release where the URL is compiled in.
  static const allowServerOverride = true;

  /// iDempiere *session* language sent with oneStepLogin -- distinct from the
  /// app's UI copy, which is French regardless. Left at en_US because a locale
  /// must actually be installed on the server; switch to 'fr_FR' once the
  /// instance has the French language pack loaded.
  static const sessionLanguage = 'en_US';
}
