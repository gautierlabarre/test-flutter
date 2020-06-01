import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personalimprover/helpers/ScaleRoute.dart';
import 'package:personalimprover/helpers/utils.dart';
import 'package:personalimprover/models/Recording.dart';
import 'package:personalimprover/screens/Login.dart';
import 'package:personalimprover/screens/recording/AudioRecorder.dart';
import 'package:personalimprover/screens/recording/RecordingDetail.dart';
import 'package:personalimprover/screens/shared/StackLineDecoration.dart';
import 'package:personalimprover/translations/Recording.i18n.dart';

class RecordingList extends StatefulWidget {
	RecordingList({Key key}) : super(key: key);
	
	@override
	_MyRecordings createState() => _MyRecordings();
}

class _MyRecordings extends State<RecordingList> {
	final Firestore _db = Firestore.instance;
	
	@override
	Widget build(BuildContext context) => Container(child: Column(children: <Widget>[header(), listRecords()]));
	
	Widget header() {
		return Stack(
			children: <Widget>[
				StackLineDecoration(),
				StackLineDecoration().fillContainer(),
				Positioned(
					top: -10,
					left: -10,
					child: Padding(
						padding: EdgeInsets.all(25),
						child: Text("My recordings".i18n, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
					),
				),
				Positioned(
					right: 20,
					top: 10,
					child: Container(
						margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
						child: RawMaterialButton(
							fillColor: Colors.green,
							textStyle: TextStyle(color: Colors.white),
							padding: EdgeInsets.all(15),
							shape: CircleBorder(),
							onPressed: () => Navigator.push(context, ScaleRoute(page: AudioRecorder(start: true))),
							child: Icon(Icons.keyboard_voice),
						)
					),
				),
			],
		);
	}
	
	Widget listRecords() {
		return Expanded(
			child: StreamBuilder(
				stream: MyRecording.getInstance(_db).where("userId", isEqualTo: connectedUser.uid).orderBy("creationDate", descending: true).limit(50).snapshots(),
				builder: (BuildContext context, AsyncSnapshot snapshot) {
					if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
					if (snapshot.hasData && snapshot.data.documents.length == 0) return Center(child: Text('No record'.i18n));
					return ListView.builder(
						shrinkWrap: true,
						itemCount: snapshot.data.documents.length,
						itemBuilder: (BuildContext context, int index) {
							MyRecording record = MyRecording.fromDb(snapshot.data.documents[index].documentID, snapshot.data.documents[index]);
							return _buildList(context, record);
						}
					);
				}
			),
		);
	}
	
	Widget _buildList(BuildContext context, MyRecording record) {
		String duration = transformStringDuration(record.duration);
		String size = sizeInKo(record.size);
		
		return Dismissible(
			key: Key(record.key),
			background: Container(color: Colors.red),
			confirmDismiss: (DismissDirection direction) async => confirmDismiss(context),
			onDismissed: (direction) => MyRecording.delete(_db, record),
			child: ListTile(
				leading: Icon(Icons.voicemail),
				title: Text(record.name, style: TextStyle(fontSize: 16.0), overflow: TextOverflow.ellipsis),
				subtitle: (connectedUser.condensedView) ? null : Container(
					child: Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: <Widget>[
							Text("Duration %s s".i18n.fill([duration]), style: TextStyle(fontSize: 12, color: Colors.grey)),
							Text("Size %s Ko".i18n.fill([size]), style: TextStyle(fontSize: 12, color: Colors.grey)),
						],
					),
				),
				trailing: IconButton(
					icon: Icon(Icons.play_arrow),
					onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RecordingDetail(recording: record, autoPlay: true))),
				),
				onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RecordingDetail(recording: record))),
			)
		);
	}
}