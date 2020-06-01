import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:personalimprover/models/Goal.dart';
import 'package:personalimprover/screens/goals/GoalDetail.dart';
import 'package:personalimprover/screens/goals/GoalList.dart';
import 'package:intl/intl.dart';

import 'Mocks.dart';

void main() {
	NavigatorObserver mockObserver;
	DateTime now = DateTime.now();
	
	Goal mockGoal = Goal(name: 'goalTest',
		description: 'fake description',
		userId: 'sdf54gsd54fghsdf54',
		checked: false,
		creationDate: DateFormat('dd-MM-yyyy HH:mm:ss').format(now),);
	var appMockList = MediaQuery(data:  MediaQueryData(), child: MaterialApp(home: Scaffold(body: GoalList())));
	var appMockDetail = MediaQuery(data:  MediaQueryData(), child:  MaterialApp(home: Scaffold(body: GoalDetail(goal: mockGoal))));


	setUp(() => mockObserver = MockNavigatorObserver());
	
	Future _buildListPage(WidgetTester tester) async {
		//TODO Fix container with HomePage(auth: mock) when cloud_firestore issue is resolved with another mock
		await tester.pumpWidget(MaterialApp(home: Container(), navigatorObservers: [mockObserver]));
	}
	// -------------------
	// -- Goal List
	// -------------------
	testWidgets('Check Screen GoalList widgets', (WidgetTester tester) async {
		await tester.pumpWidget(appMockList);
		expect(find.text('My goals'), findsOneWidget);
		expect(find.byKey(Key('filters')), findsOneWidget);
		expect(find.byType(RawMaterialButton), findsOneWidget);
	});
	
	testWidgets('Click on Add goal shows a modal', (WidgetTester tester) async {
		await tester.pumpWidget(appMockList);
		await tester.tap(find.byType(RawMaterialButton));
		await tester.pump();
		expect(find.byType(AlertDialog), findsOneWidget);
		expect(find.text('Add objective'), findsOneWidget);
		expect(find.byType(FlatButton), findsNWidgets(2));
		//TODO Go beyond that and create the damn thing
	});
	
	
	// -------------------
	// -- Goal Detail
	// -------------------
	testWidgets('Check screen GoalDetail widgets', (WidgetTester tester) async {
		await tester.pumpWidget(appMockDetail);
		expect(find.text(mockGoal.name), findsOneWidget);
		expect(find.text(mockGoal.creationDate), findsOneWidget);
		expect(find.text(mockGoal.description), findsOneWidget);
		expect(find.byType(FloatingActionButton), findsOneWidget);
		// Check tags
		expect(find.widgetWithIcon(FloatingActionButton, Icons.done_outline), findsOneWidget);
	});
	
	testWidgets('Update check attribute from GoalDetail', (WidgetTester tester) async {
		await tester.pumpWidget(appMockDetail);
		Finder checkButton = find.byType(FloatingActionButton);
		
		await tester.tap(checkButton);
		await tester.pump();
		
		expect(find.widgetWithIcon(FloatingActionButton, Icons.clear), findsOneWidget);
		
		await tester.tap(checkButton);
		await tester.pump();
		
		expect(find.widgetWithIcon(FloatingActionButton, Icons.done_outline), findsOneWidget);
	});
	
	testWidgets('Update name and description from GoalDetail', (WidgetTester tester) async {
		await tester.pumpWidget(appMockDetail);
		String newTitle = "New Title";
		String newDesc = "New description";
		
		Finder editButton = find.widgetWithIcon(IconButton, Icons.edit);
		await tester.tap(editButton);
		await tester.pump();
		
		// Modal appears.
		expect(find.text('Update goal'), findsOneWidget);
		
		// We fill with empty text to check it does not validate empty name
		await tester.enterText(find.widgetWithText(TextFormField, 'Name'), '');
		await tester.enterText(find.widgetWithText(TextFormField, 'Description'), '');
		await tester.tap(find.byType(FlatButton));
		await tester.pump();
		expect(find.text("The name can't be empty"), findsOneWidget);
		
		// We check with good name that it changes the value on the page
		await tester.enterText(find.widgetWithText(TextFormField, 'Name'), newTitle);
		await tester.enterText(find.widgetWithText(TextFormField, 'Description'), newDesc);
		await tester.tap(find.byType(FlatButton));
		await tester.pump();
		expect(find.text(newTitle), findsOneWidget);
		expect(find.text(newDesc), findsOneWidget);
		
		// We open the modal again to check the name is the right one here too
		await tester.tap(editButton);
		await tester.pump();
		expect(find.text('Update goal'), findsOneWidget);
		expect(find.widgetWithText(TextFormField, newTitle), findsOneWidget);
	});
	
	testWidgets('Delete a goal from GoalDetail', (WidgetTester tester) async {
		await tester.pumpWidget(appMockDetail);
		
		Finder deleteButton = find.widgetWithIcon(IconButton, Icons.delete);
		await tester.tap(deleteButton);
		await tester.pump();
		
		// We check we're redirected
		await _buildListPage(tester);
		verify(mockObserver.didPush(any, any)); // Check we're redirected
	});
}