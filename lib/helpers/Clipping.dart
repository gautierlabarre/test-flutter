import 'dart:ui';

import 'package:flutter/cupertino.dart';

class ClippingClass extends CustomClipper<Path> {
	@override
	Path getClip(Size size) {
		var path = Path();
		path.lineTo(300.0, size.height - 180);
		path.quadraticBezierTo(
			size.width / 100,
			size.height,
			size.width / 100,
			size.height,
		);
		path.quadraticBezierTo(
			size.width - (size.width / 1),
			size.height,
			size.width,
			size.height - 80,
		);
		path.lineTo(size.width, 0.0);
		path.close();
		return path;
	}
	
	@override
	bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class ClippingClass2 extends CustomClipper<Path> {
	@override
	Path getClip(Size size) {
		var path = Path();
		path.lineTo(0.0, size.height - 80);
		path.quadraticBezierTo(
			size.width / 4,
			size.height,
			size.width / 2,
			size.height,
		);
		path.quadraticBezierTo(
			size.width - (size.width / 4),
			size.height,
			size.width,
			size.height - 80,
		);
		path.lineTo(size.width, 0.0);
		path.close();
		return path;
	}
	
	@override
	bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}