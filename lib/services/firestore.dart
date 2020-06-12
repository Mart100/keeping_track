import 'dart:math';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


Future<List> addUserDay(uid) async {

	print('BEEP BEEP $uid');
	Map userData = await getUserData(uid);
	List days = userData['days'];
  Map settings = userData['settings'];
  List dayValues = settings['dayValues'];

  print('MMMMMMMMMMMMM: $dayValues');

	Random random = new Random();

	DateTime now = DateTime.now();

  int randomNumber = random.nextInt(1000000000);

  String id = '$randomNumber';

  Map obj = {
    'date': now,
    'dateString': DateFormat('EEE d MMM').format(now),
    'id': id,
  };

  for(Map val in dayValues) {
    String valueType = val['valueType'];
    String title = val['title'];
    if(valueType == 'number') obj[title] = 0;
    if(valueType == 'rating') obj[title] = 5;
    if(valueType == 'text') obj[title] = "Enter text here...";
    if(valueType == 'time') obj[title] = DateTime.now();
    if(valueType == 'checkbox') obj[title] = false;
  }

	days.add(obj);

	Firestore.instance
	.collection('users')
	.document(uid)
	.updateData({
		'days': days,
	});

	return days;
}

Future<List> deleteDay({uid, deletedDay}) async {
  Map userData = await getUserData(uid);
	List days = userData['days'];

  days.removeWhere((day) => day['date'].millisecondsSinceEpoch == deletedDay['date'].millisecondsSinceEpoch);

	Firestore.instance
	.collection('users')
	.document(uid)
	.updateData({
		'days': days,
	});

  return days;
}

void updateDay({uid, newDay}) async {

	Map userData = await getUserData(uid);
	List days = userData['days'];

	print('$newDay $days');
	Map day = days.firstWhere((day) => day['id'] == newDay['id']);
	int index = days.indexOf(day);
	days[index] = newDay;

	Firestore.instance
	.collection('users')
	.document(uid)
	.updateData({
		'days': days,
	});

}

void updateSettings({uid, newSettings}) async {
	Firestore.instance
	.collection('users')
	.document(uid)
	.updateData({
		'settings': newSettings,
	});
}

Future<Map> createUserData(uid) async {

	await Firestore.instance
		.collection('users')
		.document(uid)
		.setData({
			'uid': uid,
			'days': [],
			'settings': {
				'dayValues': [
          {'title': 'Mood', 'valueType': 'rating', 'order': 1},
					{'title': 'to bed', 'valueType': 'time', 'order': 2},
					{'title': 'wake up', 'valueType': 'time', 'order': 3},
					{'title': 'Food Quality', 'valueType': 'rating', 'order': 4},
					{'title': 'Exercise Quality', 'valueType': 'rating', 'order': 5},
          {'title': 'Comment', 'valueType': 'text', 'order': 6},
				]
			},
		});

	Map user = await getUserData(uid);

	return user;
}

Future<Map> getUserData(uid) async {
	return Firestore.instance
		.collection('users')
		.document(uid)
		.get()
    .catchError((err) {
      print(err);
      return {'err': err};
    })
		.then((DocumentSnapshot docsnap) async {
			print('yatta! $docsnap ${docsnap.exists}');
			
			Map user;

			if(!docsnap.exists) user = await createUserData(uid);
			else user = docsnap.data;

			print('saddtimes $user');

			List days = user['days'];

			days = days.map((day) {
				day['date'] = day['date'].toDate();
				day['dateString'] = DateFormat('EEE d MMM').format(day['date']);
				
				for(String title in day.keys) {
					if(day[title] is Timestamp) day[title] = day[title].toDate();
				}
				return day;
			}).toList();

			Map settings = user['settings'];
			
			//print('yoo: $days');
			return {'days': days, 'uid': uid, 'settings': settings};
		});
}