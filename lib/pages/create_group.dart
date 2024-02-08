import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:messagingapp/screens/chat_home.dart';
import 'package:messagingapp/service/database.dart';
import 'package:uuid/uuid.dart';

class CreateGroup extends StatefulWidget {
  final List<Map<String, dynamic>> membersList;
  const CreateGroup({required this.membersList, Key? key}) : super(key: key);

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final TextEditingController _groupName = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  void createGroup() async {
    setState(() {
      isLoading = true;
    });

    String groupId = const Uuid().v1();

    await _firestore.collection('groups').doc(groupId).set({
      'members': widget.membersList,
      'Id': groupId,
      'groupName': _groupName.text,
      'Admin': _auth.currentUser!.displayName,
      'adminUID': _auth.currentUser!.uid,
      'Photo': ''
    });
    // add group into all user in group
    for (int i = 0; i < widget.membersList.length; i++) {
      String uid = widget.membersList[i]['uid'];
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('groups')
          .doc(groupId)
          .set({
        'Name': _groupName.text,
        'Id': groupId,
        'Admin': widget.membersList[0]['Name'],
        'Photo': ''
      });
    }
    var sendTime = DateFormat('kk:mm:ss').format(DateTime.now());
    var sendDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    //adding chats collaction
    await _firestore.collection('groups').doc(groupId).collection('chats').add({
      'sendBy': 'Administrator',
      'message': '${widget.membersList[0]['Name']} Created This Group.',
      'type': 'notify',
      'sendTime': sendTime,
      'sendDate': sendDate,
      'time': FieldValue.serverTimestamp()
    });

    Map<String, dynamic> userGroupInfoMap = {
      'recordType': 'Group',
      'Name': _groupName.text,
      'Admin': widget.membersList[0]['Name'],
      'adminUID': _auth.currentUser!.uid,
      'Photo': '',
      'groupId': groupId
    };

    await DatabaseMethods().addUserGroupDetails(userGroupInfoMap, groupId);

    //adding chats collaction
    // for (int i = 0; i < widget.membersList.length; i++) {
    //   await _firestore
    //       .collection('groups')
    //       .doc(groupId)
    //       .collection('members')
    //       .add({
    //     'memberName': widget.membersList[i]['Name'],
    //     'memberType': i == 0 ? 'Admin' : 'Member',
    //     'memberUID': widget.membersList[i]['uid'],
    //     'memberPhoto': widget.membersList[i]['Photo'],
    //     'memberDate': sendDate,
    //     'memberTime': sendTime,
    //     'createDateTime': FieldValue.serverTimestamp()
    //   });
    // }

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ChatHomePage()),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin: ${_auth.currentUser!.displayName}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
      body: isLoading
          ? Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          : Column(
              children: [
                SizedBox(
                  height: size.height / 10,
                ),
                Container(
                  height: size.height / 10,
                  width: size.width,
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: size.height / 10,
                    width: size.width / 1.15,
                    child: TextField(
                      maxLines: null,
                      expands: true,
                      controller: _groupName,
                      decoration: InputDecoration(
                        hintText: 'Enter Group Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height / 50,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0)),
                        side: const BorderSide(
                            width: 1, color: Color.fromARGB(255, 95, 57, 167)),
                        backgroundColor:
                            const Color.fromARGB(255, 220, 212, 245),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 10),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        shadowColor: const Color.fromARGB(255, 71, 58, 96),
                        elevation: 5),
                    onPressed: createGroup,
                    child: const Text('Create Group',
                        style: TextStyle(
                            color: Color.fromARGB(255, 36, 12, 79),
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
    );
  }
}
