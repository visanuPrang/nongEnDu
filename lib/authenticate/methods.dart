import 'package:messagingapp/authenticate/loginscree.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<User?> createAccount(String name, String email, String password) async {
  FirebaseAuth auth = FirebaseAuth.instance;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    UserCredential userCrendetial = await auth.createUserWithEmailAndPassword(
        email: email, password: password);

    debugPrint("Account created Succesfull");

    userCrendetial.user!.updateDisplayName(name);

    await firestore.collection('users').doc(auth.currentUser!.uid).set({
      "name": name,
      "email": email,
      "status": "Unavalible",
      "uid": auth.currentUser!.uid,
    });

    return userCrendetial.user;
  } catch (e) {
    debugPrint('{$e}');
    return null;
  }
}

Future<User?> logIn(String email, String password) async {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    UserCredential userCredential =
        await auth.signInWithEmailAndPassword(email: email, password: password);

    debugPrint("Login Sucessfull");
    firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get()
        .then((value) => userCredential.user!.updateDisplayName(value['name']));

    return userCredential.user;
  } catch (e) {
    debugPrint('$e');
    return null;
  }
}

Future logOut(BuildContext context) async {
  FirebaseAuth auth = FirebaseAuth.instance;

  try {
    await auth.signOut().then((value) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  } catch (e) {
    debugPrint("error");
  }
}
