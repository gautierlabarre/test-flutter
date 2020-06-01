import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personalimprover/helpers/Authentication.dart';
import 'package:personalimprover/helpers/MyColorScheme.dart';
import 'package:personalimprover/helpers/utils.dart';
import 'package:personalimprover/models/User.dart';
import 'package:personalimprover/screens/shared/clipping.dart';
import 'package:personalimprover/translations/Login.i18n.dart';

User connectedUser = User();

class Login extends StatefulWidget {
	Login({Key key, this.auth}) : super(key: key);
	
	final Auth auth;
	
	@override
	_Login createState() => _Login();
}

class _Login extends State<Login> {
	final _formKey = GlobalKey<FormState>();
	final _emailController = TextEditingController();
	String _email;
	String _password;
	String _errorMessage;
	
	bool _isLoginForm;
	bool _isLoading;
	bool _resetPassword = false;
	bool _cancelLogin = false;
	
	@override
	void initState() {
		super.initState();
		
		_errorMessage = "";
		_isLoading = false;
		_isLoginForm = true;
	}
	
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: SingleChildScrollView(
				child: Column(
					children: <Widget>[
						Stack(children: <Widget>[isKeyboardUp(context) ? Container() : Clipping(color: Colors.blueAccent)]),
						Container(
							child: Center(
								child: Column(
									mainAxisSize: MainAxisSize.max,
									mainAxisAlignment: MainAxisAlignment.center,
									children: <Widget>[
										Transform.translate(
											offset: Offset(0, isKeyboardUp(context) ? 50 : 0),
											child: Image(
												image: AssetImage('assets/personalImprover.png'),
												height: (isKeyboardUp(context)) ? 100 : 150)
										),
										Padding(
											padding: EdgeInsets.only(top: isKeyboardUp(context) ? 50 : 10),
											child: Text('Personal Improver', style: TextStyle(
												fontWeight: FontWeight.w400,
												fontSize: 18,
												color: Colors.blueAccent
											),),
										),
										_isLoading ? Padding(
											padding: EdgeInsets.only(top: 50),
											child: Column(
												children: <Widget>[
													CircularProgressIndicator(),
													Padding(
														padding: EdgeInsets.only(top: 20),
														child: IconButton(
															icon: Icon(Icons.refresh),
															onPressed: () {
																setState(() => _cancelLogin = true);
																Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
															},
														),
													)
												],
											)
										) : showForm(),
									],
								),
							),
						),
					],
				),
			),
		);
	}
	
	Widget showForm() {
		return Container(
			padding: EdgeInsets.fromLTRB(40, 0, 40, 16),
			child: Form(
				key: _formKey,
				child: ListView(
					physics: NeverScrollableScrollPhysics(),
					shrinkWrap: true,
					children: <Widget>[
						showErrorMessage(),
						showEmailInput(),
						showPasswordInput(),
						_resetPassword ? showResetButton() : showPrimaryButton(),
						Row(
							mainAxisAlignment: MainAxisAlignment.spaceBetween,
							children: <Widget>[
								showSecondaryButton(),
								signInWithGoogle(),
							],
						)
					],
				),
			));
	}
	
	Widget showErrorMessage() {
		if (_errorMessage.isNotEmpty && _errorMessage != null) {
			return Text(
				_errorMessage.i18n,
				style: TextStyle(
					fontSize: 13.0,
					color: Colors.red,
					height: 1.0,
					fontWeight: FontWeight.w300),
			);
		}
		return Container();
	}
	
	Widget showEmailInput() {
		return Padding(
			padding: EdgeInsets.all(0),
			child: TextFormField(
				textInputAction: TextInputAction.next,
				onFieldSubmitted: (string) => _resetPassword ? validateReset() : FocusScope.of(context).nextFocus(),
				controller: _emailController,
				keyboardType: TextInputType.emailAddress,
				autofocus: false,
				decoration: InputDecoration(hintText: "Email".i18n, icon: Icon(Icons.mail, color: Colors.grey)),
				validator: (value) => value.isEmpty ? "Email can't be empty".i18n : null,
				onSaved: (value) => _email = value.trim(),
			),
		);
	}
	
	Widget showPasswordInput() {
		return _resetPassword ? Container() : Padding(
			padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
			child: TextFormField(
				textInputAction: TextInputAction.done,
				onFieldSubmitted: (string) => validateAndSubmit(),
				obscureText: true,
				autofocus: false,
				decoration: InputDecoration(hintText: 'Password'.i18n, icon: Icon(Icons.lock, color: Colors.grey)),
				validator: (value) => value.isEmpty ? "Password can't be empty".i18n : null,
				onSaved: (value) => _password = value.trim(),
			),
		);
	}
	
	Widget showSecondaryButton() {
		return Center(
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: <Widget>[
					FlatButton(
						child: Text(_isLoginForm ? 'Create account'.i18n : 'Login'.i18n, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
						onPressed: toggleFormMode
					),
					_resetPassword ? Container() : FlatButton(
						child: Text('Password lost'.i18n, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
						onPressed: resetPassword
					)
				],
			)
		);
	}
	
	Widget showPrimaryButton() {
		return Padding(
			padding: EdgeInsets.fromLTRB(50.0, 35.0, 50.0, 10.0),
			child: SizedBox(
				height: 40.0,
				child: RaisedButton(
					elevation: 10.0,
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
					color: _isLoginForm ? Colors.blueAccent : Colors.green,
					child: Text(_isLoginForm ? 'Login'.i18n : 'Create account'.i18n, style: TextStyle(fontSize: 20.0, color: Colors.white)),
					onPressed: validateAndSubmit,
				),
			));
	}
	
	Widget showResetButton() {
		return Padding(
			padding: EdgeInsets.fromLTRB(50.0, 35.0, 50.0, 60.0),
			child: SizedBox(
				height: 40.0,
				child: RaisedButton(
					elevation: 10.0,
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
					color: Colors.orange,
					child: Text('Reset'.i18n, style: TextStyle(fontSize: 20.0, color: Colors.white)),
					onPressed: validateReset,
				),
			));
	}
	
	Widget signInWithGoogle() {
		return OutlineButton(
			padding: EdgeInsets.all(5),
			splashColor: Colors.grey,
			onPressed: () async {
				setState(() {
					_errorMessage = "";
					_isLoading = true;
				});
				await widget.auth.googleSignIn().whenComplete(() async {
					if (!_cancelLogin) {
						setState(() => _isLoading = false);
						
						if (connectedUser?.uid == null) {
							return false;
						}
						
						MyColorScheme.checkTheme(context);
						await Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false, arguments: widget.auth);
						return true;
					} else {
						await widget.auth.signOut();
						return false;
					}
				});
			},
			shape: CircleBorder(),
			child: Padding(
				padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
				child: Image(image: AssetImage("assets/google_logo.png"), height: 35.0),
			),
		);
	}
	
	// Check if form is valid before perform login or signup
	bool validateAndSave() {
		final form = _formKey.currentState;
		if (form.validate()) {
			form.save();
			return true;
		}
		return false;
	}
	
	void validateReset() {
		if (validateAndSave()) {
			showResetModal();
			widget.auth.resetPassword(_email);
			setState(() {
				_isLoginForm = true;
				_resetPassword = false;
			});
		}
	}
	
	// Perform login or signup
	void validateAndSubmit() async {
		if (_emailController.text == '') return;
		
		if (validateAndSave()) {
			setState(() {
				_errorMessage = "";
				_isLoading = true;
			});
			String userId = "";
			try {
				if (_isLoginForm) {
					userId = await widget.auth.signIn(_email, _password);
					
					if (userId != null) {
						if (connectedUser.uid != null) {
							MyColorScheme.checkTheme(context);
						}
						await Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false, arguments: widget.auth);
					} else {
						_errorMessage = 'Email not verified yet. Check your email';
						setState(() => _isLoading = false);
					}
				} else {
					userId = await widget.auth.signUp(_email, _password);
					await widget.auth.sendEmailVerification();
					showVerifyEmailModal();
				}
				setState(() => _isLoading = false);
			} catch (e) {
				setState(() {
					_isLoading = false;
					_errorMessage = e.message;
				});
			}
		}
	}
	
	void resetForm() => _errorMessage = "";
	
	void toggleFormMode() {
		resetForm();
		setState(() {
			_isLoginForm = !_isLoginForm;
			_resetPassword = false;
		});
	}
	
	void resetPassword() {
		resetForm();
		setState(() => _resetPassword = !_resetPassword);
	}
	
	void showResetModal() {
		showDialog(context: context, builder: (BuildContext context) =>
			AlertDialog(
				title: Text("Verify your email".i18n),
				content: Text("A link to change your password has been sent to your email".i18n),
				actions: <Widget>[
					FlatButton(
						child: Text("OK".i18n),
						onPressed: () => Navigator.of(context).pop(),
					),
				],
			)
		);
	}
	
	void showVerifyEmailModal() {
		showDialog(context: context, builder: (BuildContext context) =>
			AlertDialog(
				title: Text("Verify your email".i18n),
				content: Text("A link to verify account has been sent to your email".i18n),
				actions: <Widget>[
					FlatButton(
						child: Text("OK".i18n),
						onPressed: () {
							toggleFormMode();
							Navigator.of(context).pop();
						},
					),
				],
			)
		);
	}
}
