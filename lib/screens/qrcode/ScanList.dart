import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:personalimprover/helpers/SlideLeftRoute.dart';
import 'package:personalimprover/helpers/utils.dart';
import 'package:personalimprover/models/Scan.dart';
import 'package:personalimprover/screens/Login.dart';
import 'package:personalimprover/screens/qrcode/Generate.dart';
import 'package:personalimprover/screens/qrcode/ScanDetail.dart';
import 'package:personalimprover/screens/qrcode/Scanner.dart';
import 'package:personalimprover/screens/shared/StackLineDecoration.dart';
import 'package:personalimprover/translations/QRCode.i18n.dart';

class ScanList extends StatefulWidget {
	ScanList({Key key}) : super(key: key);
	
	@override
	_ScanListState createState() => _ScanListState();
}

class _ScanListState extends State<ScanList> {
	final _db = Firestore.instance;
	
	@override
	Widget build(BuildContext context) => Container(child: Column(children: <Widget>[header(), listScans()]));
	
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
						child: Text('My barcodes'.i18n, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
					),
				),
				Positioned(
					right: 90,
					top: 10,
					child: Container(
						margin: EdgeInsets.only(top: 10),
						child: RawMaterialButton(
							fillColor: Colors.blue,
							textStyle: TextStyle(color: Colors.white),
							padding: EdgeInsets.all(15),
							shape: CircleBorder(),
							onPressed: () => Navigator.push(context, SlideLeftRoute(page: Scanner())),
							child: Icon(Icons.settings_overscan),
						)
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
							onPressed: () => Navigator.push(context, SlideLeftRoute(page: Generate())),
							child: Icon(Icons.add),
						)
					),
				),
			],
		);
	}
	
	Widget listScans() {
		return Expanded(
			child: StreamBuilder(
				stream: Scan.getInstance(_db).where("userId", isEqualTo: connectedUser.uid).orderBy("creationDate", descending: true).limit(50).snapshots(),
				builder: (BuildContext context, AsyncSnapshot snapshot) {
					if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
					if (snapshot.hasData && snapshot.data.documents.length == 0) return Center(child: Text('No data'.i18n));
					
					return ListView.builder(
						shrinkWrap: true,
						itemCount: snapshot.data.documents.length,
						itemBuilder: (context, index) {
							Scan scan = Scan.fromDb(snapshot.data.documents[index].documentID, snapshot.data.documents[index]);
							return _buildList(context, scan);
						}
					);
				}
			)
		);
	}
	
	Widget _buildList(BuildContext context, Scan scan) {
		return Dismissible(
			key: Key(scan.key),
			background: Container(color: Colors.red),
			confirmDismiss: (DismissDirection direction) async => confirmDismiss(context),
			onDismissed: (direction) => Scan.delete(_db, scan),
			child: ListTile(
				leading: Icon(Icons.view_column),
				title: Text(scan.name, style: TextStyle(fontSize: 16.0), overflow: TextOverflow.ellipsis),
				subtitle: (connectedUser.condensedView) ? null : Container(
					child: Text("Created on : %s".i18n.fill([scan.creationDate]), style: TextStyle(fontSize: 12, color: Colors.grey)),
				),
				onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ScanDetail(scan: scan))),
			)
		);
	}
}