import 'dart:async';
import 'dart:developer';
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
import 'package:messagingapp/helper/my_date_util.dart';
import 'package:messagingapp/image_viewer/viewimage.dart';
import 'package:messagingapp/pages/emoji.dart';
import 'package:messagingapp/pages/signin.dart';
import 'package:messagingapp/screens/chat_home.dart';
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

class _GroupChatRoomState extends State<GroupChatRoom>
    with WidgetsBindingObserver {
  final TextEditingController _message = TextEditingController();
  final TextEditingController chatMessage = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // late StreamController<int> _controller;
  List<Map<String, dynamic>> currUser = [];
  List<String> imageUrls = [];
  bool _isUploading = false, _showMore = false;
  late String newMessageId, oldSender = '';
  double x = 0.0;
  double y = 0.0;
  int lastIn = 0;

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
    WidgetsBinding.instance.addObserver(this);
    setStatus('Online');
    getCurrentUserDetails();
    updateLoginTime();
    log('${DateTime.now().microsecondsSinceEpoch}');
    log('${DateTime.now()}');
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   log('state: $state');
  //   if (state == AppLifecycleState.resumed) {
  //     // Navigator.of(context).pushReplacementNamed(context, '/ChatHomePage');
  //     // Navigator.of(context).popUntil(ModalRoute.withName('ChatHomePage'));
  //     // Navigator.popUntil(
  //     //     context, ModalRoute.withName(Navigator.defaultRouteName));
  //     // _controller.close();
  //     Navigator.popUntil(
  //         context, (route) => route.settings.name == 'ChatHomePage');
  //     ModalRoute.withName("/ChatHomePage");
  //   }
  // }

  // @override
  // void dispose() {
  //   WidgetsBinding.instance.removeObserver(this);
  //   super.dispose();
  // }

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

  updateLoginTime() async {
    // log('${_auth.currentUser!.uid}  ${widget.groupChatId}');
    _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('groups')
        .doc(widget.groupChatId)
        .update({'lastIn': FieldValue.serverTimestamp()});
  }

  getLoginTime() async {
    // log('${_auth.currentUser!.uid}  ${widget.groupChatId}');
    _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('groups')
        .doc(widget.groupChatId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        return documentSnapshot.data();
      }
      // debugPrint('Document does not exist on the database');
      return 'n/a';
    });
  }

  updateMessageRead(messageId, countRead) {
    _firestore
        .collection('groups')
        .doc(widget.groupChatId)
        .collection('chats')
        .doc(messageId)
        .update({'countRead': countRead + 1});
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
        'countRead': 0,
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
          'chatRoomId': widget.groupChatId,
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

  void setStatus(String status) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      'status': status,
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            // Navigator.push( context, MaterialPageRoute( builder: (context) => SecondPage()), ).then((value) => setState(() {}));
            updateLoginTime();
            // _firestore.terminate(); //.clearPersistence();
            // dispose();
            // _controller.close();
            // _firestore.terminate();
            // WidgetsBinding.instance.addObserver(this);
            // setStatus('Offline');
            // Navigator.of(context).pushReplacementNamed(context, '/ChatHomePage');
            // Navigator.pushReplacementNamed(
            //   context,
            //   '/ChatHomePage',
            // ).then((value) => setState(() {}));
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatHomePage()),
            ).then((value) => setState(() {
                  WidgetsBinding.instance.addObserver(this);
                  // setStatus('Offline');
                }));
          },
        ),
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
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white70,
            ),
            onPressed: () {
              setStatus('Offline');
              _auth.signOut().then((value) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return const SignIn();
                }));
              });
            },
          ),
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
                            // log('${snapshot.data!.docs[index]['sendBy']} ${snapshot.data!.docs[index]['messageId']}');
                            if (snapshot.data!.docs[index]['sendBy']
                                    .toString() !=
                                _auth.currentUser!.displayName.toString()) {
                              if (snapshot.data!.docs[index]['type'] !=
                                      'notify' &&
                                  snapshot.data!.docs[index]['sendBy'] !=
                                      _auth.currentUser!.displayName) {
                                // var arrLastIn = getLoginTime();

                                lastIn = DateTime.now().millisecondsSinceEpoch -
                                    000; //int.parse(arrLastIn['lastIn']);
                                log('$lastIn');

                                if (lastIn <=
                                    DateTime.now().millisecondsSinceEpoch) {
                                  updateMessageRead(
                                      snapshot.data!.docs[index]['messageId'],
                                      snapshot.data!.docs[index]['countRead']);
                                  updateLoginTime();
                                }
                              }
                            }
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
    // log("$oldSender == ${chatMap['sendBy']}");
    // bool sameSender = oldSender == chatMap['sendBy'];
    // sameSender ? oldSender = 'oldSender' : oldSender = chatMap['sendBy'];
    // bool sameSender = false;
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
    return chatMap['type'] == 'notify' ||
            chatMap['status'] == 'Delete' ||
            chatMap['status'] == 'Unsend'
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            verticalDirection: VerticalDirection.up,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              chatMap['status'] == 'Delete' || chatMap['status'] == 'Unsend'
                  ? chatMap['status'] == 'Delete'
                      ? const SizedBox()
                      : Container(
                          width: MediaQuery.of(context).size.width * 0.8,
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
                            child: sendByMe
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
                          ),
                        )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      verticalDirection: VerticalDirection.up,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 8),
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black38,
                          ),
                          child: Text(
                            chatMap['message'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.end, // time sender
            verticalDirection: VerticalDirection.down, // time sender
            mainAxisAlignment:
                sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              sendByMe
                  ? Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.end, // time receiver
                        verticalDirection:
                            VerticalDirection.down, // time receiver
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 5),
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
                                  MyDateUtil.getLastMessageTime(
                                      context: context,
                                      time: chatMap['time']
                                              .microsecondsSinceEpoch ~/
                                          1000),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          chatMap['type'] == 'text'
                              ? Container(
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.only(
                                      left: 5, right: 8, top: 5, bottom: 3),
                                  decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 209, 249, 234),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  constraints: const BoxConstraints(
                                    minWidth: 0.0,
                                    minHeight: 0.0,
                                    maxWidth: 250.0,
                                    // maxHeight: 100.0,
                                  ),
                                  child: Text(chatMap['message']))
                              : chatMap['type'] == 'image'
                                  ? GestureDetector(
                                      onTap: () {
                                        debugPrint('$imageUrls');
                                        final reverseUrls =
                                            imageUrls.reversed.toList();
                                        final curPicId = reverseUrls.indexWhere(
                                            (element) =>
                                                element == chatMap['message']);
                                        CustomImageWidgetProvider
                                            customImageProvider =
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
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10)),
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                            placeholder: (context, url) =>
                                                Container(
                                                    width: 35,
                                                    height: 35,
                                                    decoration:
                                                        const BoxDecoration(
                                                            shape: BoxShape
                                                                .circle),
                                                    child:
                                                        const CircularProgressIndicator(
                                                            strokeWidth: 3)),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          )),
                                    )
                                  : chatMap['type'] == 'sticker'
                                      ? SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.26,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.1581,
                                          child: CachedNetworkImage(
                                            imageUrl: chatMap['message'],
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          ))
                                      : chatMap['type'].startsWith('.xls') ||
                                              chatMap['type'].startsWith('.csv')
                                          ? GestureDetector(
                                              onTap: (() {
                                                _launchUrl(chatMap['message']);
                                              }),
                                              child: Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 8,
                                                      horizontal: 10),
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Colors
                                                              .transparent,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          10))),
                                                  constraints:
                                                      const BoxConstraints(
                                                    minWidth: 0.0,
                                                    minHeight: 0.0,
                                                    maxWidth: 180.0,
                                                    maxHeight: 100.0,
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Image.asset(
                                                        'images/Excel.png',
                                                        width: 65,
                                                        fit: BoxFit.cover,
                                                      ),
                                                      Text(
                                                        chatMap['alias'],
                                                        softWrap: true,
                                                        maxLines: 3,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      )
                                                    ],
                                                  )),
                                            )
                                          : chatMap['type'].startsWith('.pdf')
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
                                                      constraints:
                                                          const BoxConstraints(
                                                        minWidth: 80.0,
                                                        minHeight: 120.0,
                                                        maxWidth: 180.0,
                                                        maxHeight: 200.0,
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Image.asset(
                                                            'images/pdfLogo.png',
                                                            width: 65,
                                                            fit: BoxFit.cover,
                                                          ),
                                                          Text(
                                                            chatMap['alias'],
                                                            maxLines: 3,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          )
                                                        ],
                                                      )),
                                                )
                                              : chatMap['type']
                                                      .startsWith('.ppt')
                                                  ? GestureDetector(
                                                      onTap: (() {
                                                        _launchUrl(
                                                            chatMap['message']);
                                                      }),
                                                      child: Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 8,
                                                                  horizontal:
                                                                      10),
                                                          constraints:
                                                              const BoxConstraints(
                                                            minWidth: 80.0,
                                                            minHeight: 120.0,
                                                            maxWidth: 180.0,
                                                            maxHeight: 200.0,
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              Image.asset(
                                                                'images/powerpoint.png',
                                                                width: 65,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                              Text(
                                                                chatMap[
                                                                    'alias'],
                                                                maxLines: 3,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              )
                                                            ],
                                                          )),
                                                    )
                                                  : chatMap['type']
                                                          .startsWith('.doc')
                                                      ? GestureDetector(
                                                          onTap: (() {
                                                            _launchUrl(chatMap[
                                                                'message']);
                                                          }),
                                                          child: Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          8,
                                                                      horizontal:
                                                                          10),
                                                              constraints:
                                                                  const BoxConstraints(
                                                                minWidth: 80.0,
                                                                minHeight:
                                                                    120.0,
                                                                maxWidth: 180.0,
                                                                maxHeight:
                                                                    200.0,
                                                              ),
                                                              decoration: const BoxDecoration(
                                                                  color: Colors
                                                                      .transparent,
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              10))),
                                                              child: Column(
                                                                children: [
                                                                  Image.asset(
                                                                    'images/MSWord.png',
                                                                    width: 65,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                  Text(
                                                                    chatMap[
                                                                        'alias'],
                                                                    maxLines: 3,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  )
                                                                ],
                                                              )),
                                                        )
                                                      : Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 8,
                                                                  horizontal:
                                                                      10),
                                                          constraints:
                                                              const BoxConstraints(
                                                            minWidth: 80.0,
                                                            minHeight: 120.0,
                                                            maxWidth: 180.0,
                                                            maxHeight: 200.0,
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              Image.asset(
                                                                'images/unknown.png',
                                                                width: 65,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                              Text(
                                                                chatMap[
                                                                    'alias'],
                                                                maxLines: 3,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              )
                                                            ],
                                                          )),
                        ],
                      ),
                    )
