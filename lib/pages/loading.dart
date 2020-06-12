import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:keeping_track/services/firestore.dart';
import 'package:keeping_track/services/sign_in.dart';


class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {

  Map data = {};

  BuildContext context;

  void goDaysPage(data) async {
    String uid = '';
    if(data == null) {
      Map userInfo = await getUserAuthInfo();
      uid = userInfo['uid'];
    } else {
    Map user = data['user'];
    uid = user['uid'];
    }


    Map userData = await getUserData(uid);

    print('RECEIVED USER DATA: $userData');

    Navigator.pushReplacementNamed(context, '/days', arguments: userData);
  }

  @override
  Widget build(BuildContext context) {

    setState(() => this.context = context);

    if(!data.isNotEmpty) data = ModalRoute.of(context).settings.arguments;

    print(data);

    goDaysPage(data);

    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Center(
        child: SpinKitRotatingCircle(
          color: Colors.white,
          size: 50,
        )
      )
    );
  }
}