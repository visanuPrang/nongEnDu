import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nongendu/screens/login.dart';
import 'package:nongendu/screens/register.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

//1c5-PsNCviTglAa2NEF2k7cYzMUsbCqCXk0I7AzASYKI
  @override
  Widget build(BuildContext context) {
    final headerTextStyle = GoogleFonts.montserrat(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 24,
      textStyle: Theme.of(context).textTheme.displaySmall,
    );
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 146, 86, 107),
          title: Text(
            'สมัครสมาชิก/เข้าสู่ระบบ',
            style: headerTextStyle,
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
            child: Column(
              children: [
                const SizedBox(),
                const Image(image: AssetImage("assets/images/Owl.png")),
                SizedBox(
                    width: 300,
                    height: 60,
                    child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 191, 156, 168),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50))),
                        onPressed: () {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            return const RegisterScreen();
                          }));
                        },
                        icon: const Icon(
                          size: 1,
                          Icons.add,
                          color: Color.fromARGB(255, 191, 156, 168),
                        ),
                        label: const Text(
                          'สร้างบัญชีผู้ใช้ใหม่',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              inherit: true,
                              fontSize: 25.0,
                              color: Color.fromARGB(255, 146, 86, 107),
                              shadows: [
                                Shadow(
                                    // bottomLeft
                                    offset: Offset(-1.5, -1.5),
                                    color: Color.fromARGB(255, 247, 225, 202)),
                                Shadow(
                                    // bottomRight
                                    offset: Offset(1.5, -1.5),
                                    color: Color.fromARGB(255, 247, 225, 202)),
                                Shadow(
                                    // topRight
                                    offset: Offset(1.5, 1.5),
                                    color: Color.fromARGB(255, 247, 225, 202)),
                                Shadow(
                                    // topLeft
                                    offset: Offset(-1.5, 1.5),
                                    color: Color.fromARGB(255, 247, 225, 202)),
                              ]),
                          textAlign: TextAlign.right,
                        ))),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                    width: 300,
                    height: 60,
                    child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 191, 156, 168),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50))),
                        onPressed: () {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) {
                            // return const LoginScreen();
                            return const LoginScreen();
                          }));
                        },
                        icon: const Icon(
                          size: 1,
                          Icons.login,
                          color: Color.fromARGB(255, 191, 156, 168),
                        ),
                        label: const Text(
                          'เข้าสู่ระบบ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              inherit: true,
                              fontSize: 25.0,
                              color: Color.fromARGB(255, 146, 86, 107),
                              shadows: [
                                Shadow(
                                    // bottomLeft
                                    offset: Offset(-1.5, -1.5),
                                    color: Color.fromARGB(255, 247, 225, 202)),
                                Shadow(
                                    // bottomRight
                                    offset: Offset(1.5, -1.5),
                                    color: Color.fromARGB(255, 247, 225, 202)),
                                Shadow(
                                    // topRight
                                    offset: Offset(1.5, 1.5),
                                    color: Color.fromARGB(255, 247, 225, 202)),
                                Shadow(
                                    // topLeft
                                    offset: Offset(-1.5, 1.5),
                                    color: Color.fromARGB(255, 247, 225, 202)),
                              ]),
                        )))
              ],
            )));
  }
}
