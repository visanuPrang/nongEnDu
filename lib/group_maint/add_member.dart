import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:messagingapp/group_chats/group_info.dart';
import 'package:messagingapp/service/database.dart';
import 'package:random_string/random_string.dart';

class AddMembersInGroup extends StatefulWidget {
  final String groupName, groupId;
  final List membersList;
  const AddMembersInGroup(
      {required this.membersList,
      required this.groupName,
      required this.groupId,
      Key? key})
      : super(key: key);

  @override
  State<AddMembersInGroup> createState() => _AddMembersInGroupState();
}

class _AddMembersInGroupState extends State<AddMembersInGroup> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _search = TextEditingController();
  List membersList = [];
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  String newMessageId = '';

  @override
  void initState() {
    super.initState();
    membersList = widget.membersList;
  }

  noPhoto(xName) {
    String initial = '';
    var splitName = xName.split(' ');
    splitName.length > 1
        ? initial = splitName[0].substring(0, 1).toUpperCase() +
            splitName[1].substring(0, 1).toUpperCase()
        : initial = splitName[0].substring(0, 1).toUpperCase();
    return initial;
  }

  void onSearch() async {
    setState(() {
      isLoading = true;
    });
    _search.text.isEmpty
        ? setState(() {
            isLoading = false;
          })
        : await _firestore
            .collection('users')
            .where('E-mail', isEqualTo: _search.text)
            .get()
            .then((value) {
            value.docs.isNotEmpty
                ? setState(() {
                    userMap = value.docs[0].data();
                    _search.text = '';
                    isLoading = false;
                  })
                : userMap = null;
          });
    isLoading = false;
  }

  void onResultTap() {
    bool isAlreadyExist = false;
    for (int i = 0; i < membersList.length; i++) {
      if (membersList[i]['uid'] == userMap!['Id']) {
        isAlreadyExist = true;
      }
    }

    if (!isAlreadyExist) {
      setState(() {
        membersList.add({
          'Name': userMap!['Name'],
          'E-mail': userMap!['E-mail'],
          'uid': userMap!['Id'],
          'Photo': userMap!['Photo'],
          'isAdmin': 'New'
          // _auth.currentUser!.uid == userMap!['Id'] ? 'Admin' : 'Member',
        });

        userMap = null;
      });
    }
  }

  genMsgID() {
    return randomAlphaNumeric(10);
  }

  void onAddMembers() async {
    for (int i = 0; i < membersList.length; i++) {
      if (membersList[i]['isAdmin'] == 'New') {
        await _firestore
            .collection('users')
            .doc(membersList[i]['uid'])
            .collection('groups')
            .doc(widget.groupId)
            .set({
          'Admin': _auth.currentUser!.displayName,
          'Id': widget.groupId,
          'Name': widget.groupName,
          'Photo': ''
        });

        newMessageId = genMsgID();
        DateTime now = DateTime.now();
        String formatedDate = DateFormat('dd-MM-yyyy HH:mm').format(now);
        Map<String, dynamic> chatData = {
          'sendBy': 'Administrator',
          'message':
              '${_auth.currentUser!.displayName} Add ${membersList[i]['Name']} in group.',
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
      }
    }
    for (int i = 0; i < membersList.length; i++) {
      if (membersList[i]['isAdmin'] == 'New') {
        membersList[i]['isAdmin'] = 'Member';
      }
    }
    await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .update({'members': membersList});

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (_) => GroupMaintenance(
                groupName: widget.groupName, groupId: widget.groupId)),
        (route) => false);
  }

  void removeFromList(int index) {
    setState(() => membersList.removeAt(index));
  }

  void onCencel() {
    for (int i = 0; i < membersList.length; i++) {
      if (membersList[i]['isAdmin'] == 'New') {
        setState(() => membersList.removeAt(i));
      }
    }
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (_) => GroupMaintenance(
                groupName: widget.groupName, groupId: widget.groupId)),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('Add Members'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 15),
                  height: size.height / 13,
                  width: size.width / 1.2,
                  alignment: Alignment.center,
                  child: TextField(
                    autofocus: true,
                    onChanged: (value) {
                      setState(() {
                        isLoading = false;
                      });
                    },
                    controller: _search,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromARGB(255, 220, 212, 245),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Color.fromARGB(255, 95, 57, 167),
                      ),
                      hintText: 'Search',
                      hintStyle: const TextStyle(
                          color: Color.fromARGB(255, 95, 57, 167)),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          style: BorderStyle.solid,
                          width: 5,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  height: size.height / 12,
                  width: size.height,
                  alignment: Alignment.center,
                  child: Text(
                      '${_search.text} Not found.'), //const CircularProgressIndicator(),
                )
              else
                userMap != null
                    ? ListTile(
                        onTap: onResultTap,
                        leading: userMap!['Photo'].toString().isEmpty ||
                                userMap!['Photo'].length == 0
                            ? Container(
                                alignment: Alignment.center,
                                height: 40,
                                width: 40,
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30))),
                                child: Text(
                                  noPhoto(userMap!['Name']),
                                  style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 19, 47, 94)),
                                ))
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.network(
                                  userMap!['Photo'],
                                  height: 40,
                                  width: 40,
                                  fit: BoxFit.cover,
                                ),
                              ),
                        title: Text(userMap!['Name']),
                        subtitle: Text(userMap!['E-mail']),
                        trailing: const Icon(
                          size: 30,
                          Icons.add,
                          color: Color.fromARGB(255, 95, 57, 167),
                        ),
                      )
                    : const SizedBox(),
              SizedBox(height: size.height * 0.005),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    side: const BorderSide(
                        width: 1, color: Color.fromARGB(255, 95, 57, 167)),
                    backgroundColor: const Color.fromARGB(255, 220, 212, 245),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 10),
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    shadowColor: const Color.fromARGB(255, 71, 58, 96),
                    elevation: 5),
                onPressed: onSearch,
                child: const Text('Search',
                    style: TextStyle(color: Color.fromARGB(255, 29, 6, 67))),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: size.width * 0.1),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        side: const BorderSide(
                            width: 1, color: Color.fromARGB(255, 3, 24, 141)),
                        backgroundColor:
                            const Color.fromARGB(255, 177, 186, 239),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 10),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        shadowColor: const Color.fromARGB(255, 71, 58, 96),
                        elevation: 5),
                    onPressed: onAddMembers,
                    child: const Text(
                      'Update Group',
                      style: TextStyle(color: Color.fromARGB(255, 3, 24, 141)),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        side: const BorderSide(
                            width: 1, color: Color.fromARGB(255, 122, 33, 33)),
                        backgroundColor:
                            const Color.fromARGB(255, 255, 234, 234),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 10),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        shadowColor: const Color.fromARGB(255, 71, 58, 96),
                        elevation: 5),
                    onPressed: onCencel,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Color.fromARGB(255, 122, 33, 33)),
                    ),
                  ),
                  SizedBox(width: size.width * 0.1),
                ],
              ),
              SizedBox(
                height: size.height / 20,
              ),
              Flexible(
                child: ListView.builder(
                  itemCount: membersList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {}, //  => onRemoveMembers(index),
                      leading: membersList[index]['Photo'].toString().isEmpty ||
                              membersList[index]['Photo'].length == 0
                          ? Container(
                              alignment: Alignment.center,
                              height: 40,
                              width: 40,
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                              child: Text(
                                noPhoto(membersList[index]['Name']),
                                style: const TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 19, 47, 94)),
                              ))
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.network(
                                membersList[index]['Photo'],
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                      title: Text("${membersList[index]['Name']}"),
                      subtitle: Text(membersList[index]['E-mail']),
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
                                fontWeight: FontWeight.w500,
                                color: membersList[index]['isAdmin'] == 'New'
                                    ? Colors.blueAccent
                                    : Colors.black87),
                          ),
                          membersList[index]['isAdmin'] == 'New'
                              ? GestureDetector(
                                  onTap: () => removeFromList(index),
                                  child: const Icon(Icons.close,
                                      color: Colors.redAccent, size: 25),
                                )
                              : const SizedBox()
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
