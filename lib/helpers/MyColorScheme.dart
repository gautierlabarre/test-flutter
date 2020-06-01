import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:personalimprover/screens/Login.dart';

class MyColorScheme {
	static final ThemeData whiteThemeData = ThemeData(
		fontFamily: 'SF Pro Display',
		brightness: Brightness.light,
		primarySwatch: Colors.green,
		primaryColor: Colors.blue,
		accentColor: Colors.orange,
		secondaryHeaderColor: Colors.white70,
		cardColor: Colors.white60,
		backgroundColor: Colors.white,
		buttonColor: Colors.white,
		cursorColor: Colors.black,
		toggleableActiveColor: Colors.blue
	);
	static final ThemeData darkThemeData = ThemeData(
		brightness: Brightness.dark,
		fontFamily: 'SF Pro Display',
		cursorColor: Colors.white,
		primaryColor: Colors.deepOrange,
		accentColor: Colors.amber,
		buttonColor: Colors.amber,
		cardColor: Colors.black12,
		secondaryHeaderColor: Colors.black87,
		backgroundColor: Colors.black26,
		primarySwatch: Colors.deepOrange,
		toggleableActiveColor: Colors.white12
	);
	
	static checkTheme(context) {
		if (connectedUser.darkTheme == false) {
			DynamicTheme.of(context).setBrightness(Theme
				.of(context)
				.brightness == Brightness.dark ? Brightness.light : Brightness.dark);
			DynamicTheme.of(context).setThemeData(whiteThemeData);
		} else {
			DynamicTheme.of(context).setBrightness(Theme
				.of(context)
				.brightness == Brightness.dark ? Brightness.light : Brightness.dark);
			DynamicTheme.of(context).setThemeData(darkThemeData);
		}
	}
	
	static setThemeToDarkTheme(context) {
		DynamicTheme.of(context).setBrightness(Theme
			.of(context)
			.brightness == Brightness.dark ? Brightness.light : Brightness.dark);
		DynamicTheme.of(context).setThemeData(darkThemeData);
	}
	
	static setThemeToLightTheme(context) {
		DynamicTheme.of(context).setBrightness(Theme
			.of(context)
			.brightness == Brightness.dark ? Brightness.light : Brightness.dark);
		DynamicTheme.of(context).setThemeData(whiteThemeData);
	}
	
	static selectColor(context, color) {
		switch (color) {
			case 'toggleableActiveColor':
				return Theme
					.of(context)
					.toggleableActiveColor;
			case 'cursorColor':
				return Theme
					.of(context)
					.cursorColor;
			case 'secondaryHeaderColor':
				return Theme
					.of(context)
					.secondaryHeaderColor;
			case 'buttonColor':
				return Theme
					.of(context)
					.buttonColor;
			case 'backgroundColor':
				return Theme
					.of(context)
					.backgroundColor;
			case 'primaryColor':
				return Theme
					.of(context)
					.primaryColor;
			case 'cardColor':
				return Theme
					.of(context)
					.cardColor;
			default:
				return Theme
					.of(context)
					.primaryColor;
		}
	}
}