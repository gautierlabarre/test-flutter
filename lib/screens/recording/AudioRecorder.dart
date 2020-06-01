import 'dart:async';
import 'dart:io' as io;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:personalimprover/helpers/InfoBar.dart';
import 'package:personalimprover/helpers/MyColorScheme.dart';
import 'package:personalimprover/helpers/utils.dart';
import 'package:personalimprover/models/Recording.dart';
import 'package:personalimprover/models/User.dart';
import 'package:personalimprover/screens/Login.dart';
import 'package:personalimprover/screens/shared/StackBackButton.dart';
import 'package:personalimprover/screens/shared/clipping.dart';
import 'package:personalimprover/translations/Recording.i18n.dart';
import 'package:wakelock/wakelock.dart';

class AudioRecorder extends StatefulWidget {
	AudioRecorder({this.start = true, Key key}) : super(key: key);
	
	final bool start;
	
	@override
	_AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
	FlutterAudioRecorder _recorder;
	Recording recordingInfo; // Get all info
	RecordingStatus recordingStatus = RecordingStatus.Unset;
	bool saveInCloud = false;
	String _recordingNewName = '';
	final _formKey = GlobalKey<FormState>();
	final Firestore _db = Firestore.instance;
	bool isMobile = false;
	StreamSubscription subscription;
	
	@override
	void initState() {
		super.initState();
		initRecorder();
		
		if (connectedUser.wifiUpload) checkConnectivity();
		
		Wakelock.enable(); // Prevent screen for turning off
	}
	
	@override
	void dispose() {
		super.dispose();
		if (subscription != null) {
			subscription.cancel();
		}
		Wakelock.disable(); // We leave the recording, the screen may turn off now.
	}
	
