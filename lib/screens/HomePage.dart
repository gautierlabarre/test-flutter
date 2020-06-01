import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';
import 'package:flutter/material.dart';
import 'package:personalimprover/helpers/Authentication.dart';
import 'package:personalimprover/helpers/MyColorScheme.dart';
import 'package:personalimprover/screens/goals/GoalList.dart';
import 'package:personalimprover/screens/qrcode/ScanList.dart';
import 'package:personalimprover/screens/recording/RecordingList.dart';
import 'package:personalimprover/screens/settings/Settings.dart';
import 'package:personalimprover/translations/HomePage.i18n.dart';

class HomePage extends StatefulWidget {
	HomePage({Key key, this.auth}) : super(key: key);
	final BaseAuth auth;
	
	@override
	_HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
	int selectedPos = 0;
	double bottomNavBarHeight = 60;
	CircularBottomNavigationController _navigationController;
	
	@override
	void initState() {
		super.initState();
		_navigationController = CircularBottomNavigationController(selectedPos);
	}
	
	@override
	void dispose() {
		super.dispose();
		_navigationController.dispose();
	}
	
	@override
	Widget build(BuildContext context) {
		return SafeArea(
			child: Scaffold(
				body: Stack(
					children: <Widget>[
						bodyContainer(),
						Align(alignment: Alignment.bottomCenter, child: bottomNav())
					],
				),
			)
		);
	}
	
	Widget bodyContainer() {
		return Container(
			color: MyColorScheme.selectColor(context, 'backgroundColor'),
			child: selectScreen(selectedPos)
		);
	}
	
	Widget selectScreen(int pos) {
		if (pos == 0) {
			return RecordingList();
		} else if (pos == 1) {
			return GoalList();
		} else if (pos == 2) {
			return ScanList();
		} else if (pos == 3) {
			return Settings(auth: widget.auth);
		} else {
			return Center(child: Text('No item'.i18n));
		}
	}
	
	Widget bottomNav() {
		return CircularBottomNavigation(
			List.of([
				TabItem(Icons.keyboard_voice, "Audio recorder".i18n, MyColorScheme.selectColor(context, 'toggleableActiveColor')),
				TabItem(Icons.check_circle_outline, "Goals".i18n, MyColorScheme.selectColor(context, 'toggleableActiveColor')),
				TabItem(Icons.settings_overscan, "QR Code".i18n, MyColorScheme.selectColor(context, 'toggleableActiveColor')),
				TabItem(Icons.settings, "Settings".i18n, MyColorScheme.selectColor(context, 'toggleableActiveColor')),
			]),
			controller: _navigationController,
			barHeight: bottomNavBarHeight,
			circleStrokeWidth: 2,
			iconsSize: 24,
			barBackgroundColor: MyColorScheme.selectColor(context, 'secondaryHeaderColor'),
			animationDuration: Duration(milliseconds: 300),
			selectedIconColor: MyColorScheme.selectColor(context, 'buttonColor'),
			selectedCallback: (int selectedPos) => setState(() => this.selectedPos = selectedPos),
		);
	}
}