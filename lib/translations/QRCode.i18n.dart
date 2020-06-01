import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
	
	static var t = Translations("en_us") +
		// Generate.dart
		{
			"en_us": "QR Code generator",
			"fr_fr": "Générateur de QR Code",
		} +
		{
			"en_us": "Type QR Code content",
			"fr_fr": "Entrer le contenu du QRCode",
		} +
		{
			"en_us": "Generate",
			"fr_fr": "Générer",
		} +
		{
			"en_us": "Add a name",
			"fr_fr": "Ajouter un nom ?",
		} +
		{
			"en_us": "Name",
			"fr_fr": "Nom",
		} +
		{
			"en_us": "Validate",
			"fr_fr": "Valider",
		} +
		// ScanDetail.dart
		{
			"en_us": "Description",
			"fr_fr": "Description",
		} +
		{
			"en_us": "Name cannot be empty",
			"fr_fr": "Le nom ne peut pas être vide",
		} +
		{
			"en_us": "Update informations",
			"fr_fr": "Modifier les informations",
		} +
		{
			"en_us": "Share",
			"fr_fr": "Partager",
		} +
		{
			"en_us": "Fullscreen",
			"fr_fr": "Plein écran",
		} +
		{
			"en_us": "Copy content",
			"fr_fr": "Copier contenu",
		} +
		{
			"en_us": "Update",
			"fr_fr": "Modifier",
		} +
		{
			"en_us": "Delete",
			"fr_fr": "Supprimer",
		} +
		{
			"en_us": "Creation date",
			"fr_fr": "Date de création",
		} +
		// ScanList.dart
		{
			"en_us": "My barcodes",
			"fr_fr": "Mes codes barres",
		} +
		{
			"en_us": "No data",
			"fr_fr": "Aucune donnée",
		} +
		{
			"en_us": "Created on : %s",
			"fr_fr": "Créé le : %s",
		} +
		// Scanner.dart
		{
			"en_us": "Scan result",
			"fr_fr": "Résultat du scan",
		} +
		{
			"en_us": "Content copied to the clipboard",
			"fr_fr": "Résultat copié dans le presse papier",
		} +
		{
			"en_us": "Give a name to the scanned text",
			"fr_fr": "Saisissez un nom pour le texte scanné",
		} +
		{
			"en_us": "Cancel",
			"fr_fr": "Annuler",
		} +
		{
			"en_us": "Flash on",
			"fr_fr": "Activer le flash",
		} +
		{
			"en_us": "Flash off",
			"fr_fr": "Désactiver le flash",
		} +
		{
			"en_us": "You did not grant the camera permission!",
			"fr_fr": "Vous n'avez pas autorisé l'utilisation de la caméra !",
		};
	
	
	String get i18n => localize(this, t);
	
	String fill(List<Object> params) => localizeFill(this, params);
	
	String plural(int value) => localizePlural(value, this, t);
	
	String version(Object modifier) => localizeVersion(modifier, this, t);
	
	Map<String, String> allVersions() => localizeAllVersions(this, t);
}