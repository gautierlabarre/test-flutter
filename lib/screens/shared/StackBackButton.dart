import 'package:flutter/material.dart';

class StackBackButton extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: EdgeInsets.only(top: 40),
			child: IconButton(
				icon: Icon(Icons.arrow_back),
				onPressed: () => Navigator.maybePop(context),
			),
		);
	}
}
