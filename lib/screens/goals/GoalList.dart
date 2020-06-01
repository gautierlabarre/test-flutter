import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personalimprover/helpers/utils.dart';
import 'package:personalimprover/models/Goal.dart';
import 'package:personalimprover/screens/Login.dart';
import 'package:personalimprover/screens/goals/GoalDetail.dart';
import 'package:personalimprover/screens/shared/StackLineDecoration.dart';
import 'package:personalimprover/translations/Goal.i18n.dart';

class GoalList extends StatefulWidget {
	GoalList({Key key}) : super(key: key);
	
	@override
	_GoalListState createState() => _GoalListState();
}

class _GoalListState extends State<GoalList> {
	final _db = Firestore.instance;
	TextEditingController nameController = TextEditingController();
	bool isDone = false;
	
	@override
	Widget build(BuildContext context) => Container(child: Column(children: <Widget>[header(), listGoals()]));
	
	Widget header() {
		return Stack(
			children: <Widget>[
				StackLineDecoration(),
				StackLineDecoration().fillContainer(),
				Positioned(
					top: -10,
					left: -10,
					child: Padding(
						padding: EdgeInsets.all(25),
						child: Text('My goals'.i18n, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
					),
				),
				Positioned(
					right: 20,
					top: 10,
					child: Container(
						margin: EdgeInsets.only(top: 10),
						child: RawMaterialButton(
							child: Icon(Icons.add),
							onPressed: () => showAddGoal(context),
							textStyle: TextStyle(color: Colors.white),
							fillColor: Colors.green,
							padding: EdgeInsets.all(15),
							shape: CircleBorder(),
						)
					),
				),
				filters()
			],
		);
	}
	
	Widget filters() {
		return Positioned(
			bottom: -10,
			left: 20,
			child: Container(
				child: Row(
					key: Key('filters'),
					children: <Widget>[
						Padding(padding: EdgeInsets.only(left: 10), child: Text('Filter :'.i18n)),
						Padding(padding: EdgeInsets.only(left: 10),
							child: IconButton(
								color: !isDone ? Colors.blueGrey : null,
								icon: Icon(Icons.check),
								onPressed: () => setState(() => isDone = false),
							),
						),
						Padding(padding: EdgeInsets.only(right: 10),
							child: IconButton(
								color: isDone ? Colors.blueGrey : null,
								icon: Icon(Icons.done_outline, size: 18),
								onPressed: () => setState(() => isDone = true),
							),
						),
					],
				),
			),
		);
	}
	
	Widget listGoals() {
		return Padding(
			padding: EdgeInsets.only(top: 5),
			child: StreamBuilder(
				stream: Goal.getInstance(_db).where("userId", isEqualTo: connectedUser.uid).where("checked", isEqualTo: isDone).orderBy("creationDate", descending: true).limit(50).snapshots(),
				builder: (BuildContext context, AsyncSnapshot snapshot) {
					if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
					if (snapshot.hasData && snapshot.data.documents.length == 0) {
					  return Padding(padding: EdgeInsets.only(top: 100), child: Text('No data'.i18n));
					}
					return ListView.builder(
						shrinkWrap: true,
						itemCount: snapshot.data.documents.length,
						itemBuilder: (context, index) {
							Goal goal = Goal.fromDb(snapshot.data.documents[index].documentID, snapshot.data.documents[index]);
							return _buildList(context, goal);
						}
					);
				}
			)
		);
	}
	
	Widget _buildList(BuildContext context, Goal goal) {
		return Dismissible(
			key: Key(goal.key),
			background: Container(color: Colors.red),
			confirmDismiss: (DismissDirection direction) async => confirmDismiss(context),
			onDismissed: (direction) => Goal.delete(_db, goal),
			child: ListTile(
				leading: Icon(Icons.label_important),
				title: Text(goal.name, style: TextStyle(fontSize: 16.0), overflow: TextOverflow.ellipsis),
				subtitle: (connectedUser.condensedView) ? null : Container(
					child: Text("Created on : %s".i18n.fill([goal.creationDate]), style: TextStyle(fontSize: 12, color: Colors.grey)),
				),
				trailing: IconButton(
					icon: goal.checked ? Icon(Icons.done_outline, color: Colors.green) : Icon(Icons.check),
					onPressed: () => checkGoal(_db, goal),
				),
				onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GoalDetail(goal: goal))),
			)
		);
	}
	
	void checkGoal(db, Goal goal) {
		goal.checked = !goal.checked;
		Goal.update(db, goal);
	}
	
	void showAddGoal(BuildContext context) async {
		nameController.clear();
		await showDialog<String>(context: context, builder: (BuildContext context) =>
			AlertDialog(
				content: Row(
					children: <Widget>[
						Expanded(
							child: TextField(
								maxLines: 1,
								maxLength: 30,
								maxLengthEnforced: true,
								keyboardType: TextInputType.text,
								autofocus: true,
								decoration: InputDecoration(hintText: 'Add objective'.i18n),
								controller: nameController,
							))
					],
				),
				actions: <Widget>[
					FlatButton(child: Text('Cancel'.i18n), onPressed: () => Navigator.pop(context)),
					FlatButton(child: Text('Save'.i18n), onPressed: () {
						Goal.add(_db, Goal(name: nameController.text, checked: false));
						Navigator.pop(context);
					})
				],
			)
		);
	}
}