import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personalimprover/screens/Login.dart';

final scanTableName = 'scans';

class Scan {
	DateTime now = DateTime.now();
	
	String key;
	String name;
	String data;
	String description;
	String creationDate;
	String userId;
	
	Scan({this.name, this.description, this.userId, this.creationDate, this.data});
	
	Scan.fromDb(objKey, values)
		:
			key = objKey,
			name = values["name"],
			description = values["description"],
			data = values["data"],
			userId = values['userId'],
			creationDate = values['creationDate'];
	
	toJson() {
		return {
			"name": name ?? DateFormat('dd-MM-yyyy HH:mm:ss').format(now),
			"description": description ?? 'Aucune description',
			"userId": userId ?? connectedUser.uid,
			"creationDate": creationDate ?? DateFormat('dd-MM-yyyy HH:mm:ss').format(now),
			"data": data,
		};
	}
	
	static Query getInstance(_db) => _db.collection(scanTableName);
	
	static void add(Firestore db, Scan scan) {
		if (scan != null) {
			db.collection(scanTableName).add(scan.toJson());
		}
	}
	
	static delete(Firestore db, Scan scan) {
		if (scan != null) {
			return db.collection(scanTableName).document(scan.key).delete();
		}
	}
	
	static update(Firestore db, Scan scan) {
		if (scan != null) {
			db.collection(scanTableName).document(scan.key).updateData(scan.toJson());
		}
	}
	
	static Future<void> shareQR(globalKey, qrcodeData) async {
		try {
			String currentDate = DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());
			io.Directory appDocDirectory;
			if (io.Platform.isIOS) {
				appDocDirectory = await getApplicationDocumentsDirectory();
			} else {
				appDocDirectory = await getExternalStorageDirectory();
			}
			
			RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();
			final image = await boundary.toImage();
			ByteData imageData = await image.toByteData(format: ImageByteFormat.png);
			final file = io.File('${appDocDirectory.path}/qr_code-2.png');
			if (file.existsSync()) await file.delete();
			
			await file.writeAsBytes(imageData.buffer.asUint8List());
			
			await FlutterShare.shareFile(
				title: "QR du $currentDate",
				filePath: file.path,
				text: "Contenu : $qrcodeData",
			);
		} catch (exception) {
			print(exception);
		}
	}
	
	static Future<void> deleteAllScans(Firestore db) async {
		await db.collection(scanTableName).where("userId", isEqualTo: connectedUser.uid).getDocuments().then((query) {
			query.documents.forEach((doc) => Scan.delete(db, Scan.fromDb(doc.documentID, doc)));
		});
	}
}