import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:messagingapp/group_maint/add_member.dart';
import 'package:messagingapp/screens/chat_home.dart';
import 'package:messagingapp/service/database.dart';
import 'package:random_string/random_string.dart';

class GroupMaintenance extends StatefulWidget {
  final String groupName, groupId;

  const GroupMaintenance(
      {required this.groupName, required this.groupId, Key? key})
      : super(key: key);

  @override
  State<GroupMaintenance> createState() => _GroupMaintenanceState();
}

class _GroupMaintenanceState extends State<GroupMaintenance> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _editGroupName = TextEditingController();
  bool isEditGroupName = false;
  List membersList = [];
  bool isLoading = true;
  bool logAsAdmin = false;
  String newMessageId = '';

  @override
  void initState() {
    super.initState();
    getGroupMembers();
    _editGroupName.text = widget.groupName;
  }

  void getGroupMembers() async {
    await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .get()
        .then((value) {
      setState(() {
        membersList = value['members'];
        isLoading = false;
      });
    });

    membersList.sort(((a, b) {
      int sortMember = a['isAdmin'].compareTo(b['isAdmin']);
      if (sortMember == 0) {
        return a['Name'].compareTo(b['Name']);
      }
      log('$membersList');
      var searchAdmin =
          membersList.firstWhere((dropdown) => dropdown['isAdmin'] == 'Admin');
      logAsAdmin = searchAdmin['Name'] == _auth.currentUser!.displayName;
      return sortMember;
    }));
  }

  void showWarningDialog(alertText, alertType, int index) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(
              alertText,
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color.fromARGB(255, 64, 21, 138)),
            ),
            actions: [
              ElevatedButton(
                  onPressed: (() {
                    alertType == 'Remove' ? removeUser(index) : onLeaveGroup();
                    Navigator.of(context).pop();
                  }),
                  child: const Text('Yes')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('No'))
            ],
          );
        });
  }

  void removeUser(int index) async {
    setState(() {
      isLoading = true;
    });
    String uid = membersList[index]['uid'];
    String removeUserName = membersList[index]['Name'];

    membersList.removeAt(index);
    await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .update({'members': membersList});

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('groups')
        .doc(widget.groupId)
        .delete();

    newMessageId = genMsgID();
    DateTime now = DateTime.now();
    String formatedDate = DateFormat('dd-MM-yyyy HH:mm').format(now);
    Map<String, dynamic> chatData = {
      'sendBy': 'Administrator',
      'message':
          '${_auth.currentUser!.displayName} Remove $removeUserName from group.',
      'time': FieldValue.serverTimestamp(),
      'imgUrl': '',
      'cread': '',
      'ts': formatedDate,
      'type': 'notify',
      'alias': '',
      'messageId': '',
      'status': '',
      'statusTime': ''
    };
    DatabaseMethods()
        .addMessage('groups', widget.groupId, newMessageId, chatData);
    setState(() {
      isLoading = false;
    });
  }

  void changeGroupName() async {
    setState(() {
      isEditGroupName = false;
    });
    await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .update({'groupName': _editGroupName.text});

    await _firestore
        .collection('users')
        .doc(widget.groupId)
        .update({'Name': _editGroupName.text});

    for (int i = 0; i < membersList.length; i++) {
      await _firestore
          .collection('users')
          .doc(membersList[i]['uid'])
          .collection('groups')
          .doc(widget.groupId)
          .update({'Name': _editGroupName.text});
    }
  }

  genMsgID() {
    return randomAlphaNumeric(10);
  }

  void onLeaveGroup() async {
    setState(() {
      isLoading = true;
    });
    String uid = _auth.currentUser!.uid;
    for (int i = 0; i < membersList.length; i++) {
      if (membersList[i]['uid'] == uid) {
        membersList.removeAt(i);
        break;
      }
    }
    await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .update({'members': membersList});

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('groups')
        .doc(widget.groupId)
        .delete();

    var newMessageId = genMsgID();
    DateTime now = DateTime.now();
    String formatedDate = DateFormat('dd-MM-yyyy HH:mm').format(now);
    Map<String, dynamic> chatData = {
      'sendBy': 'Administrator',
      'message': '${_auth.currentUser!.displayName} Leave group.',
      'time': FieldValue.serverTimestamp(),
      'imgUrl': '',
      'cread': '',
      'ts': formatedDate,
      'type': 'notify',
      'alias': '',
      'messageId': '',
      'status': '',
      'statusTime': ''
    };
    DatabaseMethods()
        .addMessage('groups', widget.groupId, newMessageId!, chatData);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ChatHomePage()),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChatHomePage()));
              },
              icon: const Icon(Icons.arrow_back_ios)),
          title: const Text('Group Maintenance...'),
          centerTitle: true,
        ),
        body: isLoading
            ? Container(
                height: size.height,
                width: size.width,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: size.height / 8,
                    width: size.width / 1.1,
                    child: Row(children: [
                      Container(
                        height: size.height / 11,
                        width: size.width / 11,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                        child: Icon(
                          Icons.group,
                          color: Colors.white,
                          size: size.width / 10,
                        ),
                      ),
                      const SizedBox(width: 10),
                      isEditGroupName
                          ? Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                width: size.width * 0.5,
                                decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 220, 220, 220),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: TextField(
                                  maxLines: null,
                                  controller: _editGroupName,
                                  style: const TextStyle(
                                      fontSize: 19,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            )
                          : Expanded(
                              child: Text(
                                _editGroupName.text,
                                // widget.groupName,
                                style: const TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.w500),
                              ),
                            ),
                      isEditGroupName
                          ? Container(
                              width: size.width * 0.09,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 3,
                                    color:
                                        const Color.fromARGB(255, 18, 86, 20)),
                                shape: BoxShape.circle,
                                color: const Color.fromARGB(255, 255, 255, 255),
                              ),
                              child: IconButton(
                                color: const Color.fromARGB(255, 18, 86, 20),
                                onPressed: () {
                                  setState(() {
                                    changeGroupName();
                                  });
                                },
                                icon: const Icon(Icons.done, size: 20),
                              ),
                            )
                          : const SizedBox(),
                      isEditGroupName
                          ? Container(
                              width: size.width * 0.09,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 3,
                                    color:
                                        const Color.fromARGB(255, 153, 26, 26)),
                                shape: BoxShape.circle,
                                color: const Color.fromARGB(255, 255, 255, 255),
                              ),
                              child: IconButton(
                                color: const Color.fromARGB(255, 153, 26, 26),
                                onPressed: () {
                                  setState(() {
                                    isEditGroupName = false;
                                  });
                                },
                                icon: const Icon(Icons.close, size: 20),
                              ),
                            )
                          : logAsAdmin
                              ? Container(
                                  height: 40,
                                  width: 40,
                                  decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 95, 57, 167),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  child: IconButton(
                                    color: Colors.amber,
                                    onPressed: () {
                                      setState(() {
                                        isEditGroupName = true;
                                        // _editGroupName.text = widget.groupName;
                                      });
                                    },
                                    icon: const Icon(Icons.edit, size: 20),
                                  ),
                                )
                              : const SizedBox(),
                    ]),
                  ),
                  SizedBox(
                    width: size.width / 1.1,
                    child: Text(
                      '${membersList.length} Members',
                      style: TextStyle(
                        fontSize: size.width / 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  logAsAdmin
                      ? ListTile(
                          onTap: () =>
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => AddMembersInGroup(
                                        groupId: widget.groupId,
                                        groupName: _editGroupName
                                            .text, //widget.groupName,
                                        membersList: membersList,
                                      ))),
                          leading: const Icon(
                            Icons.add,
                            color: Colors.black,
                          ),
                          title: const Text('Add Members',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w500)),
                        )
                      : const SizedBox(),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ListView.builder(
                      itemCount: membersList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: (() {}),
                          leading: const Icon(Icons.account_circle),
                          title: Text(
                            membersList[index]['Name'],
                            style: TextStyle(
                                fontSize: size.width / 25,
                                fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            membersList[index]['E-mail'],
                            style: TextStyle(
                                fontSize: size.width / 27,
                                fontWeight: FontWeight.w500),
                          ),
                          trailing: Row(
                            textBaseline: TextBaseline.ideographic,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                membersList[index]['isAdmin'],
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: size.width / 27,
                                    fontWeight: FontWeight.w500),
                              ),
                              logAsAdmin
                                  ? membersList[index]['isAdmin'] == 'Admin'
                                      ? const Icon(Icons.close,
                                          color: Colors.grey, size: 25)
                                      : GestureDetector(
                                          onTap: () => showWarningDialog(
                                              "Remove member ${membersList[index]['Name']}?",
                                              'Remove',
                                              index),
                                          child: const Icon(Icons.close,
                                              color: Colors.redAccent,
                                              size: 28),
                                        )
                                  : const SizedBox(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  logAsAdmin
                      ? ListTile(
                          onTap: (() {}),
                          leading: const Icon(
                            Icons.logout,
                            color: Colors.grey,
                          ),
                          title: Text(
                            'Leave Group',
                            style: TextStyle(
                              fontSize: size.width / 22,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListTile(
                          onTap: () =>
                              showWarningDialog('Leave Group?', 'Leave', 0),
                          leading: const Icon(
                            Icons.logout,
                            color: Colors.redAccent,
                          ),
                          title: Text(
                            'Leave Group',
                            style: TextStyle(
                              fontSize: size.width / 22,
                              fontWeight: FontWeight.w500,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                ],
              )),
      ),
    );
  }
}
