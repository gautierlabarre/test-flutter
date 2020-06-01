import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personalimprover/screens/shared/StackBackButton.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeFullScreen extends StatelessWidget {
	QRCodeFullScreen({Key key, this.data}): super(key: key);
	final String data;
	
	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			onPanUpdate: (detail) => (detail.delta.dx > 10) ? Navigator.pop(context) : null,
			child: Scaffold(
				body: SingleChildScrollView(
					child: Column(
						children: <Widget>[
							Stack(
								children: <Widget>[
									Row(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: <Widget>[
											StackBackButton(),
										]
									),
								],
							),
							Padding(
							  padding: const EdgeInsets.only(top: 50.0),
							  child: qrCode(context),
							)
						],
					),
			),
			),
		);
	}
	
	Widget qrCode(context) {
		return RepaintBoundary(
			child: QrImage(
				foregroundColor: Colors.black,
				backgroundColor: Colors.white,
				data: data,
				size: MediaQuery.of(context).size.width
			),
		);
	}
}
