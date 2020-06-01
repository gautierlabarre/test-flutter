import 'dart:io' as io;

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personalimprover/helpers/InfoBar.dart';
import 'package:personalimprover/helpers/MyColorScheme.dart';
import 'package:personalimprover/helpers/utils.dart';
import 'package:personalimprover/models/Recording.dart';
import 'package:personalimprover/models/User.dart';
import 'package:personalimprover/screens/Login.dart';
import 'package:personalimprover/translations/Recording.i18n.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class RecordingDetail extends StatefulWidget {
	RecordingDetail({Key key, @required this.recording, this.autoPlay = false}) : super(key: key);
	
	final MyRecording recording;
	final bool autoPlay;
	
	@override
	_RecordingDetailState createState() => _RecordingDetailState();
}

class _RecordingDetailState extends State<RecordingDetail> {
	PanelController _pc = PanelController();
	final Firestore _db = Firestore.instance;
	final _formKey = GlobalKey<FormState>();
	
	// Player
	AudioPlayer audioPlayer = AudioPlayer();
	bool isPlaying = false;
	double currentPosition = 0;
	
	// File fetching from cloud and loading
	bool loadingCloud = false;
	bool fileExists = true;
	
	@override
	void initState() {
		super.initState();
		if (widget.autoPlay) WidgetsBinding.instance.addPostFrameCallback((_) => playRecording());
		WidgetsBinding.instance.addPostFrameCallback((_) => checkFileExists());
	}
	
	@override
	Widget build(BuildContext context) {
		return SafeArea(
			child: WillPopScope(
				onWillPop: () async {
					if (isPlaying) await audioPlayer.stop();
					return Future.value(true);
				},
				child: GestureDetector(
					onPanUpdate: (detail) => (detail.delta.dx > 10) ? Navigator.maybePop(context) : null,
					child: Scaffold(
						body: SlidingUpPanel(
							controller: _pc,
							panel: slidingPanel(),
							body: pageContent(),
							color: MyColorScheme.selectColor(context, 'secondaryHeaderColor'),
							maxHeight: 300,
						)
					)
				),
			)
		);
	}
	
