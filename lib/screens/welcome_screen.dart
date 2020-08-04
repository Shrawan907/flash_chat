import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'login_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final usersRef = Firestore.instance.collection('users');

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
      //upperBound: 100.0,    // this is not use when we use CurvedAnimation()
    );
    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white)
        .animate(controller);
    controller.forward();
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value, //Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: 60,
                  ),
                ),
                TypewriterAnimatedTextKit(
                  text: ['Fast Chat'],
                  //'${(controller.value).toInt()}%', //  we should use animation in
                  // place of controller because animation covers the controller
                  textStyle: TextStyle(
                    fontSize: 45.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            RoundedButton(
              color: Colors.lightBlueAccent,
              title: 'Start Your Chat 😎',
              onPressed: () async {
                var user = await FirebaseAuth.instance.currentUser();
                if (user != null) {
                  print("\n\n\n\n");
                  print(user.phoneNumber);
                  print(user.email);
                  print(user.displayName);
                  print(user.providerId);
                  print(ModalRoute.of(context));
                  print(ModalRoute.of(context).settings.name);
                  print(user.providerData);
                  print("\n\n\n\n");
                  DocumentSnapshot doc =
                      await usersRef.document(user.phoneNumber).get();
                  if (!doc.exists) {
                    Navigator.pushReplacementNamed(context, ChatScreen.id);
                  }
                } else {
                  Navigator.pushReplacementNamed(context, LoginScreen.id);
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
