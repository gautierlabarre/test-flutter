import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:personalimprover/models/Goal.dart';
import 'package:personalimprover/models/Tag.dart';
import 'package:personalimprover/translations/Goal.i18n.dart';

import '../Login.dart';

class GoalTagModal extends StatefulWidget {
	final Goal goal;
	final VoidCallback callback;
	
	GoalTagModal({this.goal, this.callback});
	
	@override
	_GoalTagModal createState() => _GoalTagModal();
}

class _GoalTagModal extends State<GoalTagModal> {
	
	final _db = Firestore.instance;
	List<Tag> selectedTags = [];
	TextEditingController filter = TextEditingController();
	Stream searchQuery;
	
	@override
	void initState() {
		// TODO: implement initState
		super.initState();
		searchQuery = Tag.getInstance(_db).where("userId", isEqualTo: connectedUser.uid).limit(20).snapshots();
	}
	
	@override
	Widget build(BuildContext context) {
		return AlertDialog(
			title: Text("Select or add a new tag".i18n),
			content: Container(
				height: 400,
				width: 200,
				child: Column(
					children: <Widget>[
						inputName(context),
						Expanded(child: listTags())
					],
				)
			),
			actions: <Widget>[
				FlatButton(child: Text('Cancel'.i18n), onPressed: () => Navigator.pop(context)),
				FlatButton(child: Text('Save'.i18n), onPressed: () => updateTags())
			],
		);
	}
	
	Widget inputName(context) {
		return Padding(
			padding: EdgeInsets.all(0),
			child: TextFormField(
				maxLines: 1,
				controller: filter,
				keyboardType: TextInputType.text,
				autofocus: true,
				maxLength: 30,
				maxLengthEnforced: true,
				textInputAction: TextInputAction.done,
				onFieldSubmitted: (string) => addNewTag(),
				decoration: InputDecoration(hintText: 'Name'.i18n),
			),
		);
	}
	
	Widget listTags() {
		return Padding(
			padding: EdgeInsets.only(top: 5),
			child: StreamBuilder(
				stream: searchQuery,
				builder: (BuildContext context, AsyncSnapshot snapshot) {
					if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
					if (snapshot.hasData && snapshot.data.documents.length == 0) {
						return
							Padding(
								padding: EdgeInsets.only(top: 0),
								child: Column(
									children: <Widget>[
										filter.text != null ? Text('No result'.i18n) : Text('No data'.i18n),
										filter.text != null ? RaisedButton(
											child: Text('Ajouter'),
											onPressed: () {
												addNewTag();
											},
										
										) : Container()
									],
								));
					}
					return ListView.builder(
						shrinkWrap: true,
						itemCount: snapshot.data.documents.length,
						itemBuilder: (context, index) {
							Tag tag = Tag.fromDb(snapshot.data.documents[index].documentID, snapshot.data.documents[index]);
							ImprovedTag improvedTag = ImprovedTag(name: tag.name, userId: tag.userId, selected: false);
							if (widget.goal.tags != null && widget.goal.tags.isNotEmpty) {
								widget.goal.tags.forEach((item) {
									if (item.isEmpty) return true;
									if (item['name'] == tag.name) {
										improvedTag.selected = true;
										selectedTags.add(tag);
									}
									return true;
								});
							}
							return _buildList(improvedTag, tag.key, index);
						}
					);
				}
			)
		);
	}
	
	Widget _buildList(ImprovedTag tag, String tagId, int index) {
		return Dismissible(
			key: Key(tagId),
			background: Container(color: Colors.red),
			onDismissed: (direction) => deleteTag(tagId, tag),
			child: ListTile(
				title: Text(tag.name, style: TextStyle(fontSize: 16.0), overflow: TextOverflow.ellipsis),
				trailing: IconButton(
					icon: tag.selected ? Icon(Icons.remove_circle, color: Colors.red) : Icon(Icons.done_outline, color: Colors.green),
					onPressed: () => toggleSelect(tag, index),
				)
			)
		);
	}
	
	toggleSelect(ImprovedTag tag, index) {
		setState(() {
			if (tag.selected) {
				widget.goal.tags.removeWhere((item) => item['name'] == tag.name);
			} else {
				
				widget.goal.tags.add(tag.toJson());
			}
			Goal.update(_db, widget.goal);
		});
	}
	
	// Select all Tags with selected == true and replace goal.tags
	updateTags() {
		widget.callback();
		Navigator.pop(context);
	}
	
	void addNewTag() {
		if (filter.text.length > 2) {
			setState(() {
				Tag newTag = Tag(name: filter.text, userId: connectedUser.uid);
				Tag.add(_db, newTag);
				selectedTags.add(newTag);
				
				widget.goal.tags.add(newTag.toJson());
				
				Goal.update(_db, widget.goal);
				
				filter = TextEditingController(text: '');
				searchQuery = Tag.getInstance(_db).where("userId", isEqualTo: connectedUser.uid).limit(20).snapshots();
			});
		}
	}

  deleteTag(tagId, Tag tag) {
	  Tag.delete(_db, tagId);
	  // if selected.
	  widget.goal.tags.removeWhere((item) => item['name'] == tag.name);
	  Goal.update(_db, widget.goal);
	
  }
}