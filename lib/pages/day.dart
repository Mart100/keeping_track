import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:keeping_track/services/firestore.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class DayPage extends StatefulWidget {

	bool isEditable = false;


	@override
	_DayPageState createState() => _DayPageState();
}

class _DayPageState extends State<DayPage> {


	Map data = {};
	Map day = {};
  Map settings = {};
  List dayValues = [];
	String uid;
	Map newDay = {};

	List<Widget> dayInfoWidgets = [];

	void saveDayData() {
		updateDay(uid: uid, newDay: day);
    data['refresh']();
    day['dateString'] = DateFormat('EEE d MMM').format(day['date']);
	}

	@override
	Widget build(BuildContext context) {
		
		if(!data.isNotEmpty) {
			data = ModalRoute.of(context).settings.arguments;
			day = data['day'];
			uid = data['uid'];
      settings = data['settings'];
      dayValues = settings['dayValues'];
		}

    void removeDay() {
      data['deleteDay']();
    }

		List filteredValues = ['dateString', 'id'];

    if(dayValues.firstWhere((dv) => dv['title'] == 'date', orElse: () => null) == null) dayValues.add({'title': 'date', 'order': -100});

    List dayKeys = day.keys.toList();

    dayKeys.sort((a, b) {
      Map dva = dayValues.firstWhere((dv) => dv['title'] == a, orElse: () => null);
      int aOrder = 100;
      if(dva != null && dva['order'] != null) aOrder = dva['order'];

      Map dvb = dayValues.firstWhere((dv) => dv['title'] == b, orElse: () => null);
      int bOrder = 100;
      if(dvb != null && dvb['order'] != null) bOrder = dvb['order'];

      //print('$aOrder $a -- $bOrder $b');
      return aOrder - bOrder;
      
    });
		
		dayInfoWidgets = [];
		for(String title in dayKeys) {
			if(filteredValues.contains(title)) continue;
      Map dayValue = dayValues.firstWhere((dv) => dv['title'] == title, orElse: () => null);
      String valueType = '${day[title].runtimeType}';
      if(dayValue != null) valueType = dayValue['valueType'];

			dayInfoWidgets.add(
				TextValueBox(
					title: title,
					value: day[title], 
					editable: widget.isEditable,
          valueType: valueType,
					updateValue: (newVal) {
						newDay[title] = newVal;
					}
				)
			);
		}

		return WillPopScope(
			onWillPop: () {
				if(!widget.isEditable) {
					return Future.delayed(const Duration(milliseconds: 1), () {
						return true;
					});
				} 
				return showDialog<bool>(
					context: context,
					builder: (c) => AlertDialog(
						title: Text('Warning'),
						content: Text('You have not saved this day yet, Do you really want to exit?'),
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
					title: Text('${day['dateString']}'),
					centerTitle: true,
					elevation: 0,
					actions: <Widget>[
						IconButton(
							icon: Icon(
								(widget.isEditable ? Icons.save : Icons.edit ),
								size: 30,
								color: Colors.white,
							),
							onPressed: () {
								setState(() {
								if(widget.isEditable) {
									widget.isEditable = false;
									
									// apply new day on day object
									for(String title in newDay.keys) {
										day[title] = newDay[title];
									}

									// save to database 
									saveDayData();

								} else {
									widget.isEditable = true;

								}
							});
							},
						)
					],
				),
				body: SingleChildScrollView(
					child: Padding(
						padding: const EdgeInsets.all(15.0),
						child: Column(
						  children: <Widget>[
						    Column(
						    	crossAxisAlignment: CrossAxisAlignment.start,
						    	children: dayInfoWidgets,
						    ),
								widget.isEditable ? FlatButton(
									child: Text(
										'Delete this record',
										style: TextStyle(
											color: Colors.red,
										)
									),
									onPressed: () {
										return showDialog<bool>(
											context: context,
											builder: (c) => AlertDialog(
												title: Text('Warning'),
												content: Text('Are you sure you want to delete this day?'),
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
															Navigator.pop(c);
															deleteDay(uid: uid, deletedDay: day);
                              removeDay();
														},
													),
												]
											)
										);
									},
								) : SizedBox(),
						  ],
						),
					),
				),
			),
		);
	}
}

class TextValueBox extends StatefulWidget {
	final String title;
	dynamic value;
	bool editable;
  final String valueType;
	final Function updateValue;

	TextValueBox({
		@required this.title,
		@required this.value,
		@required this.editable,
		@required this.updateValue,
    @required this.valueType,
	});

	@override
	_TextValueBoxState createState() => _TextValueBoxState();
}

class _TextValueBoxState extends State<TextValueBox> {

	Widget editWidget;

  Widget valueWidget;

	@override
	Widget build(BuildContext context) {

		String value = '${widget.value}';
		if(widget.valueType == 'rating') {
			editWidget = Slider(
				value: widget.value.toDouble(),
				min: 0.0,
				max: 10.0,
				divisions: 10,
				onChanged: (double newValue) {
					setState(() {
						widget.value = newValue;
						widget.updateValue(newValue);
					});
				}
			);
			value = widget.value.toString();
		}

		if(widget.valueType == 'time') {
			editWidget = FlatButton(
				onPressed: () {
					DatePicker.showTimePicker(context,
						showSecondsColumn: false,
						showTitleActions: true,
						onConfirm: (date) {
							setState(() {
								print('yoo $date');
								widget.value = date;
								widget.updateValue(date);
							});
						},
						currentTime: widget.value,
					);
				},
				child: Text(
					'pick time',
					style: TextStyle(
					)
				)
			);
			value = DateFormat('jm').format(widget.value);
			
		}

    if(widget.valueType == 'number') {
      editWidget = TextField(
        decoration: new InputDecoration(labelText: "Enter your number"),
        keyboardType: TextInputType.number,
        controller: TextEditingController()..text = '${widget.value}',
        onSubmitted: (newVal) {
          setState(() {
            widget.value = newVal;
            widget.updateValue(newVal);
          });
        },
      );
    }

    if(widget.valueType == 'text') {
      editWidget = TextField(
        decoration: new InputDecoration(labelText: "Enter your text..."),
        controller: TextEditingController()..text = '${widget.value}',
        onSubmitted: (newVal) {
          setState(() {
            widget.value = newVal;
            widget.updateValue(newVal);
          });
        },
      );    
    }

		if(widget.editable == false) {
			editWidget = SizedBox();
		}

    valueWidget = Text(
      '$value',
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );

    if(widget.title == 'date') {
      String dateString = DateFormat('EEE d MMM').format(widget.value);
      valueWidget = GestureDetector(
        child: Text(
          '${dateString}' + (widget.editable ? ' | click to change' : '')  ,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        onTap: () {
          if(!widget.editable) return;
          DatePicker.showDatePicker(context,
						showTitleActions: true,
						onConfirm: (date) {
							setState(() {
								print('yoo $date');
								widget.value = date;
								widget.updateValue(date);
							});
						},
						currentTime: widget.value,
					);
        }
      );
    }

		//print('$editWidget ${widget.value} ${widget.editable}');

		return Container(
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: <Widget>[
          Text(
            '${widget.title}:',
            style: TextStyle(
              color: Colors.grey,
              letterSpacing: 2,
              fontSize: 17
            ),
          ),
					SizedBox(height: 5),
          valueWidget,
					editWidget,
					SizedBox(height: 30)
				],
			)
		);
	}
}