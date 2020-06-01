import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personalimprover/helpers/InfoBar.dart';
import 'package:personalimprover/models/Scan.dart';
import 'package:personalimprover/screens/shared/StackBackButton.dart';
import 'package:personalimprover/screens/shared/StackTitle.dart';
import 'package:personalimprover/screens/shared/clipping.dart';
import 'package:personalimprover/translations/QRCode.i18n.dart';

class Scanner extends StatefulWidget {
	@override
	_ScanState createState() => _ScanState();
}

class _ScanState extends State<Scanner> {
	String barcode = "";
	String _scanNewName = '';
	final _formKey = GlobalKey<FormState>();
	final Firestore _db = Firestore.instance;
	
	@override
	initState() {
		super.initState();
		scan();
	}
	
	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			onPanUpdate: (detail) => (detail.delta.dx > 10) ? Navigator.pop(context) : null,
			child: Scaffold(
				body: SingleChildScrollView(
					child:
					Stack(
						children: <Widget>[
							Clipping(),
							Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: <Widget>[
									StackBackButton(),
									StackTitle().title('Scan result'.i18n),
									resultScanContent(),
									Padding(padding: EdgeInsets.symmetric(vertical: 20)),
									showForm(),
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
	
	Widget resultScanContent() {
		return Padding(
			padding: EdgeInsets.fromLTRB(50, 20, 50, 0),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.start,
				crossAxisAlignment: CrossAxisAlignment.start,
				children: <Widget>[
					Container(
						padding: EdgeInsets.only(right: 10),
						child: Icon(Icons.format_quote),
					),
					Flexible(
						child: Container(
							height: 100,
							padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
							decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.orange, width: 4.0))),
							child: Text(barcode)
						)
					)
				],
			)
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
						child: IconButton(icon: Icon(Icons.content_copy), onPressed: () => copyContent()),
					),
					Padding(
						padding: EdgeInsets.only(right: 50),
						child: IconButton(icon: Icon(Icons.refresh), onPressed: () => retryScan()),
					)
				],
			),
		);
	}
	
	Widget floatingButton() {
		return FloatingActionButton(
			splashColor: Colors.blue,
			backgroundColor: Colors.green,
			onPressed: () => saveCode(),
			child: Icon(Icons.save, color: Colors.white),
		);
	}
	
	void copyContent() {
		Clipboard.setData(ClipboardData(text: barcode));
		InfoBar(context).info(message: 'Content copied to the clipboard'.i18n);
	}
	
	void retryScan() {
		// Empty clipboard
		Clipboard.setData(ClipboardData(text: ''));
		scan();
	}
	
	Widget showForm() {
		return Padding(
			padding: EdgeInsets.all(20),
			child: Form(
				key: _formKey,
				child: TextFormField(
					maxLength: 30,
					maxLengthEnforced: true,
					onSaved: (value) => _scanNewName = value.trim(),
					decoration: InputDecoration(labelText: 'Give a name to the scanned text'.i18n),
				),
			)
		);
	}
	
	bool saveCode() {
		if (this.barcode.isEmpty) return false;
		final form = _formKey.currentState;
		if (form.validate()) form.save();
		if (_scanNewName == '') _scanNewName = null;
		
		Scan.add(_db, Scan(name: _scanNewName, data: this.barcode));
		Navigator.pop(context);
		return true;
	}
	
	Future scan() async {
		String barcode;
		try {
			var options = ScanOptions(
				strings: {
					"cancel": "Cancel".i18n,
					"flash_on": "Flash on".i18n,
					"flash_off": "Flash off".i18n,
				}
			);
			await BarcodeScanner.scan(options: options).then((value) {
				if (value.rawContent.isEmpty) {
					Navigator.pop(context);
				}
				barcode = value.rawContent;
				setState(() => this.barcode = barcode);
			});
		} on PlatformException catch (e) {
			if (e.code == BarcodeScanner.cameraAccessDenied) {
			  setState(() => this.barcode = 'you did not grant the camera permission!'.i18n);
			} else {
			  setState(() => this.barcode = 'Unknown error: $e');
			}
		}
	}
}