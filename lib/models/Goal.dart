import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:personalimprover/screens/Login.dart';

final goalTableName = 'goals';

class Goal {
	DateTime now = DateTime.now();
	
	String key;
	String name;
	bool checked;
	String description;
	String creationDate;
	String userId;
	List<dynamic> tags; //TODO Update typing ...
	// TODO ADD : Due date + files (list)
	
	Goal({this.name, this.description, this.userId, this.creationDate, this.checked});
	
	Goal.fromDb(objKey, values)
		:
			key = objKey,
			name = values["name"],
			description = values["description"],
			checked = values["checked"],
			userId = values['userId'],
			tags = values['tags'],
			creationDate = values['creationDate'];
	
	toJson() {
		return {
			"name": name ?? DateFormat('dd-MM-yyyy HH:mm:ss').format(now),
			"description": description ?? 'Aucune description',
			"userId": userId ?? connectedUser.uid,
			"tags": tags,
			"creationDate": creationDate ?? DateFormat('dd-MM-yyyy HH:mm:ss').format(now),
			"checked": checked,
		};
	}
	
	static Query getInstance(_db) => _db.collection(goalTableName);
	
	static void add(Firestore db, Goal goal) {
		if (goal != null) {
			db.collection(goalTableName).add(goal.toJson());
		}
	}
	
	static delete(Firestore db, Goal goal) {
		if (goal != null) {
			return db.collection(goalTableName).document(goal.key).delete();
		}
	}
	
	static update(Firestore db, Goal goal) {
		if (goal != null) {
			db.collection(goalTableName).document(goal.key).updateData(goal.toJson());
		}
	}

  static Future<void> deleteAllGoals(Firestore db) async {
	  await db.collection(goalTableName).where("userId", isEqualTo: connectedUser.uid).getDocuments().then((query) {
		  query.documents.forEach((doc) => Goal.delete(db, Goal.fromDb(doc.documentID, doc)));
	  });
  }
}