// =========================== send by other ===========================
                  : Container(
                      margin: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        verticalDirection: VerticalDirection.down,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            verticalDirection: VerticalDirection.down,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // sameSender
                              //     ?
                              //     Container(
                              //         alignment: Alignment.center,
                              //         height: 45,
                              //         width: 45,
                              //         margin: const EdgeInsets.only(
                              //             left: 10, right: 5),
                              //       )
                              //     :
                              Container(
                                alignment: Alignment.center,
                                height: 45,
                                width: 45,
                                margin:
                                    const EdgeInsets.only(left: 10, right: 5),
                                decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 217, 201, 81),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30))),
                                child: chatMap['imgUrl'].isEmpty
                                    ? Text(
                                        noPhoto(chatMap['sendBy']),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                                255, 19, 47, 94)),
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
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // sameSender
                              //     ? const SizedBox()
                              //     :
                              Text(chatMap['sendBy']),
                              Container(
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                constraints: const BoxConstraints(
                                  minWidth: 0.0,
                                  minHeight: 0.0,
                                  maxWidth: 250.0,
                                  // maxHeight: 100.0,
                                ),
                                child: chatMap['type'] == 'text'
                                    ? Container(
                                        padding: const EdgeInsets.all(8),
                                        margin: const EdgeInsets.only(
                                            left: 5,
                                            right: 8,
                                            top: 5,
                                            bottom: 3),
                                        decoration: const BoxDecoration(
                                            color: Color.fromARGB(
                                                201, 198, 242, 250),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        constraints: const BoxConstraints(
                                          minWidth: 0.0,
                                          minHeight: 0.0,
                                          maxWidth: 250.0,
                                          // maxHeight: 100.0,
                                        ),
                                        child: Text(chatMap['message']))
                                    : chatMap['type'] == 'image'
                                        ? GestureDetector(
                                            onTap: () {
                                              debugPrint('$imageUrls');
                                              final reverseUrls =
                                                  imageUrls.reversed.toList();
                                              final curPicId = reverseUrls
                                                  .indexWhere((element) =>
                                                      element ==
                                                      chatMap['message']);
                                              CustomImageWidgetProvider
                                                  customImageProvider =
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
                                                    // color: Colors.amber,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                20))),
                                                constraints:
                                                    const BoxConstraints(
                                                  minWidth: 80.0,
                                                  minHeight: 80.0,
                                                  maxWidth: 180.0,
                                                  // maxHeight: 180.0,
                                                ),
                                                child: CachedNetworkImage(
                                                  imageUrl: chatMap['message'],
                                                  imageBuilder: (context,
                                                          imageProvider) =>
                                                      Container(
                                                    constraints:
                                                        const BoxConstraints(
                                                      minWidth: 80.0,
                                                      minHeight: 80.0,
                                                      maxWidth: 180.0,
                                                      // maxHeight: 180.0,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      // color: Colors.amber,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  10)),
                                                      image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                  placeholder: (context, url) =>
                                                      Container(
                                                          constraints:
                                                              const BoxConstraints(
                                                            minWidth: 180.0,
                                                            minHeight: 180.0,
                                                            // maxWidth: 180.0,
                                                            // maxHeight: 230.0,
                                                          ),
                                                          decoration:
                                                              const BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle),
                                                          child:
                                                              const CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      3)),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
                                                )),
                                          )
                                        : chatMap['type'] == 'sticker'
                                            ? SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.26,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.1581,
                                                child: CachedNetworkImage(
                                                  imageUrl: chatMap['message'],
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
                                                ))
                                            : chatMap['type']
                                                        .startsWith('.xls') ||
                                                    chatMap['type']
                                                        .startsWith('.csv')
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
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            10))),
                                                        constraints:
                                                            const BoxConstraints(
                                                          minWidth: 0.0,
                                                          minHeight: 0.0,
                                                          maxWidth: 180.0,
                                                          maxHeight: 100.0,
                                                        ),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Image.asset(
                                                              'images/Excel.png',
                                                              width: 65,
                                                              fit: BoxFit.cover,
                                                            ),
                                                            Text(
                                                              chatMap['alias'],
                                                              softWrap: true,
                                                              maxLines: 3,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            )
                                                          ],
                                                        )),
                                                  )
                                                : chatMap['type']
                                                        .startsWith('.pdf')
                                                    ? GestureDetector(
                                                        onTap: (() {
                                                          _launchUrl(chatMap[
                                                              'message']);
                                                        }),
                                                        child: Container(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            margin:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 8,
                                                                    horizontal:
                                                                        10),
                                                            constraints:
                                                                const BoxConstraints(
                                                              minWidth: 0.0,
                                                              minHeight: 0.0,
                                                              maxWidth: 180.0,
                                                              maxHeight: 120.0,
                                                            ),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Image.asset(
                                                                  'images/pdfLogo.png',
                                                                  width: 65,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                                Text(
                                                                  chatMap[
                                                                      'alias'],
                                                                  softWrap:
                                                                      true,
                                                                  maxLines: 3,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                )
                                                              ],
                                                            )),
                                                      )
                                                    : chatMap['type']
                                                            .startsWith('.ppt')
                                                        ? GestureDetector(
                                                            onTap: (() {
                                                              _launchUrl(chatMap[
                                                                  'message']);
                                                            }),
                                                            child: Container(
                                                                margin: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 8,
                                                                    horizontal:
                                                                        10),
                                                                constraints:
                                                                    const BoxConstraints(
                                                                  minWidth:
                                                                      80.0,
                                                                  minHeight:
                                                                      120.0,
                                                                  maxWidth:
                                                                      180.0,
                                                                  maxHeight:
                                                                      200.0,
                                                                ),
                                                                child: Column(
                                                                  children: [
                                                                    Image.asset(
                                                                      'images/powerpoint.png',
                                                                      width: 65,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                    Text(
                                                                      chatMap[
                                                                          'alias'],
                                                                      maxLines:
                                                                          3,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    )
                                                                  ],
                                                                )),
                                                          )
                                                        : chatMap['type']
                                                                .startsWith(
                                                                    '.doc')
                                                            ? GestureDetector(
                                                                onTap: (() {
                                                                  _launchUrl(
                                                                      chatMap[
                                                                          'message']);
                                                                }),
                                                                child:
                                                                    Container(
                                                                        margin: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                8,
                                                                            horizontal:
                                                                                10),
                                                                        decoration: const BoxDecoration(
                                                                            color: Colors
                                                                                .transparent,
                                                                            borderRadius: BorderRadius.all(Radius.circular(
                                                                                10))),
                                                                        constraints:
                                                                            const BoxConstraints(
                                                                          minWidth:
                                                                              80.0,
                                                                          minHeight:
                                                                              120.0,
                                                                          maxWidth:
                                                                              180.0,
                                                                          maxHeight:
                                                                              200.0,
                                                                        ),
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Image.asset(
                                                                              'images/MSWord.png',
                                                                              width: 65,
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                            Text(
                                                                              chatMap['alias'],
                                                                              maxLines: 3,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            )
                                                                          ],
                                                                        )),
                                                              )
                                                            : Container(
                                                                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                                                constraints: const BoxConstraints(
                                                                  minWidth:
                                                                      80.0,
                                                                  minHeight:
                                                                      120.0,
                                                                  maxWidth:
                                                                      180.0,
                                                                  maxHeight:
                                                                      200.0,
                                                                ),
                                                                child: Column(
                                                                  children: [
                                                                    Image.asset(
                                                                      'images/unknown.png',
                                                                      width: 65,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                    Text(
                                                                      chatMap[
                                                                          'alias'],
                                                                      maxLines:
                                                                          3,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ],
                                                                )),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
              sendByMe ||
                      chatMap['type'] == 'notify' ||
                      chatMap['status'] == 'Delete' ||
                      chatMap['status'] == 'Unsend'
                  ? const SizedBox()
                  : Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            MyDateUtil.getLastMessageTime(
                                context: context,
                                time: chatMap['time'].microsecondsSinceEpoch ~/
                                    1000),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    )
            ],
          );
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
                color: const Color.fromARGB(255, 240, 237, 242),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Expanded(
                        child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 2),
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 2),
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(150, 255, 255, 255),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: TextField(
                        controller: _message,
                        minLines: 1,
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(color: Colors.blueAccent),
                            border: InputBorder.none),
                      ),
                    )),
                    _showMore
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _showMore = false;
                              });
                            },
                            icon: const Icon(Icons.arrow_forward_ios,
                                color: Colors.blueAccent))
                        : IconButton(
                            onPressed: () {
                              setState(() {
                                _showMore = true;
                              });
                            },
                            icon: const Icon(Icons.arrow_back_ios,
                                color: Colors.blueAccent)),
                    _showMore
                        ? Row(children: [
                            IconButton(
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
                                                  profileurl: currUser[0]
                                                      ['Photo'],
                                                  username: currUser[0]['Name'],
                                                  page: 'Group',
                                                  chatRoomId:
                                                      widget.groupChatId,
                                                  myProfilePic: currUser[0]
                                                      ['Photo'])));
                                },
                                icon: const Icon(Icons.emoji_emotions,
                                    color: Colors.blueAccent)),
                            IconButton(
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
                                    for (int i = 0;
                                        i < result.files.length;
                                        i++) {
                                      PlatformFile file = result.files[0];
                                      var filePath = '${file.path}';
                                      await sendChatFile(filePath, file.name);
                                    }
                                  } else {
                                    // User canceled the picker
                                  }
                                },
                                icon: const Icon(Icons.upload_file,
                                    color: Colors.blueAccent)),
                            IconButton(
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
                                    await sendChatImage(File(image.path),
                                        image.name.substring(7));
                                    setState(() => _isUploading = false);
                                  }
                                }, // => Navigator.pop(context),
                                icon: const Icon(Icons.image,
                                    color: Colors.blueAccent)),
                            IconButton(
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
                                    await sendChatImage(
                                        File(image.path), 'camara');
                                    setState(() => _isUploading = false);
                                  }
                                },
                                icon: const Icon(Icons.camera_alt_rounded,
                                    color: Colors.blueAccent))
                          ])
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
