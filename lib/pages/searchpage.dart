import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messagingapp/pages/chatpage.dart';
import 'package:messagingapp/pages/signin.dart';
import 'package:messagingapp/screens/chat_home.dart';
import 'package:messagingapp/service/database.dart';
import 'package:messagingapp/service/shared_pref.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool search = false;
  var queryResultSet = [];
  var tempSearchStore = [];
  var allUserResultSet = [];

  noPhoto(xName) {
    String initial = '';
    var splitName = xName.split(' ');
    splitName.length > 1
        ? initial = splitName[0].substring(0, 1).toUpperCase() +
            splitName[1].substring(0, 1).toUpperCase()
        : initial = splitName[0].substring(0, 1).toUpperCase();
    return initial;
  }

  listAllUser() async {
    await DatabaseMethods().getAllUser().then((QuerySnapshot docs) {
      for (int i = 0; i < docs.docs.length; ++i) {
        allUserResultSet.add(docs.docs[i].data());
      }
    });
    var seen = <String>{};
    List unique = allUserResultSet
        .where((allUserResultSet) => seen.add(allUserResultSet['Name']))
        .toList();
    allUserResultSet = unique;
  }

  initialSearch(value) async {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }
    setState(() {
      search = true;
    });
    if (queryResultSet.isEmpty && value.length == 1) {
      await DatabaseMethods().search(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.docs.length; ++i) {
          if (docs.docs[i]['Name'] != myName) {
            queryResultSet.add(docs.docs[i].data());
          }
        }
      });
    }
    var lValue = value.toLowerCase();
    tempSearchStore = [];
    for (var element in queryResultSet) {
      var xElement = element['Name'];
      if (xElement.toLowerCase().contains(lValue) &&
          element['Name'] != myName) {
        setState(() {
          tempSearchStore.add(element);
        });
      }
    }
    tempSearchStore.sort((a, b) => a["Name"].compareTo(b["Name"]));
  }

  String? myName, myProfilePic, myUsername, myEmail;
  Stream? chatRoomsStream;
  getthesharedpref() async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myProfilePic = await SharedPreferenceHelper().getUserPic();
    myUsername = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    chatRoomsStream = await DatabaseMethods().getChatRooms();
    setState(() {});
  }

  Widget chatRoomList() {
    return StreamBuilder(
        stream: chatRoomsStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.doc.length;
                    return ChatRoomListTile(
                        chatRoomId: ds.id,
                        lastMessage: ds['lastMessage'],
                        myUsername: myUsername!,
                        time: ds['lastMessageSendTs']);
                  })
              : const Center(
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                );
        });
  }

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  getChatRoomIdbyUsername(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return '${b}_$a';
    } else {
      return '${a}_$b';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 223, 219, 227),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 38, 2, 82),
        title: Text('Search page...[$myName]',
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return const ChatHomePage();
            }));
          },
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                return const SignIn();
              }));
            },
            // onPressed: () {
            //   auth.signOut().then((value) {
            //     UserSheetsApiLogout.logingOut();
            //     Navigator.pushReplacement(context,
            //         MaterialPageRoute(builder: (context) {
            //       return const SignIn();
            //     }));
            //   });
            // },
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 0),
            child: Container(
              padding:
                  const EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white70,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      onTapOutside: (event) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      autofocus: true,
                      onChanged: (value) async {
                        await initialSearch(value);
                      },
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search User',
                          hintStyle: TextStyle(
                              color: Colors.black45,
                              fontSize: 18,
                              fontWeight: FontWeight.w500)),
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      search = true;
                      setState(
                        () {},
                      );
                    },
                    child: const Icon(
                      Icons.search,
                      size: 30,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.795,
            decoration: const BoxDecoration(
                color: Color.fromARGB(255, 230, 229, 231),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: ListView(
                // controller: ScrollController(keepScrollOffset: true),
                padding: const EdgeInsets.only(left: 10, right: 10),
                // primary: false,
                // physics: const AlwaysScrollableScrollPhysics(
                //     parent: ScrollPhysics()),
                children: tempSearchStore.map((element) {
                  return buildResultCard(element);
                }).toList()),
          ),
        ],
      ),
    );
  }

  Widget buildResultCard(data) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          decoration: BoxDecoration(
              // gradient: const LinearGradient(
              //   begin: Alignment.topRight,
              //   end: Alignment.bottomLeft,
              //   colors: [
              //     Color.fromARGB(255, 195, 226, 196),
              //     Colors.blue,
              //   ],
              // ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                    color: Colors.black54,
                    blurRadius: 5.0,
                    spreadRadius: 1,
                    offset: Offset(0, 3))
              ],
              color: const Color.fromARGB(255, 181, 151, 217),
              borderRadius: BorderRadius.circular(18)),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return ChatPage(
                      type: data['Type'],
                      name: data['Name'],
                      profileurl: data['Photo'],
                      username: data['username'],
                      page: 'Search',
                      userUid: data['Id'],
                    );
                  }));
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    data['Photo'].toString().isEmpty ||
                            data['Photo'].length == 0
                        ? Container(
                            alignment: Alignment.center,
                            height: 40,
                            width: 40,
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
                            child: Text(
                              noPhoto(data['Name']),
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 19, 47, 94)),
                            ))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.network(
                              data['Photo'],
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                    const SizedBox(width: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['Name'],
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          data['E-mail'],
                          style: const TextStyle(
                              color: Colors.black45,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.person,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername, time;
  const ChatRoomListTile(
      {super.key,
      required this.chatRoomId,
      required this.lastMessage,
      required this.myUsername,
      required this.time});

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = '', name = '', username = '', id = '';

  noPhoto(xName) {
    String initial = '';
    var splitName = xName.split(' ');
    splitName.length > 1
        ? initial = splitName[0].substring(0, 1).toUpperCase() +
            splitName[1].substring(0, 1).toUpperCase()
        : initial = splitName[0].substring(0, 1).toUpperCase();
    return initial;
  }

  getthisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll('_', '').replaceAll(widget.myUsername, '');
    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username);
    name = "${querySnapshot.docs[0]['Name']}";
    profilePicUrl = "${querySnapshot.docs[0]['Photo']}";
    id = "${querySnapshot.docs[0]['Id']}";
    setState(() {});
  }

  @override
  void initState() {
    getthisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          profilePicUrl.toString().isEmpty || profilePicUrl.isEmpty
              ? Container(
                  alignment: Alignment.center,
                  height: 60,
                  width: 60,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  child: Text(
                    noPhoto(name),
                    style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 19, 47, 94)),
                  ))
              : ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.network(
                    profilePicUrl,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                widget.lastMessage,
                style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Spacer(),
          Text(
            widget.time,
            style: const TextStyle(
                color: Colors.black45,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
