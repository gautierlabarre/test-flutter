import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
	
	static var t = Translations("en_us") +
		{
			"en_us": "Login",
			"fr_fr": "Connexion",
		} +
		{
			"en_us": "Create account",
			"fr_fr": "Créer un compte",
		} +
		{
			"en_us": "Reset",
			"fr_fr": "Réinitialiser",
		} +
		{
			"en_us": "Password lost",
			"fr_fr": "Mot de passe perdu",
		} +
		{
			"en_us": "Password",
			"fr_fr": "Mot de passe",
		} +
		{
			"en_us": "Password can't be empty",
			"fr_fr": "Le mot de passe ne doit pas être vide",
		} +
		{
			"en_us": "Email",
			"fr_fr": "Adresse email",
		} +
		{
			"en_us": "Email can't be empty",
			"fr_fr": "Votre email ne doit pas être vide",
		} +
		{
			"en_us": "Verify your email",
			"fr_fr": "Vérifier votre adresse email",
		} +
		{
			"en_us": "A link to verify account has been sent to your email",
			"fr_fr": "Un lien vous a été envoyé pour vérifier votre compte",
		} +
		{
			"en_us": "A link to change your password has been sent to your email",
			"fr_fr": "Un lien vous a été envoyé pour modifier votre mot de passe",
		} +
		{
			"en_us": "OK",
			"fr_fr": "OK",
		} +
		{
			"en_us": "Email not verified yet. Check your email",
			"fr_fr": "Email non vérifié. Vérifier votre adresse mail",
		} +
		{
			"en_us": "The email address is badly formatted.",
			"fr_fr": "Email mal formaté.",
		} +
		{
			"en_us": "There is no user record corresponding to this identifier. The user may have been deleted.",
			"fr_fr": "Aucun utilisateur ne correspond à cet email. Il a peut-être été supprimé.",
		} +
		{
			"en_us": "The given password is invalid. [ Password should be at least 6 characters ]",
			"fr_fr": "Mot de passe invalide (minimum 6 caractères)",
		};
	
	String get i18n => localize(this, t);
	
	String fill(List<Object> params) => localizeFill(this, params);
	
	String plural(int value) => localizePlural(value, this, t);
	
	String version(Object modifier) => localizeVersion(modifier, this, t);
	
	Map<String, String> allVersions() => localizeAllVersions(this, t);
}