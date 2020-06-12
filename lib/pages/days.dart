import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:keeping_track/services/firestore.dart';
import 'package:intl/intl.dart';
import 'package:keeping_track/services/sign_in.dart';


class DaysPage extends StatefulWidget {
	@override
	_DaysPageState createState() => _DaysPageState();
}

class _DaysPageState extends State<DaysPage> {

	Map data = {};
  Map settings = {};
  Map firstDayValue = {'title': 'err', 'value': 'err'};

	@override
	Widget build(BuildContext context) {

    

		if(!data.isNotEmpty) {
      data = ModalRoute.of(context).settings.arguments;
      settings = data['settings'];

      settings['dayValues'].sort((a, b) {
        int orderA = a['order'];
        int orderB = b['order'];
        return orderA-orderB;
      });

      firstDayValue = settings['dayValues'][0];
      print('firstDayValue: $firstDayValue');
    }

		if(!data['days'].isNotEmpty) data['days'] = [];

		String uid = data['uid'];

		print(data['days']);

		data['days'].sort((a, b) {

			DateTime aDate = a['date'];
			DateTime bDate = b['date'];

			return bDate.millisecondsSinceEpoch-aDate.millisecondsSinceEpoch;
		});

		return Scaffold(
			drawer: new Drawer(
				child: Container(
					//color: Colors.grey[850],
					child: ListView(
						padding: EdgeInsets.all(0),
						children: <Widget>[
							Container(
								height: 104,
								child: DrawerHeader(
									decoration: BoxDecoration(
										color: Color.fromARGB(255, 86, 143, 250),
									),
									child: Text(
										'Keeping Track',
										style: TextStyle(
											fontSize: 24
										),
									),
								),
							),
							ListTile(
								leading: Icon(
									Icons.settings,
								),
								title: Text('Settings'),
								onTap: () {
									Navigator.pushNamed(context, '/settings', arguments: data);
								},
							),
							ListTile(
								leading: Icon(
									Icons.info,
								),
								title: Text('About'),
								onTap: () {
									Navigator.pushNamed(context, '/about', arguments: data['settings']);
								}
							),
							ListTile(
								leading: Icon(
									Icons.exit_to_app,
								),
								title: Text('Logout'),
								onTap: () {
									signOutGoogle();
									Navigator.pushReplacementNamed(context, '/login');
								}
							),
						],
					),
				)
			),
			appBar: AppBar(
				title: Text('Days'),
				centerTitle: true,
				actions: <Widget>[
					IconButton(
						icon: Icon(
							Icons.settings,
							size: 30,
						),
						onPressed: () {
							Navigator.pushNamed(context, '/settings', arguments: data);
						},
					),
				],
			),
			floatingActionButton: FloatingActionButton(
				onPressed: () async {
					List days = await addUserDay(uid);
					setState(() {
						
						data['days'] = days;
					});
				},
				child: Icon(Icons.add),
				//backgroundColor: Color.fromARGB(255, 56, 113, 229),
			),
			body: ListView.builder(
				padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
				itemCount: data['days'].length,
				itemBuilder: (context, index) {
					Map day = data['days'][index];

          String firstValueTitle = firstDayValue['title'] ?? 'date';

					return Container(
						padding: EdgeInsets.symmetric(vertical: 1, horizontal: 0),
						margin: EdgeInsets.symmetric(vertical: 5, horizontal: 30),
						decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
							borderRadius: BorderRadius.circular(20.0),
						),
						child: ListTile(
							onTap: () {
								Navigator.pushNamed(context, '/day', arguments: {
									'uid': uid,
									'day': day,
									'settings': data['settings'],
                  'refresh': () {
                    setState(() {});
                  },
									'deleteDay': () {
										setState(() {
											data['days'].removeWhere((dayR) => dayR['id'] == day['id']);
										});
									}
								});
							},
							title: Text(
								DateFormat('EEE d MMM').format(day['date']),
								style: TextStyle(
									fontSize: 25,
								),
							),
							subtitle: Text(
								'${firstValueTitle}: ${day[firstValueTitle]}',
								style: TextStyle(
									fontSize: 15,
								)
							),
						),
					);
				},
			)
		);
	}
}