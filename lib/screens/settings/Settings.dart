import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personalimprover/helpers/Authentication.dart';
import 'package:personalimprover/helpers/Fingerprint.dart';
import 'package:personalimprover/helpers/InfoBar.dart';
import 'package:personalimprover/helpers/MyColorScheme.dart';
import 'package:personalimprover/helpers/ScaleRoute.dart';
import 'package:personalimprover/helpers/utils.dart';
import 'package:personalimprover/models/User.dart';
import 'package:personalimprover/screens/Login.dart';
import 'package:personalimprover/screens/settings/Profile.dart';
import 'package:personalimprover/translations/Settings.i18n.dart';

class Settings extends StatefulWidget {
	Settings({Key key, this.auth}) : super(key: key);
	final BaseAuth auth;
	
	@override
	_Settings createState() => _Settings();
}

class _Settings extends State<Settings> {
	final Firestore _db = Firestore.instance;
	
	@override
	void initState() {
		super.initState();
		// TODO Put that in a service with a callback for a .then()
		checkIfFingerPrintIsAvailable();
	}
	
	@override
	Widget build(BuildContext context) {
		return SingleChildScrollView(
			child: Column(
				mainAxisSize: MainAxisSize.max,
				children: <Widget>[
					Column(
						crossAxisAlignment: CrossAxisAlignment.stretch,
						children: <Widget>[userCard(), quotaCard()],
					),
					Padding(padding: EdgeInsets.only(bottom: 10)),
					ListView(
						physics: NeverScrollableScrollPhysics(),
						shrinkWrap: true,
						children: ListTile.divideTiles(
							context: context,
							tiles: [
								fingerPrintToggle(),
								networkWifiToggle(),
								cloudUploadToggle(),
								darkThemeToggle(),
								audioQualityToggle(),
								shortTextToggle(),
							]).toList(),
					)
				],
			)
		);
	}
	
	Widget userCard() {
		return Card(
			color: MyColorScheme.selectColor(context, 'secondaryHeaderColor'),
			child: Padding(
				padding: EdgeInsets.fromLTRB(10, 20, 0, 20),
				child: ListTile(
					onTap: () => Navigator.push(context, ScaleRoute(page: Profile(auth: widget.auth))),
					leading: userAvatar(),
					title: Text(connectedUser.name, style: TextStyle(fontSize: 18),),
					subtitle: Text(connectedUser.email),
					trailing: IconButton(icon: Icon(Icons.power_settings_new), onPressed: signOut),
				)
			)
		);
	}
	
