import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
	
	static var t = Translations("en_us") +
		{
			"en_us": "No item",
			"fr_fr": "Aucun élément",
		} +
		{
			"en_us": "Audio recorder",
			"fr_fr": "Enregistreur",
		} +
		{
			"en_us": "Goals",
			"fr_fr": "Objectifs",
		} +
		{
			"en_us": "QR Code",
			"fr_fr": "QR Code",
		} +
		{
			"en_us": "Settings",
			"fr_fr": "Paramètres",
		};
	
	String get i18n => localize(this, t);
	
	String fill(List<Object> params) => localizeFill(this, params);
	
	String plural(int value) => localizePlural(value, this, t);
	
	String version(Object modifier) => localizeVersion(modifier, this, t);
	
	Map<String, String> allVersions() => localizeAllVersions(this, t);
}