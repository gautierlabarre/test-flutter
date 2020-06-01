import 'package:flutter/material.dart';

class StackLineDecoration extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return Positioned.fill(
			bottom: 30,
			top: -80.0,
			right: -320,
			child: Container(
				decoration: BoxDecoration(
					shape: BoxShape.rectangle,
					border: Border(
						bottom: BorderSide(width: 3, color: Colors.blueGrey),
					)
				),
			),
		);
	}
	
	Widget fillContainer() => Container(height: 80);
}
