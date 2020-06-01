import 'package:flutter/material.dart';

class StackTitle extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return Container();
	}
	
	Widget title(String name) {
		return Center(
			child: Padding(
				padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
				child: Text(name, style: TextStyle(fontSize: 20), overflow: TextOverflow.ellipsis),
			));
	}
}
