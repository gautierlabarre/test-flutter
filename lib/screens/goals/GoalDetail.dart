import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personalimprover/models/Goal.dart';
import 'package:personalimprover/models/Tag.dart';
import 'package:personalimprover/screens/goals/GoalTagModal.dart';
import 'package:personalimprover/screens/shared/StackBackButton.dart';
import 'package:personalimprover/screens/shared/StackTitle.dart';
import 'package:personalimprover/screens/shared/clipping.dart';
import 'package:personalimprover/translations/Goal.i18n.dart';

class GoalDetail extends StatefulWidget {
	GoalDetail({this.goal, Key key}) : super(key: key);
	
	final Goal goal;
	
	@override
	_GoalDetailState createState() => _GoalDetailState();
}

class _GoalDetailState extends State<GoalDetail> {
	final _db = Firestore.instance;
	final _formKey = GlobalKey<FormState>();
	
	@override
	Widget build(BuildContext context) {
		// Put somewhere else ?
		if (widget.goal.tags == null) {
			widget.goal.tags = [];
		}
		return GestureDetector(
			onPanUpdate: (detail) => (detail.delta.dx > 10) ? Navigator.maybePop(context) : null,
			child: Scaffold(
				body: SingleChildScrollView(
					child: Stack(
						children: <Widget>[
							Clipping(),
							Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: <Widget>[
									StackBackButton(),
									StackTitle().title(widget.goal.name),
									pageContent(),
								]
							),
						]
					),
				),
				bottomNavigationBar: bottomBar(),
				floatingActionButton: floatingButton(),
				floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
			)
		);
	}
	
	Widget pageContent() {
		return Column(
			children: <Widget>[
				Padding(
					padding: EdgeInsets.only(top: 40),
					child: Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						mainAxisSize: MainAxisSize.max,
						children: <Widget>[
							Padding(child: Text("Created on".i18n), padding: EdgeInsets.only(left: 50)),
							Padding(child: Text(widget.goal.creationDate), padding: EdgeInsets.only(right: 50))
						],
					),
				),
//TODO
//				Padding(
//					padding: EdgeInsets.only(top: 20),
//					child: Row(
//						mainAxisAlignment: MainAxisAlignment.spaceBetween,
//						mainAxisSize: MainAxisSize.max,
//						children: <Widget>[
//							Padding(child: Text('Deadline date'.i18n), padding: EdgeInsets.only(left: 50)),
//							Padding(child: Text("none".i18n), padding: EdgeInsets.only(right: 50))
//						],
//					),
//				),
				Padding(
					padding: EdgeInsets.only(top: 0),
					child: Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						mainAxisSize: MainAxisSize.max,
						children: <Widget>[
							Padding(child: Text("Tags".i18n), padding: EdgeInsets.only(left: 50)),
							tagList()
						],
					),
				),
				Padding(
					padding: EdgeInsets.only(top: 20),
					child: Column(
						children: <Widget>[
							Text('Description'.i18n),
							Text(widget.goal.description)
						],
					),
				),
			]
		);
	}
	
	void refreshTags() => setState(() {});
	
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
						child: IconButton(
							icon: Icon(Icons.edit),
							onPressed: () => editGoal()
						),
					),
					Padding(
						padding: EdgeInsets.only(right: 50),
						child: IconButton(
							icon: Icon(Icons.delete),
							onPressed: () {
								Goal.delete(_db, widget.goal);
								//TODO Create a modal to check if it's really intended
								Navigator.pop(context);
							}
						),
					)
				],
			),
		);
	}
	
	Widget floatingButton() {
		return FloatingActionButton(
			splashColor: Colors.blue,
			backgroundColor: widget.goal.checked ? Colors.deepOrangeAccent : Colors.green,
			onPressed: () => toggleChecked(),
			child: widget.goal.checked ? Icon(Icons.clear, color: Colors.white,) : Icon(Icons.done_outline, color: Colors.white),
		);
	}
	
	
	void editGoal() {
		showDialog(context: context, builder: (context) =>
			AlertDialog(
				title: Text("Update goal".i18n),
				content: Form(
					key: _formKey,
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: <Widget>[
							inputName(context),
							inputDescription()
						],
					),
				),
				actions: <Widget>[
					FlatButton(child: Text('Validate'.i18n), onPressed: () => submitForm()),
				],
			),
		);
	}
	
	Widget inputName(context) {
		return Padding(
			padding: EdgeInsets.all(0),
			child: TextFormField(
				maxLines: 1,
				controller: TextEditingController(text: widget.goal.name),
				keyboardType: TextInputType.text,
				autofocus: true,
				maxLength: 30,
				maxLengthEnforced: true,
				textInputAction: TextInputAction.next,
				onFieldSubmitted: (string) => FocusScope.of(context).nextFocus(),
				decoration: InputDecoration(hintText: 'Name'.i18n),
				validator: (value) => value.isEmpty ? "The name can't be empty".i18n : null,
				onSaved: (value) => widget.goal.name = value.trim(),
			),
		);
	}
	
	Widget inputDescription() {
		return Padding(
			padding: EdgeInsets.only(top: 10),
			child: TextFormField(
				maxLines: 5,
				controller: TextEditingController(text: widget.goal.description),
				keyboardType: TextInputType.multiline,
				autofocus: false,
				maxLength: 300,
				maxLengthEnforced: true,
				decoration: InputDecoration(hintText: 'Description'.i18n),
				onSaved: (value) => widget.goal.description = value.trim(),
			),
		);
	}
	
	void submitForm() {
		final form = _formKey.currentState;
		if (form.validate()) {
			form.save();
			// Update the view
			setState(() {});
			Goal.update(_db, widget.goal);
			Navigator.pop(context);
		}
	}
	
	void toggleChecked() {
		setState(() => widget.goal.checked = !widget.goal.checked);
		Goal.update(_db, widget.goal);
	}
	
	void showTagModal() async {
		await showDialog<String>(context: context, builder: (BuildContext context) => GoalTagModal(callback: refreshTags, goal: widget.goal));
	}
	
	Widget tagList() {
		return Padding(
			padding: EdgeInsets.only(right: 50),
			child: Container(
				height: 70,
				width: 200,
				child: (widget.goal.tags != null && widget.goal.tags.isNotEmpty) ?
				ListView.builder(
					scrollDirection: Axis.horizontal,
					itemCount: widget.goal.tags.length,
					itemBuilder: (context, index) {
						Tag tag = Tag.fromJson(widget.goal.tags[index]);
						if (index == 0) {
							return Row(
								children: <Widget>[
									addTagButton(),
									chipTag(tag),
								],
							);
						}
						return chipTag(tag);
					},
				) : addTagButton(),
			),
		);
	}
	
	Widget addTagButton() => InkWell(child: Chip(label: Icon(Icons.add)), onTap: () => showTagModal());
	
	Widget chipTag(tag) => Padding(padding: const EdgeInsets.only(left: 5), child: Chip(label: Text(tag.name)));
}
