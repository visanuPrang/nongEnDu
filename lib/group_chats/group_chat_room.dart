import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messagingapp/group_chats/group_info.dart';
import 'package:messagingapp/image_viewer/viewimage.dart';
import 'package:messagingapp/pages/emoji.dart';
import 'package:messagingapp/service/database.dart';
import 'package:random_string/random_string.dart';
import 'package:url_launcher/url_launcher.dart';

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
  List<String> imageUrls = [];
  bool _isUploading = false, _showMore = false;
  late String newMessageId;
  double x = 0.0;
  double y = 0.0;
  void _updateLocation(PointerEvent details) {
    setState(() {
      x = details.position.dx;
      y = details.position.dy;
    });
  }

  popUpMenu(messageId) {}

  Map<String, dynamic>? userMap;

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  Future<void> _launchUrl(pdfFile) async {
    final Uri url = Uri.parse(pdfFile);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
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
        'Name': map['Name'],
        'E-mail': map['E-mail'],
        'uid': map['Id'],
        'Photo': map['Photo'],
        'isAdmin': true,
      });
    });
  }

  genMsgID() {
    return randomAlphaNumeric(10);
  }

  //send chat image
  sendChatImage(File file, fileName) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final ext = file.path.split('.').last;
    newMessageId = genMsgID();
    final ref =
        storage.ref().child('images/${widget.groupChatId}/$newMessageId.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        'Data Transferred: ${p0.bytesTransferred / 1000} kb',
        style: const TextStyle(fontSize: 20),
      )));
    });
    final messageText = await ref.getDownloadURL();
    await onSendMessage(messageText, ext, newMessageId, fileName, 'image');
  }

  sendChatFile(file, fileName) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    File fFile = File(file);
    final ext = '.${fFile.path.split('.').last}';
    newMessageId = genMsgID();
    final ref = storage
        .ref()
        .child('documents/${widget.groupChatId}/$newMessageId.$ext');
    await ref
        .putFile(fFile, SettableMetadata(contentType: 'document/$ext'))
        .then((p0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        'Data Transferred: ${p0.bytesTransferred / 1000} kb',
        style: const TextStyle(fontSize: 20),
      )));
    });
    final messageText = await ref.getDownloadURL();
    await onSendMessage(messageText, ext, newMessageId, fileName, ext);
  }

  onSendMessage(messageText, ext, newMessageId, alias, type) async {
    // ignore: unused_local_variable
    final User? user = _auth.currentUser;
    DateTime now = DateTime.now();
    String formatedDate = DateFormat('dd-MM-yyyy HH:mm').format(now);
    if (messageText.isNotEmpty) {
      Map<String, dynamic> chatData = {
        'sendBy': _auth.currentUser!.displayName,
        'message': messageText,
        'time': FieldValue.serverTimestamp(),
        'imgUrl': currUser[0]['Photo'],
        'cread': '',
        'ts': formatedDate,
        'type': type,
        'alias': alias,
        'messageId': newMessageId,
        'status': '',
        'statusTime': ''
      };
      DatabaseMethods()
          .addMessage('groups', widget.groupChatId, newMessageId!, chatData)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          'lastMessage': type != 'text' ? alias : messageText,
          'lastMessageSentTs': formatedDate,
          'time': FieldValue.serverTimestamp(),
          'lastMessageSendBy': user!.displayName,
          'messageId': newMessageId,
          'type': type
        };
        DatabaseMethods()
            .updateLastMessageSend(widget.groupChatId, lastMessageInfoMap);

        _message.clear();

        // await _firestore
        //     .collection('groups')
        //     .doc(widget.groupChatId)
        //     .collection('chats')
        //     .add(chatData);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
        child: Scaffold(
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
        child: ConstrainedBox(
          constraints: BoxConstraints.tight(Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height)),
          child: MouseRegion(
            onHover: _updateLocation,
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
                        imageUrls.clear();
                        for (int i = 0; i < snapshot.data!.docs.length; i++) {
                          if (snapshot.data!.docs[i]['type'] == "image" &&
                              snapshot.data!.docs[i]['status']
                                  .toString()
                                  .isEmpty) {
                            imageUrls.add(snapshot.data!.docs[i]['message']);
                          }
                        }
                        return ListView.builder(
                          reverse: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot ds = snapshot.data!.docs[index];
                            Map<String, dynamic> chatMap =
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;
                            return GestureDetector(
                              onLongPress: (() async {
                                if (snapshot.data!.docs[index]['sendBy']
                                        .toString() ==
                                    _auth.currentUser!.displayName.toString()) {
                                  int? value = await showMenu<int>(
                                      context: context,
                                      position:
                                          RelativeRect.fromLTRB(x, y, x, y),
                                      items: [
                                        const PopupMenuItem(
                                            value: 1, child: Text('Unsend')),
                                        const PopupMenuItem(
                                            value: 2, child: Text('Delete')),
                                      ]);
                                  switch (value) {
                                    case 1:
                                      DatabaseMethods().updateMessageUD(
                                          'groups',
                                          widget.groupChatId,
                                          snapshot.data!.docs[index]
                                              ['messageId'],
                                          'Unsend');
                                      break;
                                    case 2:
                                      DatabaseMethods().updateMessageUD(
                                          'groups',
                                          widget.groupChatId,
                                          snapshot.data!.docs[index]
                                              ['messageId'],
                                          'Delete');
                                      break;
                                  }
                                }
                              }),
                              child: messageTile(chatMap, currUser),
                            );
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
              ],
            ),
          ),
        ),
      ),
    ));
  }

