import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messagingapp/group_chats/group_info.dart';

// ignore: must_be_immutable
class GroupChatRoom extends StatefulWidget {
  final String groupChatId, groupName, currUser;
  const GroupChatRoom(
      {required this.groupName,
      required this.groupChatId,
      required this.currUser,
      Key? key})
      : super(key: key);

  @override
  State<GroupChatRoom> createState() => _GroupChatRoomState();
}

class _GroupChatRoomState extends State<GroupChatRoom> {
  final TextEditingController _message = TextEditingController();
  final TextEditingController chatMessage = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> currUser = [];

  bool isLoading = false;

  Map<String, dynamic>? userMap;

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

  initSRDate(pDate) {
    String todayDate =
        DateFormat('dd-MM-yyyy').format(DateTime.now()).toString();
    String showSRDate = '';
    var splitDateTime = pDate.split(' ');
    splitDateTime.length > 1
        ? todayDate == splitDateTime[0]
            ? showSRDate = splitDateTime[1]
            : showSRDate = '${splitDateTime[0]}\n${splitDateTime[1]}'
        : showSRDate = splitDateTime[0];
    return showSRDate;
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

  void onSendMessage() async {
    // ignore: unused_local_variable
    final User? user = _auth.currentUser;
    var sendTime = DateFormat('kk:mm:ss').format(DateTime.now());
    var sendDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    DateTime now = DateTime.now();
    String formatedDate = DateFormat('dd-MM-yyyy HH:mm').format(now);

    if (_message.text.isNotEmpty) {
      Map<String, dynamic> chatData = {
        "imgUrl": currUser[0]['Photo'],
        "sendBy": _auth.currentUser!.displayName,
        "message": _message.text,
        'ts': formatedDate,
        'type': 'text',
        "read": '',
        "time": FieldValue.serverTimestamp()
      };

      _message.clear();

      await _firestore
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .add(chatData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
                child: Text(
              widget.groupName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            )),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GroupMaintenance(
                        groupName: widget.groupName,
                        groupId: widget.groupChatId,
                      ),
                    ),
                  ),
              icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: size.height / 1.27,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('groups')
                    .doc(widget.groupChatId)
                    .collection('chats')
                    .orderBy('time', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      reverse: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> chatMap =
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;

                        // if (currUser.isEmpty) {
                        //   getCurrentUserDetails();
                        // }
                        // debugPrint('usage==>$currUser');
                        return messageTile(size, chatMap, currUser);
                      },
                    );
                  } else {
                    return Center(
                      child: Text('${snapshot.data!.docs}'),
                    );
                  }
                },
              ),
            ),
            _chatInput()
            // Container(
            //   alignment: Alignment.bottomCenter,
            //   child: Material(
            //     // elevation: 5,
            //     // borderRadius: BorderRadius.circular(30),
            //     child: Container(
            //       margin:
            //           const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            //       // padding: const EdgeInsets.all(10),
            //       // decoration: BoxDecoration(
            //       //     color: const Color.fromARGB(176, 217, 233, 214),
            //       //     borderRadius: BorderRadius.circular(30)),
            //       child: TextField(
            //         maxLines: null,
            //         // expands: true,
            //         keyboardType: TextInputType.multiline,
            //         style: const TextStyle(fontSize: 16),
            //         controller: _message,
            //         decoration: InputDecoration(
            //             suffixIcon: IconButton(
            //               onPressed: () {},
            //               icon: const Icon(Icons.photo),
            //             ),
            //             hintText: "Send Message",
            //             border: OutlineInputBorder(
            //               borderRadius: BorderRadius.circular(8),
            //             )),
            //         // decoration: InputDecoration(
            //         //     border: InputBorder.none,
            //         //     hintText: 'Type a message',
            //         //     hintStyle: const TextStyle(color: Colors.black45),
            //         //     suffixIcon: GestureDetector(
            //         //       onTap: () {
            //         //         getCurrentUserDetails();
            //         //         onSendMessage();
            //         //       },
            //         //       child: const Icon(
            //         //         Icons.telegram,
            //         //         size: 45,
            //         //       ),
            //         //     )),
            //       ),
            //     ),
            //   ),
            // )
            // Container(
            //   height: size.height / 10,
            //   width: size.width,
            //   alignment: Alignment.center,
            //   child: SizedBox(
            //     height: size.height / 12,
            //     width: size.width / 1.1,
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Expanded(
            //           flex: 10,
            //           child: TextField(
            //             maxLines: null,
            //             expands: true,
            //             keyboardType: TextInputType.multiline,
            //             controller: _message,
            //             decoration: InputDecoration(
            //                 suffixIcon: IconButton(
            //                   onPressed: () {},
            //                   icon: const Icon(Icons.photo),
            //                 ),
            //                 hintText: "Send Message",
            //                 border: OutlineInputBorder(
            //                   borderRadius: BorderRadius.circular(8),
            //                 )),
            //           ),
            //         ),
            //         IconButton(
            //           icon: const Icon(
            //             Icons.telegram,
            //             size: 35,
            //           ),
            //           onPressed: () {
            //             getCurrentUserDetails();
            //             onSendMessage();
            //           },
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget messageTile(Size size, Map<String, dynamic> chatMap,
      List<Map<String, dynamic>> currUser) {
    final sendByMe = chatMap['sendBy'] == _auth.currentUser!.displayName;
    return Builder(builder: (_) {
      if (chatMap['type'] == "text") {
        chatMessage.text = chatMap['message'];
        return Row(
          mainAxisAlignment:
              sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            sendByMe
                ? const SizedBox()
                : chatMap['imgUrl'].isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.network(
                          chatMap['imgUrl'],
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        alignment: Alignment.center,
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 217, 201, 81),
                            borderRadius:
                                BorderRadius.all(Radius.circular(30))),
                        child: Text(
                          noPhoto(chatMap['sendBy']),
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 19, 47, 94)),
                        )),
            Container(
              alignment:
                  sendByMe ? Alignment.centerRight : Alignment.centerLeft,
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              child: Row(
                mainAxisAlignment:
                    sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  sendByMe
                      ? Text(
                          initSRDate(chatMap['ts']),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 10,
                          ),
                        )
                      : const SizedBox(),
                  Container(
                    // width: size.width * 0.65,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    margin: sendByMe
                        ? const EdgeInsets.only(left: 10)
                        : const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(15),
                            bottomRight: sendByMe
                                ? const Radius.circular(0)
                                : const Radius.circular(15),
                            topRight: const Radius.circular(15),
                            bottomLeft: sendByMe
                                ? const Radius.circular(15)
                                : const Radius.circular(0)),
                        color: sendByMe
                            ? const Color.fromARGB(255, 230, 239, 255)
                            : const Color.fromARGB(255, 229, 249, 230)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 5),
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        children: [
                          Text(
                            chatMap['message'],
                            textAlign:
                                sendByMe ? TextAlign.end : TextAlign.start,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  sendByMe
                      ? const SizedBox()
                      : Text(
                          initSRDate(chatMap['ts']),
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 10,
                          ),
                        )
                ],
              ),
            ),
          ],
        );
      } else if (chatMap['type'] == "img") {
        return Container(
          width: size.width,
          alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            height: size.height / 2,
            child: Image.network(
              chatMap['message'],
            ),
          ),
        );
      } else if (chatMap['type'] == "notify") {
        return Container(
          width: size.width,
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.black38,
            ),
            child: Column(
              children: [
                Text(
                  chatMap['message'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return const SizedBox();
      }
    });
  }

  Widget _chatInput() {
    return Container(
      color: const Color.fromARGB(255, 224, 218, 228),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
        child: Row(
          children: [
            Expanded(
              child: Card(
                // color: const Color.fromARGB(255, 214, 199, 227),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {}, // => Navigator.pop(context),
                        icon: const Icon(Icons.emoji_emotions,
                            color: Colors.blueAccent)),
                    Expanded(
                        child: TextField(
                      // autofocus: true,
                      controller: _message,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: Colors.blueAccent),
                          border: InputBorder.none),
                    )),
                    IconButton(
                        onPressed: () async {}, // => Navigator.pop(context),
                        icon:
                            const Icon(Icons.image, color: Colors.blueAccent)),
                    IconButton(
                        onPressed: () {}, // => Navigator.pop(context),
                        icon: const Icon(Icons.camera_alt_rounded,
                            color: Colors.blueAccent)),
                  ],
                ),
              ),
            ),
            MaterialButton(
              onPressed: () {
                onSendMessage();
                // sendMessage(true);
              },
              minWidth: 0,
              padding:
                  const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 5),
              shape: const CircleBorder(
                  side: BorderSide(color: Colors.green, width: 3)),
              child: const Icon(
                Icons.telegram,
                color: Colors.green,
                size: 40,
              ),
            )
          ],
        ),
      ),
    );
  }
}
