import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class FingerPrint {
	final LocalAuthentication _localAuthentication = LocalAuthentication();
	
	Future<bool> isBiometricAvailable() async {
		bool isAvailable = false;
		try {
			isAvailable = await _localAuthentication.canCheckBiometrics;
		} on PlatformException catch (e) {
			print(e);
		}
		
		return isAvailable;
	}
	
	Future<void> getListOfBiometricTypes() async {
		try {
			await _localAuthentication.getAvailableBiometrics();
		} on PlatformException catch (e) {
			print(e);
		}
	}
	
	Future<bool> authenticateUser() async {
		bool isAuthenticated = false;
		try {
			isAuthenticated = await _localAuthentication.authenticateWithBiometrics(
				localizedReason:
				"Merci de vous authentifier pour accéder à l'application.",
				useErrorDialogs: true,
				stickyAuth: true,
			);
		} on PlatformException catch (e) {
			print(e);
		}
		
		if (isAuthenticated) {
			return true;
		}
		return false;
	}
	
	Future<bool> isAuthenticated() async {
		if (await isBiometricAvailable()) {
			await getListOfBiometricTypes();
			if (await authenticateUser()) {
				return true;
			} else {
				return false;
			}
		}
		// User does not have access to fingerprint scanner
		return true;
	}
}