	Widget pageContent() {
		String duration = transformStringDuration(widget.recording.duration);
		String size = sizeInKo(widget.recording.size);
		return Column(
			children: <Widget>[
				header(),
				Padding(
					padding: EdgeInsets.only(top: 40),
					child: Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						mainAxisSize: MainAxisSize.max,
						children: <Widget>[
							Padding(child: Text('Duration'.i18n), padding: EdgeInsets.only(left: 50)),
							Padding(child: Text(duration), padding: EdgeInsets.only(right: 50))
						],
					),
				),
				Padding(
					padding: EdgeInsets.only(top: 20),
					child: Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						mainAxisSize: MainAxisSize.max,
						children: <Widget>[
							Padding(child: Text('Size'.i18n), padding: EdgeInsets.only(left: 50)),
							Padding(child: Text("$size Ko"), padding: EdgeInsets.only(right: 50))
						],
					),
				),
				Padding(
					padding: EdgeInsets.only(top: 20),
					child: Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						mainAxisSize: MainAxisSize.max,
						children: <Widget>[
							Padding(child: Text("Creation date".i18n), padding: EdgeInsets.only(left: 50)),
							Padding(child: Text(widget.recording.creationDate.toString()), padding: EdgeInsets.only(right: 50))
						],
					),
				),
				Padding(
					padding: EdgeInsets.only(top: 20),
					child: Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						mainAxisSize: MainAxisSize.max,
						children: <Widget>[
							Padding(child: Text('Saved in the cloud'.i18n), padding: EdgeInsets.only(left: 50)),
							Padding(child: Text(widget.recording.url != '' ? "Yes".i18n : "No".i18n), padding: EdgeInsets.only(right: 50))
						],
					),
				),
				Padding(
					padding: EdgeInsets.only(top: 20),
					child: Column(
						children: <Widget>[
							Text('Description'.i18n),
							Text(widget.recording.description)
						],
					),
				)
			],
		);
	}
	
	Widget header() {
		return Padding(
			padding: EdgeInsets.only(top: 10),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				children: <Widget>[
					IconButton(
						icon: Icon(Icons.arrow_back),
						onPressed: () => Navigator.maybePop(context),
					),
					Text(widget.recording.name, style: TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis),
					RawMaterialButton(
						child: Icon(Icons.mode_edit, color: Colors.white),
						fillColor: Colors.green,
						shape: CircleBorder(),
						onPressed: () => editRecording(),
					)
				],
			),
		);
	}
	
	Widget slidingPanel() {
		Duration currentDuration = parseDuration(currentPosition.toString());
		String duration = transformStringDuration(widget.recording.duration);
		String readableCurrentPosition = transformStringDuration(currentDuration);
		return Column(
			children: <Widget>[
				Padding(
					padding: EdgeInsets.only(top: 20, bottom: 20),
					child: loadingCloud ? CircularProgressIndicator() : RawMaterialButton(
						child: isPlaying ? Icon(Icons.pause, color: Colors.white,) : Icon(Icons.play_arrow, color: Colors.white),
						fillColor: isPlaying ? Colors.orange : Colors.green,
						shape: CircleBorder(),
						onPressed: () => playRecording(),
					),
				),
				Slider(
					min: 0,
					max: double.parse(parseDuration(widget.recording.duration).inSeconds.toString()),
					value: currentPosition,
					activeColor: Colors.orange,
					inactiveColor: Colors.grey,
					onChanged: (value) => audioPlayer.seek(Duration(seconds: value.toInt())),
				),
				Padding(
					padding: EdgeInsets.fromLTRB(25, 10, 25, 20),
					child: Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: <Widget>[
							Text(readableCurrentPosition),
							Text(duration),
						],
					),
				),
				Padding(
					padding: EdgeInsets.fromLTRB(25, 20, 20, 0),
					child: fileExists ? Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: <Widget>[
							showDeleteButton(),
							showShareButton(), //TODO
							showCloudButton()
						],
					) : showDeleteButton()
				)
			],
		);
	}
	
	Future<void> playRecording() async {
		if (_pc.isAttached) await _pc.open();
		
		if (isPlaying) {
			await audioPlayer.pause();
			setState(() => isPlaying = false);
		} else {
			if (await io.File(widget.recording.path).exists()) {
				int result = await audioPlayer.play(widget.recording.path, isLocal: true);
				if (result == 1) setState(() => isPlaying = true);
			} else {
				(widget.recording.url != '') ? displayFlushbarRetrieve(true) : displayFlushbarRetrieve(false);
			}
		}
		
		// Listeners
		audioPlayer.onAudioPositionChanged.listen((Duration duration) {
			setState(() => currentPosition = double.parse(duration.inSeconds.toString()));
		});
		
		audioPlayer.onPlayerStateChanged.listen((AudioPlayerState audioState) {
			if (AudioPlayerState.COMPLETED == audioState) setState(() => isPlaying = false);
		});
	}
	
	Future<void> regenerateFile() async {
		if (await FlutterAudioRecorder.hasPermissions) {
			setState(() => loadingCloud = true);
			StorageReference storageReference = await FirebaseStorage.instance.getReferenceFromUrl(widget.recording.url.toString());
			io.Directory appDocDirectory;
			
			if (io.Platform.isIOS) {
				appDocDirectory = await getApplicationDocumentsDirectory();
			} else {
				appDocDirectory = await getExternalStorageDirectory();
			}
			
			// Recreating all the folders to avoid an error
			await io.Directory('${appDocDirectory.path}/files/').create(recursive: true);
			
			final File tempFile = LocalFileSystem().file(widget.recording.path);
			if (tempFile.existsSync()) await tempFile.delete();
			await tempFile.create();
			storageReference.writeToFile(tempFile);
			
			setState(() {
				fileExists = true;
				loadingCloud = false;
			});
			InfoBar(context).success(title: "File recovered".i18n, message: "You can now listen to it again".i18n);
		} else {
			InfoBar(context).warning(message: "You need to accept permissions".i18n);
		}
	}
	
	Future<void> removeFromCloud() async {
		await MyRecording.deleteFromCloud(widget.recording);
		setState(() => widget.recording.url = "");
		User.updateQuota(_db, widget.recording, 'remove');
		await MyRecording.update(_db, widget.recording);
	}
	
	Future<void> addToCloud() async {
		setState(() => loadingCloud = true);
		if (!User.checkQuota(widget.recording.size)) {
			if (connectedUser.isPro) {
				InfoBar(context).warning(message: "Your quota is exceeded".i18n);
			} else {
				InfoBar(context).warning(message: "Your quota is exceeded, upgrade your account to save on the cloud".i18n);
			}
			setState(() => loadingCloud = false);
			return null;
		}
		
		File file = LocalFileSystem().file(widget.recording.path);
		String url = await MyRecording.uploadRecording(file, widget.recording.creationDate + "__" + connectedUser.uid);
		
		// Increase size on the cloud !
		User.updateQuota(_db, widget.recording, 'add');
		
		setState(() {
			loadingCloud = false;
			widget.recording.url = url;
		});
		await MyRecording.update(_db, widget.recording);
	}
	
	void editRecording() {
		showDialog(context: context, builder: (context) =>
			AlertDialog(
				title: Text("Modify recording".i18n),
				content: Form(
					key: _formKey,
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: <Widget>[inputName(context), inputDescription()],
					),
				),
				actions: <Widget>[FlatButton(child: Text('Validate'.i18n), onPressed: () => submitForm())],
			),
		);
	}
	
	Widget inputName(context) {
		return Padding(
			padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
			child: TextFormField(
				maxLines: 1,
				maxLength: 30,
				maxLengthEnforced: true,
				controller: TextEditingController(text: widget.recording.name),
				keyboardType: TextInputType.text,
				autofocus: true,
				textInputAction: TextInputAction.next,
				onFieldSubmitted: (string) => FocusScope.of(context).nextFocus(),
				decoration: InputDecoration(hintText: "Enter the recording name".i18n),
				validator: (value) => value.isEmpty ? "The name cannot be empty".i18n : null,
				onSaved: (value) => widget.recording.name = value.trim(),
			),
		);
	}
	
	Widget inputDescription() {
		return Padding(
			padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
			child: TextFormField(
				maxLines: 5,
				maxLength: 300,
				maxLengthEnforced: true,
				controller: TextEditingController(text: widget.recording.description),
				keyboardType: TextInputType.multiline,
				autofocus: false,
				decoration: InputDecoration(hintText: 'Description'.i18n),
				onSaved: (value) => widget.recording.description = value.trim(),
			),
		);
	}
	
	void submitForm() {
		final form = _formKey.currentState;
		if (form.validate()) {
			form.save();
			setState(() {}); // Update the view
			MyRecording.update(_db, widget.recording);
			Navigator.pop(context);
		}
	}
	
	void displayFlushbarRetrieve(bool canBeRetrieved) {
		var message = (canBeRetrieved) ? "This file is on the cloud, so you can re-download it.".i18n : "This file is not in the cloud. It's lost.".i18n;
		var action = canBeRetrieved ? "Download".i18n : null;
		InfoBar(context).warning(title: "File not found".i18n, message: message, actionButtonText: action, callback: () {
			if (canBeRetrieved) {
				regenerateFile();
				Navigator.pop(context);
			}
		});
	}
	
	Widget showShareButton() {
		return Column(
			children: <Widget>[
				RawMaterialButton(
					child: Icon(Icons.share),
					splashColor: Colors.orange,
					padding: EdgeInsets.all(10),
					shape: CircleBorder(),
					onPressed: () => shareRecording()
				),
				Text('Share'.i18n)
			]
		);
	}
	
	Widget showDeleteButton() {
		return Column(
			children: <Widget>[
				RawMaterialButton(
					child: Icon(Icons.delete),
					splashColor: Colors.orange,
					padding: EdgeInsets.all(10),
					shape: CircleBorder(),
					onPressed: () {
						MyRecording.delete(_db, widget.recording);
						Navigator.maybePop(context);
					}
				),
				Text('Delete'.i18n)
			]
		);
	}
	
	Widget showCloudButton() {
		return IgnorePointer(
			ignoring: loadingCloud,
			child: Column(
				children: <Widget>[
					RawMaterialButton(
						child: widget.recording.url != '' ? Icon(Icons.cloud_off) : Icon(Icons.cloud_upload),
						splashColor: Colors.orange,
						padding: EdgeInsets.all(10),
						shape: CircleBorder(),
						onPressed: () => (widget.recording.url != '') ? removeFromCloud() : addToCloud()
					),
					Text(widget.recording.url != '' ? "Remove from cloud".i18n : "Add to the cloud".i18n),
				]
			),
		);
	}
	
	Future<void> checkFileExists() async => (await io.File(widget.recording.path).exists()) ? setState(() => fileExists = true) : setState(() => fileExists = false);
	
	Future<void> shareRecording() async {
		await FlutterShare.shareFile(
			title: "Recording %s, duration : %s".i18n.fill([widget.recording.name, transformStringDuration(widget.recording.duration)]),
			text: widget.recording.description,
			filePath: widget.recording.path,
		);
	}
}