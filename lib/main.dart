import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:personalimprover/helpers/Authentication.dart';
import 'package:personalimprover/helpers/MyColorScheme.dart';
import 'package:personalimprover/screens/HomePage.dart';
import 'package:personalimprover/screens/Login.dart';
import 'package:personalimprover/screens/Root.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
	
	@override
	Widget build(BuildContext context) {
		return DynamicTheme(
			defaultBrightness: Brightness.dark,
			data: (brightness) => MyColorScheme.darkThemeData,
			themedWidgetBuilder: (context, theme) {
				return MaterialApp(
					localizationsDelegates: [
						GlobalMaterialLocalizations.delegate,
						GlobalWidgetsLocalizations.delegate,
						GlobalCupertinoLocalizations.delegate,
					],
					supportedLocales: [
						const Locale('en', "US"),
						const Locale('fr', "FR"),
					],
					title: 'Personal Improver',
					debugShowCheckedModeBanner: false,
					theme: theme,
					home: I18n(child: Root(auth: Auth())),
					onGenerateRoute: Router.generateRoute,
				);
			},
		);
	}
}

class Router {
	static Route<dynamic> generateRoute(RouteSettings settings) {
		switch (settings.name) {
			case '/root':
				return MaterialPageRoute(builder: (_) => Root(auth: Auth()));
			case '/home':
				var data = settings.arguments as BaseAuth;
				return MaterialPageRoute(builder: (_) => HomePage(auth: data));
			case '/login':
				return MaterialPageRoute(builder: (_) => Login(auth: Auth()));
			default:
				return MaterialPageRoute(builder: (_) => Scaffold(body: Center(child: Text('No route defined for ${settings.name}'))));
		}
	}
}