	Widget quotaCard() {
		double quota;
		String quotaSizeText = '';
		if (connectedUser.isPro) {
			quota = connectedUser.audioSize / User.proQuota;
			quotaSizeText = '${sizeInMo(connectedUser.audioSize)} / ${sizeInMo(User.proQuota)} Mo';
		} else {
			quota = connectedUser.audioSize / User.freeQuota;
			quotaSizeText = '${sizeInMo(connectedUser.audioSize)} / ${sizeInMo(User.freeQuota)} Mo';
		}
		return Card(
			color: MyColorScheme.selectColor(context, 'secondaryHeaderColor'),
			child: Padding(
				padding: EdgeInsets.all(0),
				child: ListTile(
					leading: Icon(Icons.stars),
					title: Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: <Widget>[
							Text(connectedUser.isPro ? 'Pro user'.i18n : 'Free user'.i18n, style: TextStyle(fontWeight: FontWeight.w300),),
							Text(quotaSizeText, style: TextStyle(fontSize: 11.5),),
						],
					),
					subtitle: LinearProgressIndicator(value: quota),
				)
			)
		);
	}
	
	Widget fingerPrintToggle() {
		return ListTile(
			leading: Icon(Icons.fingerprint),
			title: Text("Secure the app".i18n),
			subtitle: Text("When app is closed, your fingerprint will unlock it".i18n),
			isThreeLine: true,
			trailing: Switch(
				value: connectedUser.fingerprint ?? false,
				activeColor: Colors.green,
				inactiveTrackColor: Colors.grey,
				onChanged: (bool value) async {
					if (await checkIfFingerPrintIsAvailable()) {
						setState(() {
							User.update(_db, {'fingerprint': value});
							connectedUser.fingerprint = value;
						});
					}
				},
			),
		);
	}
	
	Widget networkWifiToggle() {
		return ListTile(
			leading: Icon(Icons.network_wifi),
			title: Text("Wifi only".i18n),
			subtitle: Text("Send to the cloud only when wifi is on".i18n),
			trailing: Switch(
				value: connectedUser.wifiUpload ?? true,
				activeColor: Colors.green,
				inactiveTrackColor: Colors.grey,
				onChanged: (bool value) {
					setState(() {
						User.update(_db, {'wifiUpload': value});
						connectedUser.wifiUpload = value;
					});
				},
			),
		);
	}
	
	Widget cloudUploadToggle() {
		return ListTile(
			leading: Icon(Icons.cloud_upload),
			title: Text("Auto upload".i18n),
			subtitle: Text("Automatically send your recordings to the cloud".i18n),
			trailing: Switch(
				value: connectedUser.autoUpload ?? false,
				activeColor: Colors.green,
				inactiveTrackColor: Colors.grey,
				onChanged: (bool value) {
					setState(() {
						User.update(_db, {'autoUpload': value});
						connectedUser.autoUpload = value;
					});
				},
			),
		);
	}
	
	Widget darkThemeToggle() {
		return ListTile(
			leading: Icon(Icons.invert_colors),
			title: Text("Dark theme".i18n),
			subtitle: Text("Activate / Deactivate dark theme".i18n),
			trailing: Switch(
				value: connectedUser.darkTheme ?? false,
				activeColor: Colors.green,
				inactiveTrackColor: Colors.grey,
				onChanged: (bool isDarkTheme) {
					if (isDarkTheme) {
						MyColorScheme.setThemeToDarkTheme(context);
					} else {
						MyColorScheme.setThemeToLightTheme(context);
					}
					
					setState(() {
						User.update(_db, {'darkTheme': isDarkTheme});
						connectedUser.darkTheme = isDarkTheme;
					});
				},
			),
		);
	}
	
	Widget audioQualityToggle() {
		return ListTile(
			leading: Icon(Icons.audiotrack),
			title: Text("High audio quality".i18n),
			subtitle: Text("File will take more space storage".i18n),
			trailing: Switch(
				value: connectedUser.audioQuality ?? false,
				activeColor: Colors.green,
				inactiveTrackColor: Colors.grey,
				onChanged: (bool value) {
					setState(() {
						User.update(_db, {'audioQuality': value});
						connectedUser.audioQuality = value;
					});
				},
			),
		);
	}
	
	Widget shortTextToggle() {
		return ListTile(
			leading: Icon(Icons.short_text),
			title: Text("Condensed view".i18n),
			subtitle: Text("Reduce the informations on lines".i18n),
			trailing: Switch(
				value: connectedUser.condensedView ?? false,
				activeColor: Colors.green,
				inactiveTrackColor: Colors.grey,
				onChanged: (bool value) {
					setState(() {
						User.update(_db, {'condensedView': value});
						connectedUser.condensedView = value;
					});
				},
			),
		);
	}
	
	Widget userAvatar() {
		return CircleAvatar(
			backgroundImage: NetworkImage(connectedUser.picture),
			radius: 30,
			backgroundColor: Colors.transparent,
		);
	}
	
	Future<void> signOut() async {
		try {
			await widget.auth.signOut();
			await Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
		} catch (e) {
			print(e);
		}
	}
	
	Future<bool> checkIfFingerPrintIsAvailable() async {
		if (await FingerPrint().isBiometricAvailable() == false) {
			if (connectedUser.fingerprint == true) {
				InfoBar(context).info(message: "You don't have a fingerprint scanner".i18n);
			}
			
			setState(() => connectedUser.fingerprint = false);
			return false;
		}
		return true;
	}
}
