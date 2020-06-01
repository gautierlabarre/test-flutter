import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseNotifications {
	FirebaseMessaging _firebaseMessaging;
	FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
	
	void setUpFirebase() {
		_firebaseMessaging = FirebaseMessaging();
		firebaseCloudMessagingListeners();
		
	}
	
	void firebaseCloudMessagingListeners() {
		if (Platform.isIOS) iOSPermission();
		
		_firebaseMessaging.getToken().then((token) {
			print(token);
		});
		
		_firebaseMessaging.configure(
			onMessage: (Map<String, dynamic> message) async {
				print('on message $message');
				
				//TODO Clean this to put in a service arguments : priority, body, title, callback, channel ?
				var initializationSettingsAndroid = AndroidInitializationSettings('launcher_icon');
				var initializationSettingsIOS = IOSInitializationSettings();
				var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
				flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
				await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: selectNotification);
				
				var androidPlatformChannelSpecifics = AndroidNotificationDetails(
					'firebase', 'firebase', 'firebase-notif',
					importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
				var iOSPlatformChannelSpecifics = IOSNotificationDetails();
				var platformChannelSpecifics = NotificationDetails(
					androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
				await flutterLocalNotificationsPlugin.show(
					0, message['notification']['title'], message['notification']['body'], platformChannelSpecifics,
					payload: 'item x');
			},
			onResume: (Map<String, dynamic> message) async {
				print('on resume $message');
			},
			onLaunch: (Map<String, dynamic> message) async {
				print('on launch $message');
			},
		);
	}
	
	void iOSPermission() {
		_firebaseMessaging.requestNotificationPermissions(
			IosNotificationSettings(sound: true, badge: true, alert: true));
		_firebaseMessaging.onIosSettingsRegistered
			.listen((IosNotificationSettings settings) {
			print("Settings registered: $settings");
		});
	}
	
	Future selectNotification(String payload) async {
		if (payload != null) {
			print('notification payload: ' + payload);
		}
	}
}