import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personalimprover/helpers/InfoBar.dart';
import 'package:personalimprover/helpers/MyColorScheme.dart';
import 'package:personalimprover/helpers/SlideLeftRoute.dart';
import 'package:personalimprover/models/Scan.dart';
import 'package:personalimprover/screens/qrcode/QRCodeFullScreen.dart';
import 'package:personalimprover/screens/shared/StackBackButton.dart';
import 'package:personalimprover/screens/shared/StackTitle.dart';
import 'package:personalimprover/screens/shared/clipping.dart';
import 'package:personalimprover/translations/QRCode.i18n.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ScanDetail extends StatefulWidget {
	final Scan scan;
	
	ScanDetail({this.scan, Key key}) : super(key: key);
	
	@override
	_ScanDetailState createState() => _ScanDetailState();
}

class _ScanDetailState extends State<ScanDetail> {
	PanelController _pc = PanelController();
	final Firestore _db = Firestore.instance;
	final formKey = GlobalKey<FormState>();
	GlobalKey globalKey = GlobalKey();
	
	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			onPanUpdate: (detail) => (detail.delta.dx > 10) ? Navigator.pop(context) : null,
			child: Scaffold(
				body: SlidingUpPanel(
					controller: _pc,
					minHeight: 230,
					maxHeight: 350,
					color: MyColorScheme.selectColor(context, 'secondaryHeaderColor'),
					panel: slidingPanel(),
					body: pageContent(),
				)
			),
		);
	}
	
	Widget pageContent() {
		return SingleChildScrollView(
			child: Stack(
				children: <Widget>[
					Clipping(),
					Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: <Widget>[
							Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: <Widget>[
									StackBackButton(),
									Padding(
										padding: EdgeInsets.only(top: 40),
										child: simplePopup()
									)
								],
							),
							StackTitle().title(widget.scan.name),
							scanContent(),
							Padding(padding: EdgeInsets.symmetric(vertical: 20)),
							scanInfo()
						]
					),
				],
			),
		);
	}
	
	Widget simplePopup() =>
		PopupMenuButton<int>(
			color: MyColorScheme.selectColor(context, 'secondaryHeaderColor'),
			onSelected: (value) {
				if (value == 1) {
					seeFullscreen();
				} else {
					Clipboard.setData(ClipboardData(text: widget.scan.data));
					InfoBar(context).info(message: 'Content copied to the clipboard'.i18n);
				}
			},
			itemBuilder: (context) =>
			[
				PopupMenuItem(
					value: 1,
					child: Text("Fullscreen".i18n),
				),
				PopupMenuItem(
					value: 2,
					child: Text("Copy content".i18n),
				),
			],
		);
	
	Widget scanContent() {
		return Padding(
			padding: EdgeInsets.fromLTRB(50, 20, 50, 0),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.start,
				crossAxisAlignment: CrossAxisAlignment.start,
				children: <Widget>[
					Container(padding: EdgeInsets.only(right: 10), child: Icon(Icons.format_quote)),
					scanDataContent()
				],
			)
		);
	}
	
	Widget slidingPanel() {
		return Column(
			children: <Widget>[
				gripLine(),
				Padding(padding: EdgeInsets.only(top: 10),),
				qrCode(),
				Padding(
					padding: EdgeInsets.fromLTRB(25, 20, 20, 0),
					child: Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: <Widget>[
							showDeleteButton(),
							showShareQR(),
							showEditButton()
						],
					)
				)
			],
		);
	}
	
	Widget gripLine() {
		return Container(
			width: 100,
			height: 3,
			margin: EdgeInsets.only(top: 10),
			decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: MyColorScheme.selectColor(context, 'cursorColor')),
		);
	}
	
	Widget qrCode() {
		return RepaintBoundary(
			key: globalKey,
			child: QrImage(
				foregroundColor: Colors.black,
				backgroundColor: Colors.white,
				data: widget.scan.data,
				size: 200
			),
		);
	}
	
	Widget scanDataContent() {
		return Flexible(
			child: Container(
				height: 100,
				padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
				decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.orange, width: 4.0))),
				child: Text(widget.scan.data)
			)
		);
	}
	
	Widget scanInfo() {
		return Column(
			children: <Widget>[
				Padding(
					padding: EdgeInsets.only(top: 40),
					child: Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						mainAxisSize: MainAxisSize.max,
						children: <Widget>[
							Padding(child: Text('Creation date'.i18n), padding: EdgeInsets.only(left: 50)),
							Padding(child: Text(widget.scan.creationDate), padding: EdgeInsets.only(right: 50))
						],
					),
				),
				Padding(
					padding: EdgeInsets.only(top: 20),
					child: Column(
						children: <Widget>[
							Text('Description'.i18n),
							Text(widget.scan.description)
						],
					),
				),
			]
		);
	}
	
	Widget showDeleteButton() {
		return Column(
			children: <Widget>[
				RawMaterialButton(
					child: Icon(Icons.delete),
					splashColor: Colors.orange,
					padding: EdgeInsets.all(10),
					shape: CircleBorder(),
					onPressed: () {
						Scan.delete(_db, widget.scan);
						Navigator.maybePop(context);
					}
				),
				Text('Delete'.i18n)
			]
		);
	}
	
	Widget showEditButton() {
		return Column(
			children: <Widget>[
				RawMaterialButton(
					child: Icon(Icons.edit),
					splashColor: Colors.orange,
					padding: EdgeInsets.all(10),
					shape: CircleBorder(),
					onPressed: () => editScan()
				),
				Text('Update'.i18n)
			]
		);
	}
	
	Widget showShareQR() {
		return Column(
			children: <Widget>[
				RawMaterialButton(
					child: Icon(Icons.share),
					splashColor: Colors.orange,
					padding: EdgeInsets.all(10),
					shape: CircleBorder(),
					onPressed: () => Scan.shareQR(globalKey, widget.scan.data)
				),
				Text('Share'.i18n)
			]
		);
	}
	
	void editScan() {
		showDialog(context: context, builder: (context) =>
			AlertDialog(
				title: Text("Update informations".i18n),
				content: Form(
					key: formKey,
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: <Widget>[inputName(context), inputDescription()],
					),
				),
				actions: <Widget>[FlatButton(child: Text('Validate'.i18n), onPressed: () => submitForm())],
			),
		);
	}
	
	Widget inputName(context) {
		return Padding(
			padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
			child: TextFormField(
				maxLines: 1,
				controller: TextEditingController(text: widget.scan.name),
				keyboardType: TextInputType.text,
				autofocus: true,
				maxLength: 30,
				maxLengthEnforced: true,
				textInputAction: TextInputAction.next,
				onFieldSubmitted: (string) => FocusScope.of(context).nextFocus(),
				decoration: InputDecoration(hintText: 'Name'.i18n),
				validator: (value) => value.isEmpty ? 'Name cannot be empty'.i18n : null,
				onSaved: (value) => widget.scan.name = value.trim(),
			),
		);
	}
	
	Widget inputDescription() {
		return Padding(
			padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
			child: TextFormField(
				maxLines: 5,
				maxLength: 300,
				maxLengthEnforced: true,
				controller: TextEditingController(text: widget.scan.description),
				keyboardType: TextInputType.multiline,
				autofocus: false,
				decoration: InputDecoration(hintText: 'Description'.i18n),
				onSaved: (value) => widget.scan.description = value.trim(),
			),
		);
	}
	
	void submitForm() {
		final form = formKey.currentState;
		if (form.validate()) {
			form.save();
			// Update the view
			setState(() {});
			Scan.update(_db, widget.scan);
			Navigator.pop(context);
		}
	}
	
	void seeFullscreen() {
		Navigator.push(context, SlideLeftRoute(page: QRCodeFullScreen(data:widget.scan.data)));
	}
}