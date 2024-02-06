import 'package:draggable_fab/draggable_fab.dart';
import 'package:messagingapp/group_chats/group_info.dart';
import 'package:messagingapp/group_maint/add_group.dart';
import 'package:messagingapp/group_chats/group_chat_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  List groupList = [];

  @override
  void initState() {
    super.initState();
    getAvailableGroups();
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

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: isLoading
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
                        borderRadius: BorderRadius.all(Radius.circular(30))),
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
                    return ListTile(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => GroupChatRoom(
                                groupName: groupList[index]['Name'],
                                groupChatId: groupList[index]['Id'],
                                currUser: '$currUser')),
                      ),
                      leading: groupList[index]['Photo'].toString().isEmpty ||
                              groupList[index]['Photo'].length == 0
                          ? Container(
                              alignment: Alignment.center,
                              height: 45,
                              width: 45,
                              decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 192, 163, 245),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                              child: const Icon(
                                Icons.group,
                                size: 30,
                              ))
                          : Container(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.network(
                                  groupList[index]['Photo'],
                                  height: 40,
                                  width: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(groupList[index]['Name']),
                          ),
                        ],
                      ),
                      subtitle: Text("Owner: ${groupList[index]['Admin']}"),
                      trailing: Container(
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 95, 57, 167),
                            borderRadius:
                                BorderRadius.all(Radius.circular(30))),
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
                    );
                  },
                ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: DraggableFab(
        securityBottom: 110,
        child: FloatingActionButton(
          mini: false,
          shape: const CircleBorder(side: BorderSide.none),
          backgroundColor: const Color.fromARGB(255, 110, 167, 57),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CreateNewGroup(),
            ),
          ),
          tooltip: "Create Group",
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
              icon: const Icon(Icons.add, size: 25),
            ),
          ),
        ),
      ),
    );
  }
}
