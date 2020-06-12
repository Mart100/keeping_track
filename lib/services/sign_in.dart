import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

final GoogleSignIn googleSignIn = GoogleSignIn();

Map userAuthInfo = {
  'name': '',
  'email': '',
  'imageUrl': '',
  'uid': '',
  'authSignedIn': false,
};

Future<Map> getUserAuthInfo() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  userAuthInfo['authSignedIn'] = prefs.getBool('auth') ?? false;

  final FirebaseUser user = await _auth.currentUser();

  if (userAuthInfo['authSignedIn'] == true) {
    if (user != null) {
      userAuthInfo['name'] = user.displayName;
      userAuthInfo['email'] = user.email;
      userAuthInfo['imageUrl'] = user.photoUrl;
      userAuthInfo['uid'] = user.uid;
    }
  }

  return userAuthInfo;
}


Future<Map> signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final AuthResult authResult = await _auth.signInWithCredential(credential);
  final FirebaseUser user = authResult.user;

  // Checking if email and name is null
  assert(user.email != null);
  assert(user.displayName != null);
  assert(user.photoUrl != null);

  userAuthInfo['name'] = user.displayName;
  userAuthInfo['email'] = user.email;
  userAuthInfo['imageUrl'] = user.photoUrl;
  userAuthInfo['uid'] = user.uid;

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('auth', true);
  userAuthInfo['authSignedIn'] = true;

  //print('signInWithGoogle succeeded: $name - $email');

  return {'uid': userAuthInfo['uid']};
}

void signOutGoogle() async {
  await googleSignIn.signOut();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('auth', false);
  userAuthInfo['authSignedIn'] = false;

  print("User Sign Out");
}