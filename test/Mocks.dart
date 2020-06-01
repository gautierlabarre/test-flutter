import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:mockito/mockito.dart';
import 'package:personalimprover/helpers/Authentication.dart';
import 'package:personalimprover/models/User.dart';

import 'variables.dart';

class AuthMock implements Auth {
	AuthMock({this.userFakeId});
	
	String userFakeId;
	bool didRequestSignIn = false;
	bool didSignUp = false;
	
	@override
	Future<String> signUp(String email, String password) async {
		await Future.delayed(Duration.zero);
		didSignUp = false;
		
		if (password == weakPassword) {
			throw StateError('The given password is invalid. [ Password should be at least 6 characters ]');
		}
		if (userFakeId != null) {
			didSignUp = true;
			return Future.value(userFakeId);
		} else {
			throw StateError('No user');
		}
	}
	
	@override
	Future<String> signIn(String email, String password) async {
		didRequestSignIn = true;
		await Future.delayed(Duration.zero);
		
		if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
			throw StateError("The email address is badly formatted."); // be careful here the string comes from Firebase ! It might change.
		}
		if (userFakeId != null) {
			return Future.value(userFakeId);
		} else {
			throw StateError("There is no user record corresponding to this identifier. The user may have been deleted.");
		}
	}
	
	@override
	void constructUser(key, values) {
	}
	
	@override
	Future<User> generateUser(FirebaseUser key) {
		throw UnimplementedError();
	}
	
	@override
	Future<FirebaseUser> getCurrentUser() {
		throw UnimplementedError();
	}
	
	@override
	Future<String> googleSignIn() {
		throw UnimplementedError();
	}
	
	@override
	Future<bool> isEmailVerified() {
		throw UnimplementedError();
	}
	
	@override
	Future<void> resetPassword(String key) async {
		return null;
	}
	
	@override
	Future<void> sendEmailVerification() {
		return null;
	}
	
	@override
	Future<void> signOut() {
		throw UnimplementedError();
	}
	
	@override
	Future<void> deleteAccount() {
		// TODO: implement deleteAccount
		return null;
	}

  @override
  Future<void> updateUser(String newName) {
    // TODO: implement updateUser
    return null;
  }
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}
