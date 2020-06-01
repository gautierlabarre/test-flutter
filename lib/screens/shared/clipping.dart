import 'package:flutter/material.dart';
import 'package:personalimprover/helpers/Clipping.dart';
import 'package:personalimprover/helpers/MyColorScheme.dart';

class Clipping extends StatelessWidget {
	final Color color;
	Clipping({this.color});
	
	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.only(bottom: 30.0),
			child: ClipPath(
				clipper: ClippingClass(),
				child: Container(
					height: 130.0,
					decoration: BoxDecoration(color: (color != null) ? color : MyColorScheme.selectColor(context, 'primaryColor')),
				),
			),
		);
	}
}