	@override
	Widget build(BuildContext context) {
		return WillPopScope(
			onWillPop: _onWillPop,
			child: GestureDetector(
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
										Padding(
											padding: EdgeInsets.only(top: (isKeyboardUp(context)) ? 0 : 40),
											child: recordingStatus != RecordingStatus.Initialized ? showRecordingProcess() : Center(child: Text("Loading...".i18n)),
										)
									]
								),
							]
						),
					),
					bottomNavigationBar: bottomBar(),
					floatingActionButton: floatingButton(),
					floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
				)
			),
		);
	}
	
	Widget showRecordingProcess() {
		return Column(
			children: <Widget>[
				Padding(padding: EdgeInsets.symmetric(vertical: (isKeyboardUp(context)) ? 15 : 20)),
				Text('Recording in progress...'.i18n, style: TextStyle(fontSize: 20),),
				Padding(padding: EdgeInsets.symmetric(vertical: (isKeyboardUp(context)) ? 10 : 20)),
				clockRecording(),
				Padding(padding: EdgeInsets.symmetric(vertical: (isKeyboardUp(context)) ? 10 : 20)),
				inputName(),
				Padding(padding: EdgeInsets.symmetric(vertical: (isKeyboardUp(context)) ? 10 : 20)),
				toggleCloud(),
				wifiProtectionMessage(),
			],
		);
	}
	
	Widget clockRecording() {
		return Container(
			height: 40,
			color: MyColorScheme.selectColor(context, 'primaryColor'),
			child: Center(child: Text(transformStringDuration(recordingInfo?.duration), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500))),
		);
	}
	
	Widget inputName() {
		return Padding(
			padding: EdgeInsets.all(20),
			child: Form(
				key: _formKey,
				child: TextFormField(
					maxLength: 30,
					maxLengthEnforced: true,
					onSaved: (value) => _recordingNewName = value.trim(),
					decoration: InputDecoration(labelText: 'Enter the recording name'.i18n),
				),
			)
		);
	}
	
	Widget toggleCloud() {
		return ListTile(
			leading: saveInCloud ? Icon(Icons.cloud_upload) : Icon(Icons.cloud_off),
			title: Text('Save in the cloud'.i18n),
			subtitle: Text("Enable/Disable cloud backup".i18n),
			trailing: Switch(
				value: saveInCloud,
				activeColor: Colors.green,
				inactiveTrackColor: Colors.grey,
				onChanged: (bool value) => saveInCloud = !saveInCloud,
			),
		);
	}
	
	Widget wifiProtectionMessage() {
		return isMobile ? Padding(
			padding: EdgeInsets.fromLTRB(50, 20, 50, 0),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.center,
				crossAxisAlignment: CrossAxisAlignment.start,
				children: <Widget>[
					Icon(Icons.signal_wifi_off),
					Container(color: Colors.orange, height: 50, width: 4, margin: EdgeInsets.fromLTRB(15, 0, 15, 0)),
					Flexible(child: Text("Wifi disabled, the recording will not be saved in the cloud".i18n))
				],
			)
		) : Container();
	}
	
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
							icon: (recordingStatus == RecordingStatus.Paused) ? Icon(Icons.play_arrow) : Icon(Icons.pause),
							onPressed: () => (recordingStatus == RecordingStatus.Paused) ? resumeRecording() : pauseRecording(),
						),
					),
					Padding(
						padding: EdgeInsets.only(right: 50),
						child: IconButton(icon: Icon(Icons.stop), onPressed: () => stopRecording()),
					)
				],
			),
		);
	}
	
	Widget floatingButton() {
		return FloatingActionButton(
			splashColor: Colors.blue,
			backgroundColor: Colors.green,
			onPressed: () => saveRecording(),
			child: Icon(Icons.save, color: Colors.white,),
		);
	}
	
	Future<void> initRecorder() async {
		try {
			if (await FlutterAudioRecorder.hasPermissions) {
				if (connectedUser.autoUpload) setState(() => saveInCloud = true);
				
				String customPath = '/audio_recording_';
				io.Directory appDocDirectory;
				if (io.Platform.isIOS) {
					appDocDirectory = await getApplicationDocumentsDirectory();
				} else {
					appDocDirectory = await getExternalStorageDirectory();
				}
				
				customPath = appDocDirectory.path + customPath + DateTime
					.now()
					.millisecondsSinceEpoch
					.toString();
				
				var format = AudioFormat.AAC;
				var sampleRate = 16000;
				if (connectedUser.audioQuality) {
					format = AudioFormat.WAV;
					sampleRate = 22000;
				}
				_recorder = FlutterAudioRecorder(customPath, audioFormat: format, sampleRate: sampleRate);
				
				await _recorder.initialized;
				var current = await _recorder.current(channel: 0);
				
				if (widget.start) {
					WidgetsBinding.instance.addPostFrameCallback((_) => startRecording());
				}
				
				setState(() {
					recordingInfo = current;
					recordingStatus = current.status;
				});
			} else {
				InfoBar(context).warning(message: "You need to accept permissions".i18n);
			}
		} catch (e) {
			print(e);
		}
	}
	
	Future<void> startRecording() async {
		try {
			await _recorder.start();
			var recording = await _recorder.current(channel: 0);
			
			setState(() => recordingInfo = recording);
			
			Timer.periodic(Duration(milliseconds: 50), (Timer t) async {
				if (recordingStatus == RecordingStatus.Stopped) t.cancel();
				
				var current = await _recorder.current(channel: 0);
				setState(() {
					recordingInfo = current;
					recordingStatus = recordingInfo.status;
				});
			});
		} catch (e) {
			print(e);
		}
	}
	
	Future<void> stopRecording() async {
		await _recorder.stop();
		setState(() => recordingStatus = recordingInfo.status);
	}
	
	Future<void> resumeRecording() async => await _recorder.resume();
	
	Future<void> pauseRecording() async => await _recorder.pause();
	
	Future<void> saveRecording() async {
		DateTime now = DateTime.now();
		String currentDate = DateFormat('dd-MM-yyyy HH:mm:ss').format(now);
		var result = await _recorder.stop();
		final form = _formKey.currentState;
		
		if (form.validate()) form.save();
		if (_recordingNewName == '') _recordingNewName = null;
		
		showLoadingModal();
		
		File file = LocalFileSystem().file(result.path);
		
		String url = '';
		int size = await file.length();
		
		if (connectedUser.autoUpload) {
			// We don't save on the cloud : quota is exceeded.
			if (!User.checkQuota(size)) {
				saveInCloud = false;
			}
			
			if (saveInCloud) {
				url = await MyRecording.uploadRecording(file, currentDate + '__' + connectedUser.uid);
				connectedUser.audioSize = connectedUser.audioSize + size;
				User.update(_db, {'audioSize': connectedUser.audioSize});
			}
		}
		
		
		await _saveToDB(_recordingNewName, result.path, currentDate, url, result.duration.toString(), size);
		
		setState(() {
			recordingInfo = result;
			recordingStatus = recordingInfo.status;
		});
		
		// We close the modal and go back a screen.
		Navigator.of(context).popUntil((route) => route.isFirst);
		
		if (!User.checkQuota(size) && connectedUser.autoUpload) {
			InfoBar(context).success(message: "Recording saved but not on the cloud, your cloud size is reached".i18n, position: 'TOP');
		} else {
			InfoBar(context).success(message: "Recording saved".i18n, position: 'TOP');
		}
	}
	
	Future<void> _saveToDB(String name, String path, String creationDate, String url, String duration, int size) async {
		MyRecording.add(_db, MyRecording(
			name: name,
			path: path,
			creationDate: creationDate,
			duration: duration,
			size: size,
			url: url)
		);
	}
	
	Future<bool> _onWillPop() {
		if (recordingStatus == RecordingStatus.Paused || recordingStatus == RecordingStatus.Recording) {
			return showDialog(context: context, builder: (context) =>
				AlertDialog(
					title: Text("Unfinished".i18n),
					content: Text("You want to exit ? The recording will be lost".i18n),
					actions: <Widget>[
						FlatButton(child: Text('No'.i18n), onPressed: () => Navigator.of(context).pop(false)),
						FlatButton(child: Text('Yes'.i18n), onPressed: () {
							stopRecording(); // We clean the recording before leaving
							Navigator.of(context).pop(true);
						}),
					],
				),
			) ?? false;
		}
		
		return Future.value(true);
	}
	
	Future<void> checkConnectivity() async {
		if (connectedUser.autoUpload) {
			var connectivityResult = await (Connectivity().checkConnectivity());
			if (connectivityResult == ConnectivityResult.mobile) {
				saveInCloud = false;
				isMobile = true;
			}
			
			subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
				if (result == ConnectivityResult.mobile) {
					saveInCloud = false;
					isMobile = true;
				} else {
					isMobile = false;
					saveInCloud = true;
				}
			});
		}
	}
	
	void showLoadingModal() {
		showDialog(context: context, builder: (context) =>
			AlertDialog(
				title: Text('Saving...'.i18n),
				content: Column(
					mainAxisSize: MainAxisSize.min,
					children: <Widget>[Center(child: CircularProgressIndicator())])
			),
		);
	}
}