import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String verId;
  String phoneNo;
  String smsCode;
  String verificationId;

  Future<void> veifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetriveal = (String verId) {
      this.verificationId = verId;
    };
    final smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      smsCodeDialog(context).then((value) {
        print('signed in');
      });
    };
    final PhoneVerificationCompleted verifiedSuccess =
        (AuthCredential credential) async {
      print("verified\n");
      AuthResult result =
          await FirebaseAuth.instance.signInWithCredential(credential);
      FirebaseUser user = result.user;
      if (user != null) {
        print(ModalRoute.of(context));
        print(ModalRoute.of(context).settings.name);
        Navigator.pushReplacementNamed(context, ChatScreen.id);
      } else {
        print("Error ho gay bhai!");
      }
    };
    final PhoneVerificationFailed veriFailed = (AuthException exception) {
      print("${exception.message}");
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: this.phoneNo,
      codeAutoRetrievalTimeout: autoRetriveal,
      codeSent: smsCodeSent,
      timeout: const Duration(seconds: 5),
      verificationCompleted: verifiedSuccess,
      verificationFailed: veriFailed,
    );
  }

  Future<bool> smsCodeDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Enter Code: '),
            content: TextField(
              onChanged: (value) {
                this.smsCode = value;
              },
            ),
            contentPadding: EdgeInsets.all(10.0),
            actions: <Widget>[
              new FlatButton(
                child: Text('Submit'),
                onPressed: () async {
                  smsCode = this.smsCode.trim();
                  AuthCredential credential = PhoneAuthProvider.getCredential(
                      verificationId: verificationId, smsCode: smsCode);
                  AuthResult result = await FirebaseAuth.instance
                      .signInWithCredential(credential);
                  FirebaseUser user = result.user;
                  if (user != null) {
                    print(ModalRoute.of(context));
                    print(ModalRoute.of(context).settings.name);
                    Navigator.pushReplacementNamed(context, ChatScreen.id);
                  } else {
                    print("\n ho gayi error yha\n");
                  }
                },
              )
            ],
          );
        });
  }

  String alert;
  bool showAlert = false;
  @override
  Widget build(BuildContext context) {
    return ProgressHUD(
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Flexible(
                  child: Hero(
                    tag: 'logo',
                    child: Container(
                      height: 200.0,
                      child: Image.asset('images/logo.png'),
                    ),
                  ),
                ),
                SizedBox(
                  height: 48.0,
                ),
                TextField(
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.left,
                  onChanged: (value) {
                    this.phoneNo = value;
                  },
                  decoration:
                      kTextFieldDecoration.copyWith(hintText: "+91----------"),
                ),
                SizedBox(
                  height: 24.0,
                ),
                !showAlert
                    ? RoundedButton(
                        color: Colors.lightBlueAccent,
                        title: 'Log In',
                        onPressed: () {
                          this.phoneNo = this.phoneNo.trim();
                          veifyPhone();
                        },
                      )
                    : AlertDialog(title: Text(alert), actions: [
                        FlatButton(
                          onPressed: () {
                            setState(() {
                              showAlert = false;
                            });
                          },
                          child: Text('Back'),
                        ),
                      ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