//Map<String, dynamic> chatMap, List<Map<String, dynamic>> currUser
  Widget messageTile(
      Map<String, dynamic> chatMap, List<Map<String, dynamic>> currUser) {
    final sendByMe = chatMap['sendBy'] == _auth.currentUser!.displayName;

    // String message,
    // String sendBy,
    // bool sendByMe,
    // String ts,
    // String read,
    // String type,
    // String alias,
    // String status,
    // String statusTime

    // String message,//chatMap['message']
    // String sendBy,//chatMap['sendBy']
    // bool sendByMe,
    // String ts,//chatMap['ts']
    // String read,//chatMap['read']
    // String type,//chatMap['type']
    // String alias,//chatMap['alias']
    // String status,//chatMap['status']
    // String statusTime//chatMap['statusTime']

    String buffName = '', tfName = '';
    if (chatMap['alias'] != null) {
      buffName = chatMap['alias'];
    }
    if (buffName.isNotEmpty) {
      if (buffName.length > 30) {
        while (buffName.length > 26) {
          tfName = '$tfName${buffName.substring(0, 25)}\n';
          buffName = buffName.substring(25);
        }
        if (buffName.isNotEmpty) {
          tfName = '$tfName$buffName';
        }
      } else {
        tfName = buffName;
      }
    }
    return chatMap['type'] == 'notify'
        ? Container(
            width: MediaQuery.of(context).size.width * 0.6,
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
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
          )
        : Row(
            mainAxisAlignment:
                sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              chatMap['status'] == 'Delete'
                  ? const SizedBox()
                  : chatMap['status'] == 'Unsend'
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.black38,
                            ),
                            child: Column(
                              children: [
                                sendByMe
                                    ? const Text(
                                        'You unsend a message',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        '${chatMap['sendBy']} unsend a message',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        )
                      : sendByMe
                          ? Container(
                              padding: const EdgeInsets.only(right: 5),
                              child: Column(
                                children: [
                                  chatMap['cread'] == ''
                                      ? const SizedBox()
                                      : const Text(
                                          'Read',
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 10,
                                          ),
                                        ),
                                  Text(
                                    initSRDate(chatMap['ts']),
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(),
              chatMap['status'] == 'Delete' || chatMap['status'] == 'Unsend'
                  ? const SizedBox()
                  : sendByMe
                      ? const SizedBox()
                      : chatMap['imgUrl'].isEmpty
                          ? Flexible(
                              child: Container(
                                  alignment: Alignment.center,
                                  height: 45,
                                  width: 45,
                                  decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 217, 201, 81),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  child: Text(
                                    noPhoto(chatMap['sendBy']),
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 19, 47, 94)),
                                  )),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: Image.network(
                                chatMap['imgUrl'],
                                height: 45,
                                width: 45,
                                fit: BoxFit.cover,
                              ),
                            ),
              chatMap['status'] == 'Delete' || chatMap['status'] == 'Unsend'
                  ? const SizedBox()
                  : chatMap['type'] == 'text'
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sendByMe
                                ? const SizedBox()
                                : Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 2, horizontal: 17),
                                    alignment: Alignment.topLeft,
                                    constraints: const BoxConstraints(
                                      minWidth: 0.0,
                                      minHeight: 0.0,
                                      maxWidth: 250.0,
                                      // maxHeight: 100.0,
                                    ),
                                    child: Text(
                                      chatMap['sendBy'],
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                            Container(
                              decoration: sendByMe
                                  ? const BoxDecoration(
                                      color: Color.fromARGB(255, 209, 249, 234),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)))
                                  : const BoxDecoration(
                                      color: Color.fromARGB(201, 198, 242, 250),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 8),
                              padding: const EdgeInsets.all(8),
                              child: Container(
                                constraints: const BoxConstraints(
                                  minWidth: 0.0,
                                  minHeight: 0.0,
                                  maxWidth: 250.0,
                                  // maxHeight: 100.0,
                                ),
                                child: Text(
                                  chatMap['message'],
                                  maxLines: null,
                                  softWrap: true,
                                  textAlign: sendByMe
                                      ? TextAlign.end
                                      : TextAlign.start,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                //   ],
                                // ),
                              ),
                            ),
                          ],
                        )
                      : chatMap['type'] == 'image'
                          ? GestureDetector(
                              onTap: () {
                                debugPrint('$imageUrls');
                                final reverseUrls = imageUrls.reversed.toList();
                                final curPicId = reverseUrls.indexWhere(
                                    (element) => element == chatMap['message']);
                                CustomImageWidgetProvider customImageProvider =
                                    CustomImageWidgetProvider(
                                        imageUrls: reverseUrls,
                                        initialIndex: curPicId);
                                showImageViewerPager(
                                    context, customImageProvider,
                                    doubleTapZoomable: true,
                                    swipeDismissible: true);
                              },
                              child: Container(
                                  decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 8),
                                  padding: const EdgeInsets.all(10),
                                  constraints: const BoxConstraints(
                                    minWidth: 80.0,
                                    minHeight: 120.0,
                                    maxWidth: 180.0,
                                    maxHeight: 230.0,
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: chatMap['message'],
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    placeholder: (context, url) => Container(
                                        width: 35,
                                        height: 35,
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle),
                                        child: const CircularProgressIndicator(
                                            strokeWidth: 3)),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  )),
                            )
                          : chatMap['type'] == 'sticker'
                              ? SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.26,
                                  height: MediaQuery.of(context).size.height *
                                      0.1581,
                                  child: CachedNetworkImage(
                                    imageUrl: chatMap['message'],
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ))
                              : chatMap['type'].startsWith('.xls') ||
                                      chatMap['type'].startsWith('.csv')
                                  ? Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 10),
                                      decoration: const BoxDecoration(
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'images/Excel.png',
                                            width: 100,
                                            fit: BoxFit.cover,
                                          ),
                                          Text(tfName)
                                        ],
                                      ))
                                  : chatMap['type'].startsWith('.pdf')
                                      ? GestureDetector(
                                          onTap: (() {
                                            _launchUrl(chatMap['message']);
                                          }),
                                          child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 10),
                                              child: Column(
                                                children: [
                                                  Image.asset(
                                                    'images/pdfLogo.png',
                                                    width: 100,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  Text(tfName)
                                                ],
                                              )),
                                        )
                                      : chatMap['type'].startsWith('.ppt')
                                          ? GestureDetector(
                                              onTap: (() {
                                                _launchUrl(chatMap['message']);
                                              }),
                                              child: Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 8,
                                                      horizontal: 10),
                                                  child: Column(
                                                    children: [
                                                      Image.asset(
                                                        'images/powerpoint.png',
                                                        width: 100,
                                                        fit: BoxFit.cover,
                                                      ),
                                                      Text(tfName)
                                                    ],
                                                  )),
                                            )
                                          : chatMap['type'].startsWith('.doc')
                                              ? GestureDetector(
                                                  onTap: (() {
                                                    _launchUrl(
                                                        chatMap['message']);
                                                  }),
                                                  child: Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 8,
                                                          horizontal: 10),
                                                      decoration: const BoxDecoration(
                                                          color: Colors
                                                              .transparent,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          10))),
                                                      child: Column(
                                                        children: [
                                                          Image.asset(
                                                            'images/MSWord.png',
                                                            width: 100,
                                                            fit: BoxFit.cover,
                                                          ),
                                                          Text(tfName)
                                                        ],
                                                      )),
                                                )
                                              : Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 8,
                                                      horizontal: 10),
                                                  child: Column(
                                                    children: [
                                                      Image.asset(
                                                        'images/unknown.png',
                                                        width: 100,
                                                        fit: BoxFit.cover,
                                                      ),
                                                      Text(tfName)
                                                    ],
                                                  )),
              chatMap['status'] == 'Delete' || chatMap['status'] == 'Unsend'
                  ? const SizedBox()
                  : sendByMe
                      ? const SizedBox()
                      : Text(
                          initSRDate(chatMap['ts']),
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 10,
                          ),
                        )
            ],
          );
  }

  Widget messageTile1(Size size, Map<String, dynamic> chatMap,
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
      } else if (chatMap['type'] == "image") {
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
      } else if (chatMap['type'] == 'notify') {
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
                    _showMore
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _showMore = false;
                              });
                            },
                            icon: const Icon(Icons.arrow_back_ios,
                                color: Colors.blueAccent))
                        : const SizedBox(),
                    _showMore
                        ? IconButton(
                            onPressed: ()
                                //  => keyboardEmoji(),
                                {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          KeyboardInsertedContentApp(
                                              type: 'Group',
                                              name: widget.groupName,
                                              profileurl: currUser[0]['Photo'],
                                              username: currUser[0]['Name'],
                                              page: 'Group',
                                              chatRoomId: widget.groupChatId,
                                              myProfilePic: currUser[0]
                                                  ['Photo'])));
                            },
                            icon: const Icon(Icons.emoji_emotions,
                                color: Colors.blueAccent))
                        : IconButton(
                            onPressed: () {
                              setState(() {
                                _showMore = true;
                              });
                            },
                            icon: const Icon(Icons.arrow_forward_ios,
                                color: Colors.blueAccent)),
                    Expanded(
                        child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 2),
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 2),
                      child: TextField(
                        controller: _message,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(color: Colors.blueAccent),
                            border: InputBorder.none),
                      ),
                    )),
                    _showMore
                        ? IconButton(
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                dialogTitle: 'Select upload file...',
                                type: FileType.custom,
                                allowMultiple: true,
                                allowedExtensions: [
                                  'csv',
                                  'xls',
                                  'xlsx',
                                  'pdf',
                                  'doc',
                                  'docx',
                                  'ppt',
                                  'pptx'
                                ],
                              );

                              if (result != null) {
                                for (int i = 0; i < result.files.length; i++) {
                                  PlatformFile file = result.files[0];
                                  var filePath = '${file.path}';
                                  await sendChatFile(filePath, file.name);
                                }
                              } else {
                                // User canceled the picker
                              }
                            },
                            icon: const Icon(Icons.upload_file,
                                color: Colors.blueAccent))
                        : const SizedBox(),
                    _showMore
                        ? IconButton(
                            onPressed: () async {
                              final ImagePicker picker = ImagePicker();
                              //pick an image
                              final List<XFile> images =
                                  await picker.pickMultiImage(
                                imageQuality: 100,
                                maxHeight: 480,
                                maxWidth: 640,
                              );
                              for (var image in images) {
                                setState(() => _isUploading = true);
                                await sendChatImage(
                                    File(image.path), image.name.substring(7));
                                setState(() => _isUploading = false);
                              }
                            }, // => Navigator.pop(context),
                            icon: const Icon(Icons.image,
                                color: Colors.blueAccent))
                        : const SizedBox(),
                    _showMore
                        ? IconButton(
                            onPressed: () async {
                              final ImagePicker picker = ImagePicker();
                              //pick an image
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.camera,
                                imageQuality: 80,
                                maxHeight: 480,
                                maxWidth: 640,
                              );
                              if (image != null) {
                                setState(() => _isUploading = true);
                                await sendChatImage(File(image.path), 'camara');
                                setState(() => _isUploading = false);
                              }
                            },
                            icon: const Icon(Icons.camera_alt_rounded,
                                color: Colors.blueAccent))
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
            MaterialButton(
              onPressed: () {
                newMessageId = genMsgID();
                onSendMessage(_message.text, '', newMessageId, '', 'text');
                // sendMessage(true);
              },
              minWidth: 0,
              padding:
                  const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 5),
              shape: const CircleBorder(
                  side: BorderSide(
                      color: Color.fromARGB(255, 20, 20, 156), width: 3)),
              child: const Icon(
                Icons.telegram,
                color: Color.fromARGB(255, 20, 20, 156),
                size: 40,
              ),
            )
          ],
        ),
      ),
    );
  }
}
