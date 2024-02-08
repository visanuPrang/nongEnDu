import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messagingapp/group_chats/group_list.dart';
import 'package:messagingapp/pages/home.dart';
import 'package:messagingapp/pages/image.dart';
import 'package:messagingapp/pages/signin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bottom Navigation Bar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      // home:  ChatHomePage(loginName: name),
    );
  }
}

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({Key? key}) : super(key: key);

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage>
    with WidgetsBindingObserver {
  late Map<String, dynamic> userMap;
  bool isLoading = false;
  final PageController pageController = PageController(initialPage: 0);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late int _selectedIndex = 0;
  var pageName = ['User List.', 'Group List.'];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus('Online');
  }

  void setStatus(String status) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      'status': status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus('Online');
    } else {
      // offline
      setStatus('Offline');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 220, 214, 232),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 57, 6, 119),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white70,
          ),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return const SignIn();
            }));
          },
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              'Main chat page.',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              pageName[_selectedIndex],
              style: const TextStyle(color: Colors.white70, fontSize: 20),
            ),
          ],
        ),
        centerTitle: false,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            // onPressed: () {
            //   Navigator.pushReplacement(context,
            //       MaterialPageRoute(builder: (context) {
            //     return const SignIn();
            //   }));
            // },
            onPressed: () {
              setState(() {
                WidgetsBinding.instance.addObserver(this);
                setStatus("Offline");
              });
              _auth.signOut().then((value) {
                // UserSheetsApiLogout.logingOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return const SignIn();
                }));
              });
            },
          ),
        ],
      ),
      // extendBody: true,
      body: PageView(
        onPageChanged: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        controller: pageController,
        children: const <Widget>[
          Center(
            child: Home(),
          ),
          Center(
            child: GroupList(),
          ),
        ],
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        mini: true,
        shape: const CircleBorder(side: BorderSide.none),
        backgroundColor: const Color.fromARGB(255, 95, 57, 167),
        tooltip: 'Back to home page.',
        onPressed: () {},
        child: IconButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AboutImage(
                          title: 'view image',
                        )));
          },
          icon: const Icon(
            Icons.home_outlined,
            size: 25,
            color: Colors.white70,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
        height: 55,
        color: const Color.fromARGB(255, 95, 57, 167),
        shape: const CircularNotchedRectangle(),
        clipBehavior: Clip.antiAlias,
        child: BottomNavigationBar(
          backgroundColor: const Color.fromARGB(255, 95, 57, 167),
          useLegacyColorScheme: false,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
              pageController.jumpToPage(index);
            });
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              tooltip: 'Person',
              icon: Icon(Icons.person),
              label: 'Person',
            ),
            BottomNavigationBarItem(
              tooltip: 'Group',
              icon: Icon(Icons.group),
              label: 'Group',
            ),
          ],
        ),
      ),
    );
  }
}

// Screens for the different bottom navigation items
class SHome extends StatelessWidget {
  const SHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text('Home');
  }
}

class Search extends StatelessWidget {
  const Search({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text('Search');
  }
}
