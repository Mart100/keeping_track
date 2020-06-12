import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
	@override
	_AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.grey[900],
			appBar: AppBar(
				title: Text('About'),
				centerTitle: true,
				backgroundColor: Colors.grey[850],
				elevation: 0,
			),
			body: Padding(
				padding: EdgeInsets.fromLTRB(30, 40, 30, 0),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: <Widget>[
						Center(
							child: CircleAvatar(
								backgroundImage: AssetImage('assets/logo.png'),
								radius: 40,
								backgroundColor: Color.fromARGB(50, 0, 0, 0),
							),
						),
						Divider(
							height: 60,
							color: Colors.grey[800],
						),
						Text(
							'MADE BY:',
							style: TextStyle(
								color: Colors.grey,
								letterSpacing: 2
							),
						),
						SizedBox(height: 10),
						Text(
							'Mart van Enckevort',
							style: TextStyle(
								color: Colors.amberAccent[200],
								fontSize: 28,
								fontWeight: FontWeight.bold,
								letterSpacing: 2,
							),
						),
						SizedBox(height: 20),
						Row(
							children: <Widget>[
								Icon(
									Icons.web,
									color: Colors.grey[400],
								),
								SizedBox(width: 10),
								Text(
									'https://martvenck.com',
									style: TextStyle(
										color: Colors.grey[400],
										fontSize: 18,
										letterSpacing: 1,
									),
								)
							],
						),
						SizedBox(height: 20),
						Row(
							children: <Widget>[
								Icon(
									Icons.email,
									color: Colors.grey[400],
								),
								SizedBox(width: 10),
								Text(
									'martvanenck1@gmail.com',
									style: TextStyle(
										color: Colors.grey[400],
										fontSize: 18,
										letterSpacing: 1,
									),
								)
							],
						)
					],
				),
			),
		);
	}
}