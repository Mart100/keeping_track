import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:keeping_track/pages/loading.dart';
import 'package:keeping_track/services/sign_in.dart';

class LoginPage extends StatefulWidget {
	@override
	_LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

	bool _isLoading;

	
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: new AppBar(
				title: new Text('Flutter Login'),
			),
			body: Container(
				child: Center(
					child: Column(
						mainAxisSize: MainAxisSize.max,
						mainAxisAlignment: MainAxisAlignment.center,
						children: <Widget>[
							Image(image: AssetImage('assets/logo.png'), height: 150),
							SizedBox(height: 50),
							_signInButton(),
						],
					)
				),
			),
		);
	}

	Widget _signInButton() {
		return OutlineButton(
			splashColor: Colors.grey,
			shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
			highlightElevation: 0,
			borderSide: BorderSide(color: Colors.grey),
			child: Padding(
				padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
				child: Row(
					mainAxisSize: MainAxisSize.min,
					mainAxisAlignment: MainAxisAlignment.center,
					children: <Widget>[
						Image(image: AssetImage("assets/google_logo.png"), height: 35.0),
						Padding(
							padding: const EdgeInsets.only(left: 10),
							child: Text(
								'Sign in with Google',
								style: TextStyle(
									fontSize: 20,
									color: Colors.grey,
								),
							),
						)
					],
				),
			),
			onPressed: () async {
				Map data = await signInWithGoogle();
        String uid = data['uid'];
        print('YEEEEET: $uid $data');
        Navigator.pushReplacementNamed(context, '/loading', arguments: {
          'user': {
            'uid': uid,
          },
        });
			},
		);
	}

}

