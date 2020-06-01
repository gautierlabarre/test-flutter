import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:personalimprover/models/Recording.dart';
import 'package:personalimprover/screens/Login.dart';

final userTableName = 'users';

class User {
	String key;
	String uid;
	String email;
	String name;
	String picture;
	
	bool isPro;
	int audioSize;
	
	// User preferences
	bool autoUpload;
	bool fingerprint;
	bool wifiUpload;
	bool darkTheme;
	bool audioQuality;
	bool condensedView;
	
	
	static int proQuota = 1000000000;
	static int freeQuota = 100000000;
	
	User({this.uid, this.email, this.name, this.picture, this.isPro, this.audioSize});
	
	Map<String, dynamic> toJson() {
		return {
			"name": this.name,
			"email": this.email,
			"uid": this.uid,
			"picture": this.picture ?? 'https://png.pngtree.com/png-clipart/20190520/original/pngtree-vector-users-icon-png-image_4144740.jpg',
			"autoUpload": this.autoUpload,
			"darkTheme": this.darkTheme,
			"fingerprint": this.fingerprint,
			"wifiUpload": this.wifiUpload,
			"condensedView": this.condensedView,
			"audioQuality": this.audioQuality,
			"isPro": this.isPro ?? false,
			"audioSize": this.audioSize ?? 0
		};
	}
	
	// Replace all static method with non static ?
	static Query getInstance(_db) => _db.collection(userTableName);
	
	// Add and related to adding
	static Future<void> add(Firestore db, User user) async {
		if (null != user) {
			await db.collection(userTableName).add(user.toJson());
		}
	}
	
	static update(Firestore db, Map<String, dynamic> data) {
		if (null != data) {
			db.collection(userTableName).document(connectedUser.key).updateData(data);
		}
	}
	
	static Future<void> addWithUid(Firestore db, User user) async {
		if (null != user) {
			await db.collection(userTableName).document(user.uid).setData(user.toJson());
		}
	}
	
	static void updateQuota(Firestore db, MyRecording recording, String type) {
		if (recording.url != '') {
			if (type == 'remove') {
				connectedUser.audioSize = connectedUser.audioSize - recording.size;
			} else {
				connectedUser.audioSize = connectedUser.audioSize + recording.size;
			}
			
			User.update(db, {'audioSize': connectedUser.audioSize});
		}
	}
	
	static bool checkQuota(int addedOctets) {
		int quota = User.freeQuota;
		if (connectedUser.isPro) {
			quota = User.proQuota;
		}
		// The user asks to save something that is bigger than the allowed quota
		if (connectedUser.audioSize + addedOctets > quota) {
			return false;
		}
		
		return true;
	}
	
	static deleteUser(Firestore db) async {
		await db.collection(userTableName).where("uid", isEqualTo: connectedUser.uid).getDocuments().then((query) {
			query.documents.forEach((doc) => db.collection(userTableName).document(doc.documentID).delete());
		});
	}
	
}