import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
	
	static var t = Translations("en_us") +
		// AudioRecorder.dart
		{
			"en_us": "Loading...",
			"fr_fr": "Chargement ...",
		} +
		{
			"en_us": "Recording in progress...",
			"fr_fr": "Enregistrement en cours ...",
		} +
		{
			"en_us": "Enter the recording name",
			"fr_fr": "Indiquer le nom de l'enregistrement",
		} +
		{
			"en_us": "Save in the cloud",
			"fr_fr": "Sauvegarder dans le cloud",
		} +
		{
			"en_us": "Enable/Disable cloud backup",
			"fr_fr": "Activer / Désactiver la sauvegarde",
		} +
		{
			"en_us": "Wifi disabled, the recording will not be saved in the cloud",
			"fr_fr": "Le WIFI est désactivé, la sauvegarde au cloud est donc désactivée.",
		} +
		{
			"en_us": "You need to accept permissions",
			"fr_fr": "Il faut accepter les permissions",
		} +
		{
			"en_us": "Recording saved",
			"fr_fr": "Enregistrement sauvegardé",
		} +
		{
			"en_us": "Recording saved but not on the cloud, your cloud size is reached",
			"fr_fr": "Enregistrement sauvegardé, mais pas sur le cloud, votre quota est dépassé.",
		} +
		{
			"en_us": "You want to exit ? The recording will be lost",
			"fr_fr": "Voulez-vous quitter l'engistrement ? Il sera perdu.",
		} +
		{
			"en_us": "Unfinished",
			"fr_fr": "Non terminé",
		} +
		{
			"en_us": "No",
			"fr_fr": "Non",
		} +
		{
			"en_us": "Yes",
			"fr_fr": "Oui",
		} +
		{
			"en_us": "Saving...",
			"fr_fr": "Sauvegarde...",
		} +
		// RecordingDetail.dart
		{
			"en_us": "Duration",
			"fr_fr": "Durée",
		} +
		{
			"en_us": "Size",
			"fr_fr": "Taille",
		} +
		{
			"en_us": "Creation date",
			"fr_fr": "Date de création",
		} +
		{
			"en_us": "Saved in the cloud",
			"fr_fr": "Sauvegardé dans le cloud",
		} +
		{
			"en_us": "Description",
			"fr_fr": "Description",
		} +
		{
			"en_us": "File recovered",
			"fr_fr": "Fichier récupéré",
		} +
		{
			"en_us": "You can now listen to it again",
			"fr_fr": "Vous pouvez désormais le réécouter",
		} +
		{
			"en_us": "Modify recording",
			"fr_fr": "Modifier l'enregistrement",
		} +
		{
			"en_us": "Validate",
			"fr_fr": "Valider",
		} +
		{
			"en_us": "The name cannot be empty",
			"fr_fr": "Le nom ne peut pas être vide",
		} +
		{
			"en_us": "Share",
			"fr_fr": "Partager",
		} +
		{
			"en_us": "Delete",
			"fr_fr": "Supprimer",
		} +
		{
			"en_us": "Remove from cloud",
			"fr_fr": "Retirer du cloud",
		} +
		{
			"en_us": "Add to the cloud",
			"fr_fr": "Ajouter au cloud",
		} +
		{
			"en_us": "File not found",
			"fr_fr": "Fichier introuvable",
		} +
		{
			"en_us": "Download",
			"fr_fr": "Télécharger",
		} +
		{
			"en_us": "This file is on the cloud, so you can re-download it.",
			"fr_fr": "Ce fichier est sur le cloud, vous pouvez donc le retélécharger",
		} +
		{
			"en_us": "This file is not in the cloud. It's lost.",
			"fr_fr": "Ce fichier n'est pas dans le cloud. Il est perdu.",
		} +
		{
			"en_us": "Recording %s, duration : %s",
			"fr_fr": "Enregistrement %s, durée %s",
		} +
		{
			"en_us": "Your quota is exceeded",
			"fr_fr": "Votre quota est dépassé",
		} +
		{
			"en_us": "Your quota is exceeded, upgrade your account to save on the cloud",
			"fr_fr": "Votre quota est passé, passez pro",
		} +
		{
			"en_us": "Go pro",
			"fr_fr": "Passez pro",
		} +
		// RecordingList.dart
		{
			"en_us": "My recordings",
			"fr_fr": "Mes enregistrements",
		} +
		{
			"en_us": "No record",
			"fr_fr": "Aucun enregistrement",
		} +
		{
			"en_us": "Duration %s s",
			"fr_fr": "Durée %s s",
		} +
		{
			"en_us": "Size %s Ko",
			"fr_fr": "Taille %s Ko",
		};
	
	String get i18n => localize(this, t);
	
	String fill(List<Object> params) => localizeFill(this, params);
	
	String plural(int value) => localizePlural(value, this, t);
	
	String version(Object modifier) => localizeVersion(modifier, this, t);
	
	Map<String, String> allVersions() => localizeAllVersions(this, t);
}