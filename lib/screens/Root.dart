import 'package:flutter/material.dart';
import 'package:personalimprover/helpers/FirebaseNotifications.dart';
import 'package:personalimprover/helpers/MyColorScheme.dart';
import 'package:personalimprover/screens/HomePage.dart';

import '../helpers/Authentication.dart';
import 'package:personalimprover/screens/Login.dart';
import 'settings/CheckAuthentication.dart';

enum AuthStatus { notDetermined, notLoggedIn, loggedIn }

class Root extends StatefulWidget {
	Root({this.auth});
	
	final Auth auth;
	
	@override
	State<StatefulWidget> createState() => _RootState();
}

class _RootState extends State<Root> {
	AuthStatus authStatus = AuthStatus.notDetermined;
	String _userId = "";
	
	@override
	void initState() {
		super.initState();
		FirebaseNotifications().setUpFirebase();
		
		widget.auth.getCurrentUser().then((user) async {
			if (null != user) {
				await widget.auth.generateUser(user);
				MyColorScheme.checkTheme(context);
			} else {
				MyColorScheme.setThemeToLightTheme(context);
			}
			
			setState(() {
				if (null != user) _userId = user?.uid;
				authStatus = user?.uid == null ? AuthStatus.notLoggedIn : AuthStatus.loggedIn;
			});
		});
	}
	
	@override
	Widget build(BuildContext context) {
		switch (authStatus) {
			case AuthStatus.notDetermined:
				return buildWaitingScreen();
				break;
			case AuthStatus.notLoggedIn:
				return Login(auth: widget.auth);
				break;
			case AuthStatus.loggedIn:
				if (_userId.isNotEmpty && _userId != null) {
					if (connectedUser.fingerprint == true) {
						return CheckAuthentication(auth: widget.auth);
					}
					
					return HomePage(auth: widget.auth);
				} else {
					return buildWaitingScreen();
				}
				break;
			default:
				return buildWaitingScreen();
		}
	}
	
	Widget buildWaitingScreen() => Scaffold(body: Container(alignment: Alignment.center, child: CircularProgressIndicator()));
}