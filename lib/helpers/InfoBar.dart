import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InfoBar {
	BuildContext context;
	
	InfoBar(this.context);
	
	void info({String title, String message, String position, String actionButtonText, callback}) {
		Flushbar(
			icon: Icon(Icons.info_outline),
			title: title,
			message: message,
			flushbarPosition: checkPosition(position),
			isDismissible: true,
			flushbarStyle: FlushbarStyle.FLOATING,
			margin: EdgeInsets.fromLTRB(8, 0, 8, 20),
			animationDuration: Duration(milliseconds: 750),
			duration: Duration(milliseconds: 2800),
			mainButton: (actionButtonText != null) ? FlatButton(
				child: Text(actionButtonText),
				onPressed: () {
					callback();
				}
			) : null
		)
			..show(context);
	}
	
	void warning({String title, String message, String position, String actionButtonText, callback}) {
		Flushbar(
			icon: Icon(Icons.warning),
			title: title,
			message: message,
			flushbarPosition: checkPosition(position),
			isDismissible: false,
			borderColor: Colors.red,
			backgroundColor: Color(0xFF851f00),
			flushbarStyle: FlushbarStyle.FLOATING,
			margin: EdgeInsets.fromLTRB(8, 0, 8, 20),
			animationDuration: Duration(milliseconds: 400),
			duration: Duration(seconds: 4),
			mainButton: (actionButtonText != null) ? FlatButton(
				child: Text(actionButtonText),
				onPressed: () {
					callback();
				}
			) : null
		)
			..show(context);
	}
	
	void success({String title, String message, String position, String actionButtonText, callback}) {
		Flushbar(
			icon: Icon(Icons.check_circle_outline),
			title: title,
			message: message,
			flushbarStyle: FlushbarStyle.FLOATING,
			backgroundColor: Color(0xFF014f0a),
			margin: EdgeInsets.fromLTRB(8, 0, 8, 20),
			flushbarPosition: checkPosition(position),
			isDismissible: true,
			animationDuration: Duration(milliseconds: 750),
			duration: Duration(seconds: 2),
			mainButton: (actionButtonText != null) ? FlatButton(
				child: Text(actionButtonText),
				onPressed: () {
					callback();
				}
			) : null
		)
			..show(context);
	}
	
	FlushbarPosition checkPosition(String position) {
		FlushbarPosition flushbarPosition = FlushbarPosition.BOTTOM;
		
		if (position == 'TOP') {
			flushbarPosition = FlushbarPosition.TOP;
		}
		
		return flushbarPosition;
	}
}