import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messagingapp/pages/signin.dart';
import 'package:messagingapp/service/database.dart';
import 'package:messagingapp/service/shared_pref.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = '', password = '', name = '', confirmPassword = '';
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController confirmPasswordcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  registration() async {
    // ----------- comment out auto add new user
    var xName = ['P', 'S', 'T'];
    password = '111111';
    confirmPassword = '111111';
    debugPrint('${xName.length}');
    for (int i = 0; i < xName.length; i++) {
      for (int n = 1; n < 10; n++) {
        var email = "${xName[i]}0$n@endu.com";
        var cName = "${xName[i]}0$n EnDu School";
        debugPrint('${xName[i]} $email $cName');
        if (password.toString() == confirmPassword.toString()) {
          try {
            // ignore: unused_local_variable
            UserCredential userCredential = await FirebaseAuth.instance
                .createUserWithEmailAndPassword(
                    email: email, password: password);
            User? user = userCredential.user;
            await user?.updateDisplayName(cName);
            await user?.reload();

            // User? user = userCredential.user;
            String uid = user!.uid;
            String updateusername = email.substring(0, email.indexOf('@'));
            Map<String, dynamic> userInfoMap = {
              'recordType': 'Person',
              // 'Name': namecontroller.text,
              // 'E-mail': emailcontroller.text,
              'Name': cName, //namecontroller.text,
              'E-mail': email, //emailcontroller.text,
              'username': updateusername,
              'Photo':
                  'https://img.freepik.com/premium-vector/cute-little-student-girl-cartoon_96373-287.jpg',
              'Id': uid,
              'status': ''
            };
            await DatabaseMethods().addUserDetails(userInfoMap, uid);
            await SharedPreferenceHelper().saveUserId(uid);
            await SharedPreferenceHelper()
                .saveUserDisplayName(namecontroller.text);
            await SharedPreferenceHelper().saveUserEmail(emailcontroller.text);
            await SharedPreferenceHelper().saveUserPic(
                'https://img.freepik.com/premium-vector/cute-little-student-girl-cartoon_96373-287.jpg');
            await SharedPreferenceHelper()
                .saveUserName(emailcontroller.text.replaceAll('@endu.com', ''));

            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                'register $email\nRegistered Successfully',
                style: const TextStyle(fontSize: 20),
              ),
            ));
            // ignore: use_build_context_synchronously
            // Navigator.pushReplacement(context,
            //     MaterialPageRoute(builder: (builder) => const ChatHomePage()));
          } on FirebaseAuthException catch (e) {
            // if (e.code == 'weak-password') {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
              'register $email\n${e.message}',
              style: const TextStyle(fontSize: 20),
            )));
            // }
          }
        }
      } //loop int n for automatic create user
    } //loop int i for automatic create user
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ignore: avoid_unnecessary_containers
      body: Container(
          child: Stack(children: [
        Container(
          height: MediaQuery.of(context).size.height / 4,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF7f30fe), Color(0xFF6380fb)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.vertical(
                  bottom: Radius.elliptical(
                      MediaQuery.of(context).size.width, 105))),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Column(
            children: [
              const Text(
                'SignUp',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const Center(
                child: Text(
                  'Create a new account.',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffbbb0ff)),
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 30, horizontal: 20),
                    height: MediaQuery.of(context).size.height / 1.5,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Form(
                      key: _formkey,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Name',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              // padding: EdgeInsets.only(left: 10),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Colors.black38),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: namecontroller,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please Enter Name';
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        prefixIcon: Icon(
                                          Icons.person_2_outlined,
                                          color: Color(0xFF7f30fe),
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Email',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              // padding: EdgeInsets.only(left: 10),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Colors.black38),
                                  borderRadius: BorderRadius.circular(10)),
                              child: TextFormField(
                                controller: emailcontroller,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter email';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: Icon(
                                      Icons.mail_outline,
                                      color: Color(0xFF7f30fe),
                                    )),
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Password',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              // padding: EdgeInsets.only(left: 10),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Colors.black38),
                                  borderRadius: BorderRadius.circular(10)),
                              child: TextFormField(
                                controller: passwordcontroller,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter passowrd';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: Icon(
                                      Icons.password,
                                      color: Color(0xFF7f30fe),
                                    )),
                                obscureText: true,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Confirm Password',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              // padding: EdgeInsets.only(left: 10),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1, color: Colors.black38),
                                  borderRadius: BorderRadius.circular(10)),
                              child: TextFormField(
                                controller: confirmPasswordcontroller,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Confirm Password';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: Icon(
                                      Icons.password,
                                      color: Color(0xFF7f30fe),
                                    )),
                                obscureText: true,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Already have an account? ',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SignIn()));
                                  },
                                  child: const Text(
                                    'Sign In Now!',
                                    style: TextStyle(
                                        color: Color(0xFF6380fb),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ]),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  if (_formkey.currentState!.validate()) {
                    setState(() {
                      email = emailcontroller.text;
                      name = namecontroller.text;
                      password = passwordcontroller.text;
                      confirmPassword = confirmPasswordcontroller.text;
                    });
                  }
                  registration();
                },
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    width: MediaQuery.of(context).size.width,
                    child: Material(
                      borderRadius: BorderRadius.circular(10),
                      elevation: 5,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: const Color(0xFF6380fb),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Center(
                          child: Text(
                            'SIGN UP',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ])),
    );
  }
}
