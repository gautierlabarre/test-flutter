import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personalimprover/helpers/Authentication.dart';
import 'package:personalimprover/helpers/Clipping.dart';
import 'package:personalimprover/helpers/MyColorScheme.dart';
import 'package:personalimprover/screens/Login.dart';
import 'package:personalimprover/translations/Settings.i18n.dart';

class Profile extends StatefulWidget {
	Profile({Key key, this.auth}) : super(key: key);
	final BaseAuth auth;
	
	@override
	_ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
	String userName = connectedUser.name;
	final _formKey = GlobalKey<FormState>();
	
	
	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			onPanUpdate: (detail) => (detail.delta.dx > 10) ? Navigator.maybePop(context) : null,
			child: Scaffold(
				body: ListView(
					children: <Widget>[
						Stack(
							children: <Widget>[
								Padding(
									padding: EdgeInsets.only(bottom: 30.0),
									child: ClipPath(
										clipper: ClippingClass2(),
										child: Container(height: 130.0, decoration: BoxDecoration(color: Colors.blueGrey)),
									),
								),
								Positioned(
									top: -10,
									left: -10,
									child: Padding(
										padding: EdgeInsets.all(25),
										child: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.maybePop(context)),
									),
								),
								Positioned.fill(
									top: -100,
									child: Align(
										alignment: Alignment.center,
										child: Padding(
											padding: EdgeInsets.all(25),
											child: Chip(
												avatar: CircleAvatar(
													backgroundColor: connectedUser.isPro ? Colors.green.shade800 : Colors.grey.shade800,
													child: connectedUser.isPro ? Icon(Icons.stars) : Icon(Icons.account_circle),
												),
												label: connectedUser.isPro ? Text('PRO'.i18n) : Text('FREE'.i18n),
											)
										),
									),
								),
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
								),
							],
						),
						Center(child: Text(connectedUser.name, style: TextStyle(fontSize: 20))),
						Column(
							children: <Widget>[
								Padding(
									padding: EdgeInsets.only(top: 40),
									child: Row(
										mainAxisAlignment: MainAxisAlignment.spaceBetween,
										mainAxisSize: MainAxisSize.max,
										children: <Widget>[
											Padding(child: Text('Email'.i18n), padding: EdgeInsets.only(left: 50)),
											Padding(child: Text(connectedUser.email), padding: EdgeInsets.only(right: 50))
										],
									),
								),
								Padding(
									padding: EdgeInsets.only(top: 15),
									child: Row(
										mainAxisAlignment: MainAxisAlignment.spaceBetween,
										mainAxisSize: MainAxisSize.max,
										children: <Widget>[
											Padding(child: Text('Since'.i18n), padding: EdgeInsets.only(left: 50)),
											Padding(child: Text('12/12/2020 14:20'), padding: EdgeInsets.only(right: 50))
										],
									),
								),
							]
						),
//						Card(
//							margin: EdgeInsets.fromLTRB(20, 40, 20, 20),
//							color: MyColorScheme.selectColor(context, 'secondaryHeaderColor'),
//							child: Padding(
//								padding: EdgeInsets.fromLTRB(10, 20, 0, 20),
//								child: Column(
//									children: <Widget>[
//										Row(
//											mainAxisAlignment: MainAxisAlignment.spaceAround,
//											children: <Widget>[
//												Column(
//													children: <Widget>[
//														Icon(Icons.voicemail, color: Colors.grey,),
//														Padding(
//															padding: EdgeInsets.only(top: 5),
//															child: Text('32', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300)),
//														),
//													],
//												),
//												Column(
//													children: <Widget>[
//														Icon(Icons.check_circle_outline, color: Colors.grey,),
//														Padding(
//															padding: EdgeInsets.only(top: 5),
//															child: Text('110', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300)),
//														),
//													],
//												),
//												Column(
//													children: <Widget>[
//														Icon(Icons.settings_overscan, color: Colors.grey,),
//														Padding(
//															padding: EdgeInsets.only(top: 5),
//															child: Text('0', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300)),
//														),
//													],
//												)
//											],
//										),
//									],
//								)
//							)
//						),
						Padding(padding: EdgeInsets.only(top: 50),),
						Row(
							mainAxisAlignment: MainAxisAlignment.spaceAround,
							children: <Widget>[
								Column(
									children: <Widget>[
										RawMaterialButton(
											child: Icon(Icons.edit),
											splashColor: Colors.orange,
											padding: EdgeInsets.all(10),
											shape: CircleBorder(),
											onPressed: () => updateUserInfo(context),
										),
										Text('Modify'.i18n),
									]
								),
								Column(
									children: <Widget>[
										RawMaterialButton(
											child: Icon(Icons.block),
											splashColor: Colors.orange,
											padding: EdgeInsets.all(10),
											shape: CircleBorder(),
											onPressed: () => confirmDeleteAccount(),
										),
										Text('Delete account'.i18n),
									]
								),
							],
						)
					],
				),
			),
		);
	}
	
	Future<void> confirmDeleteAccount() async {
		await showDialog <String>(context: context, builder: (BuildContext context) =>
			AlertDialog(
				content: Text('Beware, this will delete your account as well as all data associated with it'.i18n),
				actions: <Widget>[
					FlatButton(child: Text('Cancel'.i18n), onPressed: () => Navigator.pop(context)),
					FlatButton(child: Text('Confirm'.i18n), color: Colors.red, onPressed: () => deleteAccount())
				],
			)
		);
	}
	
	Future<void> deleteAccount() async {
		showLoadingModal();
		
		await widget.auth.deleteAccount();
		await Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
	}
	
	void showLoadingModal() {
		showDialog(context: context, builder: (context) =>
			AlertDialog(
				title: Text('Deleting data...'.i18n),
				content: Column(
					mainAxisSize: MainAxisSize.min,
					children: <Widget>[
						Center(child: CircularProgressIndicator()),
						Text('If this operation is taking too long, logout and retry'.i18n)
					])
			),
		);
	}
	
	void updateUserInfo(BuildContext context) async {
		await showDialog<String>(context: context, builder: (BuildContext context) =>
			AlertDialog(
				content: Row(
					children: <Widget>[
						Form(
							key: _formKey,
							child: Expanded(
								child: TextFormField(
									textInputAction: TextInputAction.done,
									controller: TextEditingController(text: userName),
									onFieldSubmitted: (string) => validateUpdate(),
									autofocus: true,
									maxLength: 30,
									decoration: InputDecoration(hintText: 'Name'.i18n,),
									validator: (value) => value.isEmpty ? "Your name can't be empty".i18n : null,
									onSaved: (value) => userName = value.trim(),
								),
							)
						)
					],
				),
				actions: <Widget>[
					FlatButton(child: Text('Cancel'.i18n), onPressed: () => Navigator.pop(context)),
					FlatButton(child: Text('Save'.i18n), onPressed: () {
						validateUpdate();
						setState(() => connectedUser.name = userName);
					})
				],
			)
		);
	}
	
	void validateUpdate() {
		if (validateAndSave()) {
			widget.auth.updateUser(userName);
			//TODO Update cloud database info
			Navigator.pop(context);
		}
	}
	
	bool validateAndSave() {
		final form = _formKey.currentState;
		if (form.validate()) {
			form.save();
			return true;
		}
		return false;
	}
}

