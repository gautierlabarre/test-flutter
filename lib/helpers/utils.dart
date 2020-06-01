// Parse a String to Duration
import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'InfoBar.dart';

Duration parseDuration(String s) {
	int hours = 0;
	int minutes = 0;
	int micros;
	List<String> parts = s.split(':');
	if (parts.length > 2) {
		hours = int.parse(parts[parts.length - 3]);
	}
	if (parts.length > 1) {
		minutes = int.parse(parts[parts.length - 2]);
	}
	micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
	return Duration(hours: hours, minutes: minutes, microseconds: micros);
}

String transformStringDuration(recordDuration) =>
	recordDuration
		.toString()
		.split('.')
		.first
		.padLeft(8, "0");

String sizeInKo(recordSize) => (recordSize / 1000).toString().split('.')[0];
String sizeInMo(recordSize) => (recordSize / 1000000).toString().split('.')[0];

bool isKeyboardUp(context) {
	return !(MediaQuery
		.of(context)
		.viewInsets
		.bottom == 0.0);
}

Future<bool> confirmDismiss(context) {
	var completer = Completer<bool>();
	
	InfoBar(context).info(title: "Element supprimé", message: "Vous avez quelques secondes pour annuler", actionButtonText: "Annuler", callback: () {
		Navigator.pop(context, true);
		completer.complete(false);
		return true;
	});
	
	Timer.periodic(Duration(seconds: 3), (Timer t) {
		if (completer.isCompleted == false) {
		  return completer.complete(true);
		}
	});
	
	return completer.future;
}