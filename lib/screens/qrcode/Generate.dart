import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:personalimprover/helpers/SlideLeftRoute.dart';
import 'package:personalimprover/models/Scan.dart';
import 'package:personalimprover/screens/qrcode/Scanner.dart';
import 'package:personalimprover/screens/shared/StackBackButton.dart';
import 'package:personalimprover/screens/shared/StackTitle.dart';
import 'package:personalimprover/screens/shared/clipping.dart';
import 'package:personalimprover/translations/QRCode.i18n.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Generate extends StatefulWidget {
	Generate({Key key}) : super(key: key);
	
	@override
	_GenerateState createState() => _GenerateState();
}

class _GenerateState extends State<Generate> {
	GlobalKey globalKey = GlobalKey();
	GlobalKey formKey = GlobalKey<FormState>();
	final Firestore _db = Firestore.instance;
	final TextEditingController _qrDataController = TextEditingController();
	final TextEditingController _qrNameController = TextEditingController();
	String qrData = '';
	String scanName = '';
	
	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			onPanUpdate: (detail) => (detail.delta.dx > 10) ? Navigator.pop(context) : null,
			child: Scaffold(
				body: SingleChildScrollView(
					child: Stack(
						children: <Widget>[
							Clipping(),
							Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: <Widget>[
									StackBackButton(),
									StackTitle().title("QR Code generator".i18n),
									pageContent()
								]
							),
						],
					),
				),
				bottomNavigationBar: bottomBar(),
				floatingActionButton: floatingButton(),
				floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
			),
		);
	}
	
	Widget pageContent() => Column(children: <Widget>[inputName(), submitButton(), qrPreview()]);
	
	Widget inputName() {
		return Padding(
			padding: EdgeInsets.all(20),
			child: TextField(
				controller: _qrDataController,
				keyboardType: TextInputType.multiline,
				autofocus: true,
				maxLines: 5,
				maxLength: 300,
				maxLengthEnforced: true,
				decoration: InputDecoration(hintText: "Type QR Code content".i18n),
			),
		);
	}
	
	Widget submitButton() {
		return Padding(
			padding: const EdgeInsets.only(left: 10.0),
			child: FlatButton(
				color: Colors.green,
				child: Text("Generate".i18n),
				onPressed: () => setState(() => qrData = _qrDataController.text),
			),
		);
	}
	
	Widget qrPreview() {
		return Padding(
			padding: EdgeInsets.only(top: 20),
			child: Center(
				child: qrData.isNotEmpty ? RepaintBoundary(
					key: globalKey,
					child: QrImage(
						foregroundColor: Colors.black,
						backgroundColor: Colors.white,
						data: qrData,
						size: 300
					),
				) : Text(''),
			),
		);
	}
	
	Widget bottomBar() {
		return BottomAppBar(
			notchMargin: 10,
			shape: CircularNotchedRectangle(),
			child: Row(
				mainAxisSize: MainAxisSize.max,
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				children: <Widget>[
					Padding(
						padding: EdgeInsets.only(left: 50),
						child: IconButton(icon: Icon(Icons.share), onPressed: () => Scan.shareQR(globalKey, qrData)),
					),
					Padding(
						padding: EdgeInsets.only(right: 50),
						child: IconButton(icon: Icon(Icons.settings_overscan), onPressed: () => Navigator.push(context, SlideLeftRoute(page: Scanner())),
						),
					)
				],
			),
		);
	}
	
	Widget floatingButton() {
		return IgnorePointer(
			ignoring: qrData == '',
			child: FloatingActionButton(
				splashColor: Colors.blue,
				backgroundColor: Colors.green,
				onPressed: () => saveCode(),
				child: Icon(Icons.save, color: Colors.white),
			)
		);
	}
	
	void saveCode() {
		showDialog(context: context, builder: (context) =>
			AlertDialog(
				title: Text("Add a name".i18n),
				content: Form(
					key: formKey,
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: <Widget>[
							Padding(
								padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
								child: TextField(
									maxLines: 1,
									maxLength: 30,
									maxLengthEnforced: true,
									keyboardType: TextInputType.text,
									autofocus: true,
									decoration: InputDecoration(hintText: 'Name'.i18n),
									controller: _qrNameController,
								)
							),
						],
					),
				),
				actions: <Widget>[FlatButton(child: Text('Validate'.i18n), onPressed: () => validateAndSave())],
			),
		);
	}
	
	void validateAndSave() {
		String scanName = _qrNameController.text.trim();
		if (scanName == '') scanName = null;
		Scan.add(_db, Scan(name: scanName, data: qrData));
		Navigator.of(context).popUntil((route) => route.isFirst);
	}
}