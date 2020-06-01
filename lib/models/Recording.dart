import 'dart:io' as io;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:personalimprover/models/User.dart';
import 'package:personalimprover/screens/Login.dart';

final recordingTableName = 'recordings';

class MyRecording {
	DateTime now = DateTime.now();
	
	String key;
	String name;
	String description;
	String url;
	String path;
	String duration;
	String creationDate;
	int size;
	String userId;
	
	MyRecording({this.name, this.description, this.duration, this.size, this.url, this.path, this.userId, this.creationDate});
	
	MyRecording.fromDb(objKey, values)
		:
			key = objKey,
			name = values["name"],
			description = values["description"],
			userId = values['userId'],
			duration = values['duration'],
			creationDate = values['creationDate'],
			size = values['size'],
			url = values['url'],
			path = values['path'];
	
	toJson() {
		return {
			"name": name ?? DateFormat('dd-MM-yyyy HH:mm:ss').format(now),
			"description": description ?? 'Aucune description',
			"userId": userId ?? connectedUser.uid,
			"duration": duration,
			"creationDate": creationDate,
			"size": size,
			"path": path,
			"url": url,
		};
	}
	
	// Replace all static method with non static ?
	static Query getInstance(_db) => _db.collection(recordingTableName);
	
	// Add and related to adding
	static add(Firestore db, MyRecording recording) {
		if (recording != null) {
			db.collection(recordingTableName).add(recording.toJson());
		}
	}
	
	static update(Firestore db, MyRecording recording) {
		if (null != recording) {
			db.collection(recordingTableName).document(recording.key).updateData(recording.toJson());
		}
	}
	
	static void delete(Firestore db, MyRecording recording) async {
		// We check the file exists on the FS
		await deleteFromFS(recording);
		// We check the file exists on Firestorage
		await deleteFromCloud(recording);
		// We update the user size thingy, but only if it's on the cloud
		User.updateQuota(db, recording, 'remove');
		// We wait for firestore to delete the item
		await db.collection(recordingTableName).document(recording.key).delete();
	}
	
	// Firestorage
	static Future<String> uploadRecording(File file, String name) async {
		StorageReference storageReference = FirebaseStorage.instance.ref().child("recording/${connectedUser.email}/$name");
		
		final StorageUploadTask uploadTask = storageReference.putFile(file);
		final StorageTaskSnapshot downloadUrl = await uploadTask.onComplete;
		final String url = await downloadUrl.ref.getDownloadURL();
		
		return url;
	}
	
	static deleteFromCloud(MyRecording recording) async {
		// We check the user asked for the file to be saved on the cloud
		if (recording.url != '') {
			StorageReference storageReference;
			
			storageReference = await FirebaseStorage.instance.getReferenceFromUrl(recording.url.toString());
			await storageReference.delete();
		}
	}
	
	static deleteFromFS(recording) async {
		if (await io.File(recording.path).exists()) {
			await LocalFileSystem().file(recording.path).delete();
		}
	}
	
	static Future<void> deleteAllRecordings(Firestore db) async {
		await db.collection(recordingTableName).where("userId", isEqualTo: connectedUser.uid).getDocuments().then((query) {
			query.documents.forEach((doc) => MyRecording.delete(db, MyRecording.fromDb(doc.documentID, doc)));
		});
		
	}
}