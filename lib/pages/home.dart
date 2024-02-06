import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:draggable_fab/draggable_fab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messagingapp/group_chats/group_chat_room.dart';
import 'package:messagingapp/pages/chatpage.dart';
import 'package:messagingapp/pages/searchpage.dart';
import 'package:messagingapp/service/database.dart';
import 'package:messagingapp/service/shared_pref.dart';

void main() {
  runApp(const Home());
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> currUser = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var allUserResultSet = [];
  bool isLoading = true;

  noPhoto(xName) {
    String initial = '';
    var splitName = xName.split(' ');
    splitName.length > 1
        ? initial = splitName[0].substring(0, 1).toUpperCase() +
            splitName[1].substring(0, 1).toUpperCase()
        : initial = splitName[0].substring(0, 1).toUpperCase();
    return initial;
  }

  getCurrentUserDetails() async {
    currUser.clear();
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((map) {
      currUser.add({
        "Name": map['Name'],
        "E-mail": map['E-mail'],
        "uid": map['Id'],
        "Photo": map['Photo'],
        "isAdmin": true,
      });
    });
    // debugPrint('function==>$currUser');
  }

  Future<QuerySnapshot> chkUserIsInGroup(String userId) async {
    //, String gId) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('groups')
        // .where('Id', isEqualTo: gId)
        .get();
  }

  Future<QuerySnapshot> getGroupId(String userId, String gId) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('groups')
        .where('Id', isEqualTo: gId)
        .get();
  }

  listAllUser() async {
    // isLoading = true;
    allUserResultSet.clear();
    await DatabaseMethods().getAllUser().then((QuerySnapshot docs) async {
      for (int i = 0; i < docs.docs.length; ++i) {
        if (docs.docs[i]['Name'] != myName) {
          allUserResultSet.add(docs.docs[i].data());
        }
      }
    });
    //remove duplicate
    var seen = <String>{};
    List unique = allUserResultSet
        .where((allUserResultSet) => seen.add(allUserResultSet['Name']))
        .toList();
    allUserResultSet = unique;
    // sort assending
    allUserResultSet.sort((a, b) => a["Name"].compareTo(b["Name"]));
    // // sort descending
    // allUserResultSet.sort((a, b) => b["Name"].compareTo(a["Name"]));

    var getGroup = await chkUserIsInGroup(_auth.currentUser!.uid);
    var isInGroup = false;
    for (int i = 0; i < allUserResultSet.length; i++) {
      if (allUserResultSet[i]['recordType'] == 'Group') {
        for (int n = 0; n < getGroup.docs.length; n++) {
          if (allUserResultSet[i]['groupId'] == getGroup.docs[n]['Id']) {
            isInGroup = true;
            break;
          }
        }
        if (!isInGroup) {
          allUserResultSet.removeAt(i);
        }
        isInGroup = false;
      }
    }
    return allUserResultSet;
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

  Future ontheload() async {
    await getthesharedpref();
    chatRoomsStream = await DatabaseMethods().getChatRooms();
  }

  @override
  void initState() {
    // super.activate();
    super.initState();
    // Firebase.initializeApp();
    // FirebaseFirestore.setLoggingEnabled(true);
    // _firestore; //.settings.sslEnabled;
    ontheload();
    getCurrentUserDetails();
    listAllUser();
  }

  @override
  Widget build(BuildContext context) {
    Future refresh() async {
      setState(() {
        listAllUser();
      });
    }

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        //   floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
        floatingActionButton: DraggableFab(
          securityBottom: 110,
          child: FloatingActionButton(
              shape: const CircleBorder(side: BorderSide.none),
              backgroundColor: const Color.fromRGBO(82, 170, 94, 1.0),
              tooltip: 'Search.',
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchPage()));
              },
              child: const Icon(Icons.person_search_outlined,
                  size: 30, color: Colors.white)),
        ),
        backgroundColor: const Color.fromARGB(255, 231, 225, 236),
        body:
            // isLoading
            //     ? Container(
            //         // height: size.height,
            //         // width: size.width,
            //         alignment: Alignment.center,
            //         child: const CircularProgressIndicator(),
            //       )
            //     :
            Container(
                height: MediaQuery.of(context).size.height,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  // color: Color.fromARGB(255, 248, 214, 114),
                  image: DecorationImage(
                      opacity: 0.15,
                      image: AssetImage("images/NongEnDu_Tran.png"),
                      // image: NetworkImage(
                      //     'https://img.freepik.com/premium-vector/cute-little-student-girl-cartoon_96373-287.jpg'),
                      fit: BoxFit.cover),
                ),
                child: FutureBuilder(
                    future: listAllUser(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          return const Center(
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                  color: Color.fromARGB(255, 177, 21, 10)),
                            ),
                          );
                        case ConnectionState.waiting:
                          return const Center(
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                  color: Color.fromARGB(255, 73, 44, 2)),
                            ),
                          );
                        case ConnectionState.active:
                          return const Center(
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                  color: Color.fromARGB(255, 6, 6, 164)),
                            ),
                          );
                        case ConnectionState.done:
                          return RefreshIndicator(
                            onRefresh: refresh,
                            child: ListView.builder(
                              itemCount: allUserResultSet.length,
                              itemBuilder: (BuildContext context, int index) {
                                return buildUserList(allUserResultSet[index]);
                              },
                            ),
                          );
                      }
                    })),
      ),
    );
  }

  Widget buildUserList(data) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            data['recordType'] == 'Person'
                ? Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                    return ChatPage(
                        type: data['recordType'],
                        name: data['Name'],
                        profileurl: data['Photo'],
                        username: data['username'],
                        page: 'Home');
                  }))
                : Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GroupChatRoom(
                        groupName: data['Name'],
                        groupChatId: data['groupId'],
                        currUser: '$currUser',
                      ),
                    ),
                  );
          },
          child: data['recordType'] == 'Person'
              ? Row(
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
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 19, 47, 94)),
                            ))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.network(
                              data['Photo'],
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                    const SizedBox(width: 5),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .65,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
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
                                Divider(
                                  thickness: 1.5,
                                  color: Colors.black.withOpacity(0.3),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    data['recordType'] == 'Person'
                        ? const Icon(
                            Icons.person,
                            color: Colors.black45,
                          )
                        : const Icon(
                            Icons.group,
                            color: Colors.black45,
                          )
                  ],
                )
              : Row(
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
                            child: const Icon(Icons.group))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.network(
                              data['Photo'],
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                    const SizedBox(width: 5),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .65,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
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
                                  data['Admin'],
                                  style: const TextStyle(
                                      color: Colors.black45,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                Divider(
                                  thickness: 1.5,
                                  color: Colors.black.withOpacity(0.3),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.group_outlined,
                      color: Colors.black45,
                    )
                  ],
                ),
        ),
      ],
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
