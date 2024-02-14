import 'package:draggable_fab/draggable_fab.dart';
import 'package:messagingapp/group_chats/group_info.dart';
import 'package:messagingapp/group_maint/add_group.dart';
import 'package:messagingapp/group_chats/group_chat_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messagingapp/helper/my_date_util.dart';
import 'package:messagingapp/service/database.dart';

class GroupList extends StatefulWidget {
  const GroupList({Key? key}) : super(key: key);

  @override
  _GroupListState createState() => _GroupListState();
  // State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;
  List<Map<String, dynamic>> currUser = [];
  String showLastMessage = '';

  List groupList = [];
  var lastMessageMap = [];

  @override
  void initState() {
    super.initState();
    getAvailableGroups();
    listAllLastMessage();
  }

  noPhoto(xName) {
    String initial = '';
    var splitName = xName.split(' ');
    splitName.length > 1
        ? initial = splitName[0].substring(0, 1) + splitName[1].substring(0, 1)
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
        'Name': map['Name'],
        'E-mail': map['E-mail'],
        'uid': map['Id'],
        'Photo': map['Photo'],
        'isAdmin': true,
      });
    });
  }

  void getAvailableGroups() async {
    String uid = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('groups')
        .get()
        .then((value) {
      setState(() {
        groupList = value.docs;
        isLoading = false;
      });
    });
  }

  listAllLastMessage() async {
    // lastMessageMap.clear();
    await DatabaseMethods()
        .getAllLastMessage('A01 EnDu School_P01 EnDu School')
        .then((QuerySnapshot docs) async {
      for (int i = 0; i < docs.docs.length; ++i) {
        lastMessageMap.add(docs.docs[i].data());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Future refresh() async {
      setState(() {
        // initState();
        getAvailableGroups();
        getCurrentUserDetails();
        listAllLastMessage();
      });
    }

    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: refresh,
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
          child: isLoading
              ? Container(
                  height: size.height,
                  width: size.width,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                )
              : groupList.isEmpty
                  ? Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.2,
                        width: MediaQuery.of(context).size.width * 0.95,
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 95, 57, 167),
                            borderRadius:
                                BorderRadius.all(Radius.circular(30))),
                        alignment: Alignment.center,
                        child: const Text(
                          textAlign: TextAlign.center,
                          'Not a member in any group.\nTo create group click on "+" button below.',
                          style: TextStyle(
                              fontSize: 19,
                              color: Color.fromARGB(255, 181, 170, 201)),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: groupList.length,
                      itemBuilder: (context, index) {
                        listAllLastMessage();
                        var inArray = lastMessageMap.length + 1;
                        var myName = _auth.currentUser!.displayName;
                        for (int i = 0; i < lastMessageMap.length; i++) {
                          if (lastMessageMap[i]['chatRoomId'] ==
                              groupList[index]['Id']) {
                            inArray = i;
                            break;
                          }
                        }
                        showLastMessage = '';
                        if (inArray < lastMessageMap.length) {
                          if (lastMessageMap[inArray]['type'] == 'text') {
                            showLastMessage =
                                lastMessageMap[inArray]['lastMessage'];
                          } else if (lastMessageMap[inArray]['type'] ==
                              'image') {
                            if (lastMessageMap[inArray]['lastMessageSendBy'] ==
                                myName) {
                              showLastMessage = 'You send a photo.';
                            } else {
                              showLastMessage =
                                  "${lastMessageMap[inArray]['lastMessageSendBy']} send a photo.";
                            }
                          } else if (lastMessageMap[inArray]['type'] ==
                              'sticker') {
                            if (lastMessageMap[inArray]['lastMessageSendBy'] ==
                                myName) {
                              showLastMessage = 'You send a sticker.';
                            } else {
                              showLastMessage =
                                  "${lastMessageMap[inArray]['lastMessageSendBy']} send a sticker.";
                            }
                          } else {
                            if (lastMessageMap[inArray]['lastMessageSendBy'] ==
                                myName) {
                              showLastMessage = 'You send a file.';
                            } else {
                              showLastMessage =
                                  "${lastMessageMap[inArray]['lastMessageSendBy']} send a file.";
                            }
                          }
                        }
                        return ListTile(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => GroupChatRoom(
                                    groupName: groupList[index]['Name'],
                                    groupChatId: groupList[index]['Id'],
                                    currUser: '$currUser')),
                          ),
                          leading: groupList[index]['Photo']
                                      .toString()
                                      .isEmpty ||
                                  groupList[index]['Photo'].length == 0
                              ? Container(
                                  alignment: Alignment.center,
                                  height: 40,
                                  width: 40,
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  child: Text(
                                    noPhoto(groupList[index]['Name']),
                                    style: const TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 19, 47, 94)),
                                  ))
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Image.network(
                                    groupList[index]['Photo'],
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(groupList[index]['Name'],
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          subtitle: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  showLastMessage,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                ),
                              ),
                              // const Spacer(),
                              Text(
                                  inArray > lastMessageMap.length
                                      ? ''
                                      : MyDateUtil.getLastMessageTime(
                                          context: context,
                                          time: lastMessageMap[inArray]['time']
                                              .millisecondsSinceEpoch),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.black45,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          trailing: SizedBox(
                            height: 40,
                            width: 40,
                            child: Column(
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color.fromARGB(255, 95, 57, 167),
                                    // borderRadius: BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: IconButton(
                                    color: Colors.amber,
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => GroupMaintenance(
                                          groupName: groupList[index]['Name'],
                                          groupId: groupList[index]['Id'],
                                        ),
                                      ),
                                    ),
                                    icon: const Icon(Icons.edit, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: DraggableFab(
        securityBottom: 110,
        child: FloatingActionButton(
          mini: false,
          shape: const CircleBorder(
              side: BorderSide(
                  width: 6,
                  color: Color.fromRGBO(82, 170, 94, 1.0),
                  strokeAlign: BorderSide.strokeAlignInside)),
          backgroundColor: Colors.white,
          tooltip: "Create Group",
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CreateNewGroup(),
            ),
          ),
          child: Container(
            height: 45,
            width: 45,
            decoration: const BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 1),
                borderRadius: BorderRadius.all(Radius.circular(30))),
            child: IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CreateNewGroup(),
                ),
              ),
              icon: Text(
                String.fromCharCode(Icons.add.codePoint),
                style: TextStyle(
                  color: const Color.fromARGB(255, 2, 42, 7),
                  inherit: false,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  fontFamily: Icons.add.fontFamily,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
