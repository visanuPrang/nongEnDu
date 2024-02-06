import 'package:messagingapp/pages/create_group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messagingapp/screens/chat_home.dart';

class EditGroup extends StatefulWidget {
  const EditGroup({Key? key}) : super(key: key);

  @override
  State<EditGroup> createState() => _EditGroupState();
}

class _EditGroupState extends State<EditGroup> {
  final TextEditingController _search = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> membersList = [];
  bool isLoading = false;
  Map<String, dynamic>? userMap;
  Map<String, dynamic>? userListInGroup;

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
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

  void listUserInGroup() async {
    await _firestore
        // .collection('users')
        // .doc('*')
        .collection('groups')
        // .where('Id', isEqualTo: '9DUC4Z5MIuYOy6wfZwMQ1xUaUYm1')
        .get()
        .then((value) {
      setState(() {
        userListInGroup = value.docs[0].data();
      });
    });
    debugPrint('userListInGroup==>$userListInGroup');
  }

// 128e22b0-5689-1e77-bf31-d7c3c97c3626
  void getCurrentUserDetails() async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((map) {
      setState(() {
        membersList.add({
          "Name": map['Name'],
          "E-mail": map['E-mail'],
          "uid": map['Id'],
          "Photo": map['Photo'],
          "isAdmin": true,
        });
      });
    });
  }

  void onSearch() async {
    listUserInGroup();
    setState(() {
      isLoading = true;
    });
    await _firestore
        .collection('users')
        .where("E-mail", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        _search.text = '';
      });
    });
    isLoading = false;
  }

  void onResultTap() {
    bool isAlreadyExist = false;
    // debugPrint('1userMap$userMap');
    for (int i = 0; i < membersList.length; i++) {
      if (membersList[i]['uid'] == userMap!['Id']) {
        isAlreadyExist = true;
      }
    }

    if (!isAlreadyExist) {
      setState(() {
        membersList.add({
          "Name": userMap!['Name'],
          "E-mail": userMap!['E-mail'],
          "uid": userMap!['Id'],
          "Photo": userMap!['Photo'],
          "isAdmin": false,
        });

        userMap = null;
      });
    }
    // debugPrint('membersList$membersList');
  }

  void onRemoveMembers(int index) {
    if (membersList[index]['uid'] != _auth.currentUser!.uid) {
      setState(() {
        membersList.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined,
              color: Colors.black87),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ChatHomePage()));
          },
        ),
        title: const Text("Add Members"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ListView.builder(
                itemCount: membersList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () => onRemoveMembers(index),
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
                    trailing: index == 0
                        ? const Text(
                            'Admin',
                            style: TextStyle(
                                color: Color.fromARGB(255, 95, 57, 167)),
                          )
                        : const Icon(Icons.close),
                  );
                },
              ),
            ),
            SizedBox(
              height: size.height / 20,
            ),
            SizedBox(
              height: size.height / 13,
              width: size.width / 1.2,
              child: TextField(
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
                  hintText: "Search",
                  hintStyle:
                      const TextStyle(color: Color.fromARGB(255, 95, 57, 167)),
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
            SizedBox(height: size.height * 0.005),
            if (isLoading)
              Container(
                height: size.height / 12,
                width: size.height,
                alignment: Alignment.center,
                child: Text(
                    '${_search.text} Not found.'), //const CircularProgressIndicator(),
              )
            else
              Container(
                height: size.height / 12,
                width: size.height,
                alignment: Alignment.center,
                child: const Text(''), //const CircularProgressIndicator(),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  side: const BorderSide(
                      width: 1, color: Color.fromARGB(255, 95, 57, 167)),
                  backgroundColor: const Color.fromARGB(255, 220, 212, 245),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  shadowColor: const Color.fromARGB(255, 71, 58, 96),
                  elevation: 5),
              onPressed: onSearch,
              child: const Text("Search"),
            ),
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
                    trailing: const Icon(Icons.add),
                  )
                : const SizedBox(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: membersList.length >= 2
          ? FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 66, 7, 202),
              tooltip: 'Create group.',
              shape: const CircleBorder(side: BorderSide.none),
              child: Container(
                height: 45,
                width: 45,
                decoration: const BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: const Icon(Icons.forward),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreateGroup(
                    membersList: membersList,
                  ),
                ),
              ),
            )
          : const SizedBox(),
    );
  }
}
