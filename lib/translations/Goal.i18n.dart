import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
	
	static var t = Translations("en_us") +
		//GoalDetail.dart
		{
			"en_us": "Created on",
			"fr_fr": "Créé le",
		} +
		{
			"en_us": "Deadline date",
			"fr_fr": "Date limite",
		} +
		{
			"en_us": "none",
			"fr_fr": "aucune",
		} +
		{
			"en_us": "Tags",
			"fr_fr": "Libellés",
		} +
		{
			"en_us": "Description",
			"fr_fr": "Description",
		} +
		{
			"en_us": "Update goal",
			"fr_fr": "Modifier l'objectif",
		} +
		{
			"en_us": "Validate",
			"fr_fr": "Valider",
		} +
		{
			"en_us": "Name",
			"fr_fr": "Nom",
		} +
		{
			"en_us": "The name can't be empty",
			"fr_fr": "Le nom ne peut pas être vide",
		}  +
		{
			"en_us": "Select or add a new tag",
			"fr_fr": "Choisir ou créer un tag",
		}   +
		{
			"en_us": "No result",
			"fr_fr": "Aucun résultat",
		} +
		// GoalList.dart
		{
			"en_us": "My goals",
			"fr_fr": "Mes objectifs",
		} +
		{
			"en_us": "Filter :",
			"fr_fr": "Filtre :",
		} +
		{
			"en_us": "No data",
			"fr_fr": "Aucune donnée",
		} +
		{
			"en_us": "Created on : %s",
			"fr_fr": "Créé le : %s",
		} +
		{
			"en_us": "Add objective",
			"fr_fr": "Ajouter un objectif",
		} +
		{
			"en_us": "Cancel",
			"fr_fr": "Annuler",
		} +
		{
			"en_us": "Save",
			"fr_fr": "Sauvegarder",
		};
	
	
	String get i18n => localize(this, t);
	
	String fill(List<Object> params) => localizeFill(this, params);
	
	String plural(int value) => localizePlural(value, this, t);
	
	String version(Object modifier) => localizeVersion(modifier, this, t);
	
	Map<String, String> allVersions() => localizeAllVersions(this, t);
}