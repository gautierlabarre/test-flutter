import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:personalimprover/models/Goal.dart';
import 'package:personalimprover/models/Recording.dart';
import 'package:personalimprover/models/Scan.dart';
import 'package:personalimprover/models/Tag.dart';
import 'package:personalimprover/models/User.dart';
import 'package:personalimprover/screens/Login.dart';

final GoogleSignIn googleSignInService = GoogleSignIn();

abstract class BaseAuth {
	Future<String> signIn(String email, String password);
	
	Future<String> googleSignIn();
	
	Future<String> signUp(String email, String password);
	
	Future<FirebaseUser> getCurrentUser();
	
	Future<void> deleteAccount();
	
	Future<void> sendEmailVerification();
	
	Future<void> signOut();
	
	Future<bool> isEmailVerified();
	
	Future<void> resetPassword(String email);
	
	Future<void> updateUser(String newName);
}

class Auth implements BaseAuth {
	final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
	
	@override
	Future<void> resetPassword(String email) async => await _firebaseAuth.sendPasswordResetEmail(email: email);
	
	@override
	Future<String> signIn(String email, String password) async {
		AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
		FirebaseUser user = result.user;
		
		if (user.isEmailVerified) {
			await generateUser(user);
			return user.uid;
		}
		return null;
	}
	
	@override
	Future<String> signUp(String email, String password) async {
		AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
		FirebaseUser user = result.user;
		
		final Firestore _db = Firestore.instance;
		await User.add(_db, User(name: user.email.split('@')[0], email: user.email, uid: user.uid));
		
		return user.uid;
	}
	
	@override
	Future<FirebaseUser> getCurrentUser() async => await _firebaseAuth.currentUser();
	
	@override
	Future<void> deleteAccount() async {
		//TODO Bug fix : requires recent login.
		FirebaseUser user = await getCurrentUser();
		final Firestore db = Firestore.instance;
		await MyRecording.deleteAllRecordings(db); // Not possible for now, i should do it manually
		await Scan.deleteAllScans(db);
		await Goal.deleteAllGoals(db);
		await Tag.deleteAllTags(db);
		await User.deleteUser(db);
		await user.delete();
		await signOut();
		// Possible improvement : Send a mail to confirm
	}
	
	@override
	Future<void> signOut() async {
		try {
			await googleSignInService.signOut();
			connectedUser = null;
			
		} catch (e) {
			print(e);
		}
		
		return _firebaseAuth.signOut();
	}
	
	@override
	Future<void> sendEmailVerification() async {
		FirebaseUser user = await _firebaseAuth.currentUser();
		await user.sendEmailVerification();
	}
	
	@override
	Future<bool> isEmailVerified() async {
		FirebaseUser user = await _firebaseAuth.currentUser();
		return user.isEmailVerified;
	}
	
	@override
	Future<String> googleSignIn() async {
		final GoogleSignInAccount googleSignInAccount = await googleSignInService.signIn();
		if (googleSignInAccount == null) return null;
		
		final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
		final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
		
		final AuthCredential credential = GoogleAuthProvider.getCredential(
			accessToken: googleSignInAuthentication.accessToken,
			idToken: googleSignInAuthentication.idToken,
		);
		
		final AuthResult authResult = await _firebaseAuth.signInWithCredential(credential);
		final FirebaseUser user = authResult.user;
		
		if (user.email == null) await googleSignInService.signOut();
		
		await generateUser(user);
		return user.uid;
	}
	
	@override
	Future<void> updateUser(String newName) async {
		FirebaseUser user = await _firebaseAuth.currentUser();
		UserUpdateInfo userInfo = UserUpdateInfo();
		userInfo.displayName = newName;
		await user.updateProfile(userInfo);
		connectedUser.name = userInfo.displayName;
		return null;
	}
	
	Future<User> generateUser(FirebaseUser user) async {
		var completer = Completer<User>();
		connectedUser = User();
		
		final Firestore _db = Firestore.instance;
		String name = 'newUser';
		
		String photoUrl = user.photoUrl ?? 'https://png.pngtree.com/png-clipart/20190520/original/pngtree-vector-users-icon-png-image_4144740.jpg';
		
		if (user.displayName != null && user.displayName.isNotEmpty) {
			name = user.displayName;
		} else {
			name = user.email.split('@')[0];
		}
		
		connectedUser.uid = user.uid;
		connectedUser.email = user.email;
		connectedUser.name = name;
		connectedUser.picture = photoUrl;
		
		await _db.collection('users').document(user.uid).get().then((value) async {
			if (value.data != null) {
				constructUser(value.documentID, value.data);
				completer.complete(connectedUser);
			} else {
				await User.addWithUid(_db, User(name: name, email: user.email, picture: photoUrl, uid: user.uid));
				await _db.collection('users').document(user.uid).get().then((value) {
					constructUser(value.documentID, value.data);
					completer.complete(connectedUser);
				});
			}
		});
		
		return completer.future;
	}
	
	void constructUser(key, values) {
		connectedUser.key = key;
		connectedUser.autoUpload = values['autoUpload'] ?? false;
		connectedUser.darkTheme = values['darkTheme'] ?? false;
		connectedUser.fingerprint = values['fingerprint'] ?? false;
		connectedUser.wifiUpload = values['wifiUpload'] ?? true;
		connectedUser.audioQuality = values['audioQuality'] ?? false;
		connectedUser.audioSize = values['audioSize'] ?? 0;
		connectedUser.isPro = values['isPro'] ?? false;
		connectedUser.condensedView = values['condensedView'] ?? false;
	}


}