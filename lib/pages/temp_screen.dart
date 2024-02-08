import 'package:flutter/material.dart';
import 'package:messagingapp/pages/signin.dart';
import 'package:messagingapp/screens/chat_home.dart';
import 'package:messagingapp/service/auth.dart';

class TempScreen extends StatefulWidget {
  const TempScreen({super.key});

  @override
  State<TempScreen> createState() => _TempScreenState();
}

class _TempScreenState extends State<TempScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: AuthMethods().getcurrentUser(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return const ChatHomePage();
          } else {
            return const SignIn();
          }
        },
      ),
    );
  }
}
