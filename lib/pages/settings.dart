import 'package:flutter/material.dart';
import 'package:keeping_track/main.dart';
import 'package:get/get.dart';
import 'package:theme_mode_handler/theme_mode_handler.dart';


class SettingsPage extends StatefulWidget {
	@override
	_SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

	Map data = {};
	bool darkThemeSwitch = true;

	@override
	Widget build(BuildContext context) {

		if(!data.isNotEmpty) data = ModalRoute.of(context).settings.arguments;

		return Scaffold(
			appBar: AppBar(
				title: new Text(
					'Settings',
					style: TextStyle(
						fontSize: 30,
					)
				),
				elevation: 0,
				centerTitle: true,
			),
			body: ListView(
				padding: EdgeInsets.all(20),
				children: <Widget>[
					ListTile(
						title: Text('change Day values'),
						leading: Icon(Icons.event_note),
						onTap: () {
							Navigator.pushNamed(context, '/dayValuesSettings', arguments: data);
						}
					),
					ListTile(
						title: Row(
							children: <Widget>[
								Text('Dark mode'),
								Switch(
									value: ThemeModeHandler.of(context).themeMode == ThemeMode.dark,
									onChanged: (boolVal) {
										if(boolVal) ThemeModeHandler.of(context).saveThemeMode(ThemeMode.dark);
										else ThemeModeHandler.of(context).saveThemeMode(ThemeMode.light);
										setState(() {
											darkThemeSwitch = boolVal;
										});
									},
								)
							] 
						),
					),
				],
			),
		);
	}
}