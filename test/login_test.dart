import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:personalimprover/screens/Login.dart';

import 'Mocks.dart';
import 'variables.dart';

void main() {
	NavigatorObserver mockObserver;
	AuthMock mock = AuthMock(userFakeId: 'sdf54gsd54fghsdf54');
	AuthMock mockError = AuthMock(userFakeId: null);
	
	var appMock = MediaQuery(data: MediaQueryData(), child: MaterialApp(home: Login(auth: mock)));
	var appMockError = MediaQuery(data: MediaQueryData(), child: MaterialApp(home: Login(auth: mockError)));
	
	final Finder emailField = find.widgetWithText(TextFormField, 'Email');
	final Finder passwordField = find.widgetWithText(TextFormField, 'Password');
	final Finder loginButton = find.widgetWithText(RaisedButton, 'Login');
	final Finder resetButton = find.widgetWithText(RaisedButton, 'Reset');
	final Finder createAccountButton = find.widgetWithText(RaisedButton, 'Create account');
	
	setUp(() => mockObserver = MockNavigatorObserver());
	
	Future _buildMainPage(WidgetTester tester) async {
		//TODO Fix container with HomePage(auth: mock) when cloud_firestore issue is resolved with another mock
		await tester.pumpWidget(MaterialApp(home: Container(), navigatorObservers: [mockObserver]));
	}
	
	Future expectLoaderAndDelay(tester) async {
		expect(find.byType(CircularProgressIndicator), findsOneWidget);
		await Future.delayed(Duration.zero);
		await tester.pump();
	}
	
	testWidgets('Check screen Login widgets', (WidgetTester tester) async {
		await tester.pumpWidget(appMock);
		
		expect(find.byType(Image), findsNWidgets(2));
		expect(find.text('Personal Improver'), findsOneWidget);
		expect(find.byType(TextFormField), findsNWidgets(2));
		expect(find.widgetWithText(RaisedButton, 'Login'), findsOneWidget);
		expect(find.widgetWithText(FlatButton, 'Create account'), findsOneWidget);
		expect(find.widgetWithText(FlatButton, 'Password lost'), findsOneWidget);
		expect(find.byType(OutlineButton), findsOneWidget); // Google
	});
	
	// -------------------
	// -- Login actions
	// -------------------
	
	testWidgets('Submit login form without password', (WidgetTester tester) async {
		await tester.pumpWidget(appMock);
		await tester.enterText(find.widgetWithText(TextFormField, 'Email'), workingEmail);
		await tester.tap(find.widgetWithText(RaisedButton, 'Login'));
		await tester.pump();
		
		expect(find.text("Password can't be empty"), findsOneWidget);
	});
	
	testWidgets('Submit login form with badly formatted email', (WidgetTester tester) async {
		await tester.runAsync(() async {
			await tester.pumpWidget(appMock);
			await tester.enterText(emailField, wrongEmail);
			await tester.enterText(passwordField, strongPassword);
			await tester.tap(loginButton);
			await tester.pump();
			
			await expectLoaderAndDelay(tester);
			
			// Expect to find email error and wrongEmail still displayed on field
			expect(find.text("The email address is badly formatted."), findsOneWidget);
			expect(find.widgetWithText(TextFormField, wrongEmail), findsOneWidget);
		});
	});
	
	testWidgets('Submit login with unknown email', (WidgetTester tester) async {
		await tester.runAsync(() async {
			await tester.pumpWidget(appMockError);
			await tester.enterText(emailField, workingEmail); // Works because appMockError is launched !
			await tester.enterText(passwordField, strongPassword);
			await tester.tap(loginButton);
			await tester.pump();
			
			await expectLoaderAndDelay(tester);
			
			// Expect to find no user error and workingEmail still displayed on field
			expect(find.widgetWithText(TextFormField, workingEmail), findsOneWidget);
			expect(find.text("There is no user record corresponding to this identifier. The user may have been deleted."), findsOneWidget);
		});
	});
	
	testWidgets('Login successfully', (WidgetTester tester) async {
		await tester.runAsync(() async {
			await tester.pumpWidget(appMock);
			await tester.enterText(emailField, workingEmail);
			await tester.enterText(passwordField, strongPassword);
			await tester.tap(loginButton);
			await tester.pump();
			
			await expectLoaderAndDelay(tester);
			
			// Build the redirection with navigator observer
			await _buildMainPage(tester);
			verify(mockObserver.didPush(any, any)); // Check we're redirected
			
			// Expect to be redirected to recordings and to have title My recordings
//			expect(find.text("My recordings"), findsOneWidget); //TODO When above todo is fixed
		});
	});
	
	// -------------------
	// -- Reset actions
	// -------------------
	testWidgets('Reset password', (WidgetTester tester) async {
		await tester.pumpWidget(appMock);
		
		// We fill the form, (why not) and click the Password lost button
		await tester.enterText(emailField, workingEmail);
		FlatButton passwordLostButton = find.widgetWithText(FlatButton, 'Password lost').evaluate().first.widget;
		passwordLostButton.onPressed(); // I don't know why i have to use this complicated form of event ...
		await tester.pump();
		
		// We expect to find the email with the previous text entered and the password field to disappear
		expect(find.widgetWithText(TextFormField, workingEmail), findsOneWidget);
		expect(passwordField, findsNothing);
		expect(resetButton, findsOneWidget);
		
		await tester.tap(resetButton);
		await tester.pump();
		
		// A modal shows up : We click on OK button
		expect(find.text("Verify your email"), findsOneWidget);
		expect(find.text("A link to change your password has been sent to your email"), findsOneWidget);
		
		await tester.tap(find.widgetWithText(FlatButton, 'OK'));
		await tester.pump();
		
		// We expect to find the login page with my email already filled
		expect(find.widgetWithText(TextFormField, workingEmail), findsOneWidget);
		expect(loginButton, findsOneWidget);
	});
	
	// -------------------
	// -- Sign up actions
	// -------------------
	testWidgets('Successfully create a new account', (WidgetTester tester) async {
		await tester.runAsync(() async {
			await tester.pumpWidget(appMock);
			await tester.tap(find.widgetWithText(FlatButton, 'Create account'));
			await tester.pump();
			
			// We expect to see the create account button instead of login
			expect(loginButton, findsNothing);
			expect(createAccountButton, findsOneWidget);
			
			// We fill the form & submit
			await tester.enterText(emailField, workingEmail);
			await tester.enterText(passwordField, strongPassword);
			await tester.tap(createAccountButton);
			await tester.pump();
			
			await expectLoaderAndDelay(tester);
			
			expect(find.text("Verify your email"), findsOneWidget);
			expect(find.text("A link to verify account has been sent to your email"), findsOneWidget);
			
			await tester.tap(find.widgetWithText(FlatButton, 'OK'));
			await tester.pump();
			
			// We expect the login button to appear
			expect(find.widgetWithText(TextFormField, workingEmail), findsOneWidget);
			expect(loginButton, findsOneWidget);
			expect(mock.didSignUp, true);
		});
	});
	
	testWidgets('Create account with weak password', (WidgetTester tester) async {
		await tester.runAsync(() async {
			await tester.pumpWidget(appMock);
			await tester.tap(find.widgetWithText(FlatButton, 'Create account'));
			await tester.pump();
			
			// We expect to see the create account button instead of login
			expect(loginButton, findsNothing);
			expect(createAccountButton, findsOneWidget);
			
			await tester.enterText(emailField, workingEmail);
			await tester.enterText(passwordField, weakPassword);
			await tester.tap(createAccountButton);
			await tester.pump();
			
			await expectLoaderAndDelay(tester);
			
			// We expect the SignUp to be cancelled, email field to have the workingEmail and weak password warning
			expect(mock.didSignUp, false);
			expect(find.widgetWithText(TextFormField, workingEmail), findsOneWidget);
			expect(find.text('The given password is invalid. [ Password should be at least 6 characters ]'), findsOneWidget);
		});
	});
}