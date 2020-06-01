import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
	
	static var t = Translations("en_us") +
		// -- Settings.dart
		{
			"en_us": "Pro user",
			"fr_fr": "Utilisateur Pro",
		} +
		{
			"en_us": "Free user",
			"fr_fr": "Utilisateur gratuit",
		} +
		{
			"en_us": "Secure the app",
			"fr_fr": "Sécuriser l'application",
		} +
		{
			"en_us": "When app is closed, your fingerprint will unlock it",
			"fr_fr": "Lorsque l'application est fermée, votre empreinte sera redemandée",
		} +
		{
			"en_us": "Wifi only",
			"fr_fr": "Wifi uniquement",
		} +
		{
			"en_us": "Send to the cloud only when wifi is on",
			"fr_fr": "Envoi cloud : wifi uniquement",
		} +
		{
			"en_us": "Auto upload",
			"fr_fr": "Uploader automatiquement",
		} +
		{
			"en_us": "Automatically send your recordings to the cloud",
			"fr_fr": "Envoyer automatiquement vos enregistrements au cloud",
		} +
		{
			"en_us": "Dark theme",
			"fr_fr": "Thème sombre",
		} +
		{
			"en_us": "Activate / Deactivate dark theme",
			"fr_fr": "Activer / Désactiver le thème sombre",
		} +
		{
			"en_us": "High audio quality",
			"fr_fr": "Haute Qualité audio",
		} +
		{
			"en_us": "File will take more space storage",
			"fr_fr": "Fichier plus volumieux",
		} +
		{
			"en_us": "Condensed view",
			"fr_fr": "Vue condensé",
		} +
		{
			"en_us": "Reduce the informations on lines",
			"fr_fr": "Réduire les informations sur les lignes",
		} +
		{
			"en_us": "You don't have a fingerprint scanner",
			"fr_fr": "Vous n'avez pas de capteur d'empreinte",
		} +
		// -- CheckAuthentication.dart
		{
			"en_us": "Fingerprint protection",
			"fr_fr": "Protection par empreinte",
		} +
		{
			"en_us": "Press to retry",
			"fr_fr": "Appuyer pour réessayer",
		} +
		{
			"en_us": "Press to disconnect",
			"fr_fr": "Appuyer pour vous déconnecter",
		} +
		// -- Profile.dart
		{
			"en_us": "PRO",
			"fr_fr": "PRO",
		} +
		{
			"en_us": "FREE",
			"fr_fr": "Gratuit",
		} +
		{
			"en_us": "Email",
			"fr_fr": "Email",
		} +
		{
			"en_us": "Since",
			"fr_fr": "Depuis",
		} +
		{
			"en_us": "Modify",
			"fr_fr": "Modifier",
		} +
		{
			"en_us": "Delete account",
			"fr_fr": "Supprimer le compte",
		} +
		{
			"en_us": "Beware, this will delete your account as well as all data associated with it",
			"fr_fr": "Attention, votre compte sera supprimé, ainsi que toutes les données associées",
		} +
		{
			"en_us": "Name",
			"fr_fr": "Nom",
		} +
		{
			"en_us": "Cancel",
			"fr_fr": "Annuler",
		}  +
		{
			"en_us": "Save",
			"fr_fr": "Sauvegarder",
		} +
		{
			"en_us": "Your name can't be empty",
			"fr_fr": "Votre nom ne peut pas être vide",
		} +
		{
			"en_us": "Confirm",
			"fr_fr": "Confirmer",
		}+
		{
			"en_us": "Deleting data...",
			"fr_fr": "Suppression des données...",
		} +
		{
			"en_us": "If this operation is taking too long, logout and retry",
			"fr_fr": "Si cette opération dure trop longtemps, déconnectez-vous et réessayer.",
		};
	
	String get i18n => localize(this, t);
	
	String fill(List<Object> params) => localizeFill(this, params);
	
	String plural(int value) => localizePlural(value, this, t);
	
	String version(Object modifier) => localizeVersion(modifier, this, t);
	
	Map<String, String> allVersions() => localizeAllVersions(this, t);
}