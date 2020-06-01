import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:personalimprover/screens/Login.dart';

final tagTableName = 'tags';

class ImprovedTag extends Tag {
	bool selected = false;
	@override
	String name;
	
	@override
	String userId;
	ImprovedTag({this.name, this.userId, this.selected});
}
class Tag {
	DateTime now = DateTime.now();
	
	String key;
	String name;
	String userId;
	
	Tag({this.name, this.userId});
	
	Tag.fromDb(objKey, values)
		:
			key = objKey,
			name = values["name"],
			userId = values['userId'];
	
	Tag.fromJson(values)
		:
			name = values["name"],
			userId = values['userId'];
	
	toJson() {
		return {
			"name": name,
			"userId": userId ?? connectedUser.uid,
		};
	}
	
	static Query getInstance(_db) => _db.collection(tagTableName);
	
	static void add(Firestore db, Tag tag) {
		if (tag != null) {
			db.collection(tagTableName).add(tag.toJson());
		}
	}
	
	static delete(Firestore db, String tagKey) {
		if (tagKey != null) {
			return db.collection(tagTableName).document(tagKey).delete();
		}
	}

  static deleteAllTags(Firestore db) async {
	  await db.collection(tagTableName).where("userId", isEqualTo: connectedUser.uid).getDocuments().then((query) {
		  query.documents.forEach((doc) => Tag.delete(db, doc.documentID));
	  });
  }
}