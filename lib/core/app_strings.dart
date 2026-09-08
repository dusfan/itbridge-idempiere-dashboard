/// Every user-facing string in one place.
///
/// The product ships in French. Centralising the copy means adding a locale
/// later is mechanical (swap this class for generated l10n lookups) instead
/// of a hunt through widget trees.
class AppStrings {
  // Login
  static const loginTitle = 'Connexion';
  static const email = 'Email';
  static const emailHint = 'exemple@tourism.com';
  static const password = 'Mot de passe';
  static const passwordHint = 'Votre mot de passe';
  static const rememberMe = 'Se souvenir de moi';
  static const signIn = 'Se connecter';
  static const forgotPassword = 'Mot de passe oublié ?';
  static const advanced = 'Avancé';
  static const serverUrl = 'Serveur';
  static const serverUrlHint = 'https://host/api/v1';
  static const showPassword = 'Afficher le mot de passe';
  static const hidePassword = 'Masquer le mot de passe';

  // Validation
  static const emailRequired = 'L\'email est requis.';
  static const emailInvalid = 'Format d\'email invalide.';
  static const passwordRequired = 'Le mot de passe est requis.';
  static const serverRequired = 'L\'URL du serveur est requise.';
  static const serverInvalid = 'URL invalide (http:// ou https:// attendu).';

  // Feedback
  static const invalidCredentials = 'Email ou mot de passe incorrect.';
  static const networkError =
      'Serveur injoignable. Vérifiez votre connexion et l\'URL du serveur.';
  static const forgotPasswordHelp =
      'Contactez votre administrateur pour réinitialiser votre mot de passe.';
}
