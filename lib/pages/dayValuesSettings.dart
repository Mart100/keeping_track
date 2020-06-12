import 'package:flutter/material.dart';
import 'package:keeping_track/services/firestore.dart';

class DayValuesSettingsPage extends StatefulWidget {
	@override
	_DayValuesSettingsPageState createState() => _DayValuesSettingsPageState();
}

class _DayValuesSettingsPageState extends State<DayValuesSettingsPage> {

	Map data = {};

	List newDayValues = [];

	bool newChangesMade = false;

	List valuesWidgetList = [];

	void saveDayValues() {
		data['settings']['dayValues'] = newDayValues;
		updateSettings(uid: data['uid'], newSettings: data['settings']);
	}

	@override
	Widget build(BuildContext context) {

		if(!data.isNotEmpty) {
			data = ModalRoute.of(context).settings.arguments;
			newDayValues = data['settings']['dayValues'];
		}

		List<Widget> valuesWidgetList = [];
	
		print('uwu: ${data['settings']}');

    newDayValues = newDayValues.where((v) => v['active'] != false).toList();

    newDayValues = newDayValues.where((v) => v['title'] != 'date' || v['valueType'] != null).toList();

		newDayValues.sort((a, b) {
			int orderA = a['order'];
			int orderB = b['order'];
			return orderA-orderB;
		});

		for(var idx = 0; idx < newDayValues.length; idx++ ) {
			Map val = newDayValues[idx];
			valuesWidgetList.add(
				DayValueSettingsListTile(
					title: val['title'],
					valueType: val['valueType'],
					updateTitle: (newVal) {
						val['title'] = newVal;
						setState(() {
							newChangesMade = true;
						});
					},
					deleteDayValue: () {
						setState(() {
              val['active'] = false;
							newChangesMade = true;
						});
					},
					moveDayValue: (amount) {
						if(idx+amount < 0) return;
						if(idx+amount > newDayValues.length-1) return;
						newDayValues.remove(val);
						newDayValues.insert(idx+amount, val);
						for(var idx1 = 0; idx1 < newDayValues.length; idx1++) newDayValues[idx1]['order'] = idx1;
						setState(() {
							newChangesMade = true;
						});
					},
					updateValueType: (newVal) {
						val['valueType'] = newVal;
						setState(() {
							newChangesMade = true;
						});
					}
				),
			);
		}

		valuesWidgetList.add(
			FlatButton.icon(
				padding: EdgeInsets.all(10),
				label: Text(
					'Click to add a new Day value!',
					style: TextStyle(
						fontSize: 25,
					),
				),
				color: Theme.of(context).cardColor,
				icon: Icon(
					Icons.add,
					size: 40,
				),
				onPressed: () {
					setState(() {
						newChangesMade = true;
						newDayValues.add({
							'title': 'Title',
							'valueType': 'number',
							'order': newDayValues.length+1
						});
					});
				},
			),
		);


		return WillPopScope(
      onWillPop: () {
				if(!newChangesMade) {
					return Future.delayed(const Duration(milliseconds: 1), () {
						return true;
					});
				} 
				return showDialog<bool>(
					context: context,
					builder: (c) => AlertDialog(
						title: Text('Warning'),
						content: Text('You have not saved yet, Do you really want to exit?'),
						actions: [
							FlatButton(
								child: Text('No'),
								onPressed: () => Navigator.pop(c, false),
							),
							FlatButton(
								child: Text('Yes'),
								onPressed: () => Navigator.pop(c, true),
							),
						]
					)
				);
			},
      child: Scaffold(
		  	appBar: AppBar(
		  		title: Text('Day values settings'),
		  		centerTitle: true,
		  		elevation: 0,
		  	),
		  	body: SingleChildScrollView(
		  		child: Container(
		  			padding: EdgeInsets.all(20),
		  			child: Column(
		  				mainAxisSize: MainAxisSize.min,
		  				children: <Widget>[
		  					newChangesMade ? Container(
		  						width: 10000,
		  						color: Colors.green[300],
		  						child: FlatButton.icon(
		  							label: Text('Click here to save changes!'),
		  							icon: Icon(Icons.save),
		  							onPressed: () {
		  								saveDayValues();
		  								setState(() {
		  									newChangesMade = false;
		  								});
		  							},
		  						),
		  					) : Container(),
		  					ListView(
		  						shrinkWrap: true,
		  						physics: ScrollPhysics(),
		  						children: valuesWidgetList,
		  					),
		  				],
		  			)
		  		),
		  	)
		  ),
		);
	}
}

class DayValueSettingsListTile extends StatefulWidget {

	String title;
	String valueType;
	Function updateValueType;
	Function updateTitle;
	Function deleteDayValue;
	Function moveDayValue;

	DayValueSettingsListTile({
		@required this.title,
		@required this.valueType,
		@required this.updateValueType,
		@required this.updateTitle,
		@required this.deleteDayValue,
		@required this.moveDayValue,
	});


	@override
	_DayValueSettingsListTileState createState() => _DayValueSettingsListTileState();
}

class _DayValueSettingsListTileState extends State<DayValueSettingsListTile> {

	bool showTitleDropdown = false;
	
	var titleInputController = TextEditingController();

	@override
	Widget build(BuildContext context) {

		titleInputController.text = widget.title;

		return Container(
			color: Theme.of(context).cardColor,
			margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
			padding: EdgeInsets.all(10),
			child: Row(
				children: <Widget>[
					Expanded(
						flex: 4,
						child: TextField(
							autofocus: true,
							
							controller: titleInputController,
							decoration: InputDecoration(
								border: UnderlineInputBorder(),
								
							),
							style: TextStyle(
								fontSize: 15,
							),
							onSubmitted: (String newValue) {
								widget.updateTitle(newValue);

								setState(() {
									widget.title = newValue;
									showTitleDropdown = false;
								});
							},
						),
					),
					Expanded(
						flex: 4,
						child: DropdownButton<String>(
							autofocus: true,
							isExpanded: true,
							dropdownColor: Theme.of(context).cardColor,
							value: widget.valueType,
							items: <String>['time', 'text', 'number', 'rating'].map((String value) {
								return new DropdownMenuItem<String>(
									value: value,
									child: new Text(
                    value,
                  ),
								);
							}).toList(),
							onChanged: (String newValue) {
								widget.updateValueType(newValue);

								setState(() {
									widget.valueType = newValue;
								});
							},
						)
					),
					Expanded(
						flex: 1,
						child: Column(
							children: <Widget>[
								GestureDetector(
									child: Icon(
										Icons.keyboard_arrow_up,
										size: 30,
									),
									onTap: () {
										widget.moveDayValue(-1);
									},
								),
								GestureDetector(
									child: Icon(
										Icons.keyboard_arrow_down,
										size: 30,
									),
									onTap: () {
										widget.moveDayValue(1);
									},
								),
							],
						)
					),
					Expanded(
						flex: 1,
						child: IconButton(
							icon: Icon(
								Icons.delete,
							),
							tooltip: 'Delete',
							splashColor: Colors.blue,
							onPressed: () {
								return showDialog<bool>(
									context: context,
									builder: (c) => AlertDialog(
										title: Text('Warning'),
										content: Text('Are you sure you want to delete this day value?'),
										actions: [
											FlatButton(
												child: Text('No'),
												onPressed: () {
													Navigator.pop(c);
												},
											),
											FlatButton(
												child: Text('Yes'),
												onPressed: () {
													Navigator.pop(c);
													widget.deleteDayValue();
												},
											),
										]
									)
								);
							},
						)
					)
				],
			),
		);
	}
}