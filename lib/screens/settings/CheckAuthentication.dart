import 'package:flutter/material.dart';
import 'package:personalimprover/helpers/Authentication.dart';
import 'package:personalimprover/helpers/Fingerprint.dart';
import 'package:personalimprover/helpers/MyColorScheme.dart';
import 'package:personalimprover/screens/Login.dart';
import 'package:personalimprover/screens/shared/clipping.dart';
import 'package:personalimprover/translations/Settings.i18n.dart';

class CheckAuthentication extends StatefulWidget {
	CheckAuthentication({Key key, this.auth}) : super(key: key);
	final BaseAuth auth;
	
	@override
	_CheckAuthenticationState createState() => _CheckAuthenticationState();
}

class _CheckAuthenticationState extends State<CheckAuthentication> {
	
	@override
	void initState() {
		checkFingerPrint();
		super.initState();
	}
	
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				children: <Widget>[
					Stack(
						children: <Widget>[
							Clipping(),
							Positioned.fill(
								child: Align(
									alignment: Alignment.bottomCenter,
									child: Container(
										height: 90.0,
										width: 90.0,
										decoration: BoxDecoration(
											shape: BoxShape.circle,
											image: DecorationImage(image: NetworkImage(connectedUser.picture)),
											border: Border.all(
												color: MyColorScheme.selectColor(context, 'secondaryHeaderColor'),
												width: 3.0,
											),
										),
									),
								),
							)
						],
					),
					Center(
						child: Padding(
							padding: EdgeInsets.all(20),
							child: Text('Fingerprint protection'.i18n, style: TextStyle(fontSize: 20),),
						)),
					Center(
						child: Padding(
							padding: EdgeInsets.all(30),
							child: Column(
								children: <Widget>[
									IconButton(
										icon: Icon(Icons.fingerprint),
										iconSize: 40,
										onPressed: checkFingerPrint,
									),
									Text('Press to retry'.i18n)
								],
							),
						),
					),
					Center(
						child: Padding(
							padding: EdgeInsets.fromLTRB(30, 150, 30, 30),
							child: Column(
								children: <Widget>[
									IconButton(
										icon: Icon(Icons.power_settings_new),
										iconSize: 40,
										onPressed: signOut,
									),
									Text('Press to disconnect'.i18n)
								],
							),
						),
					)
				],
			),
		);
	}
	
	Future<bool> checkFingerPrint() async {
		if (await FingerPrint().isAuthenticated()) {
			await Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false, arguments: widget.auth);
			return true;
		}
		return false;
	}
	
	Future<void> signOut() async {
		try {
			await widget.auth.signOut();
			await Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
		} catch (e) {
			print(e);
		}
	}
}
