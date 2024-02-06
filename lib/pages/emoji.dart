import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:messagingapp/pages/chatpage.dart';
import 'package:messagingapp/service/database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:random_string/random_string.dart';
import 'package:screenshot/screenshot.dart';

/// Flutter code sample for [EditableText.onContentInserted].

// void main() => runApp( KeyboardInsertedContentApp());

class KeyboardInsertedContentApp extends StatefulWidget {
  final String type, name, profileurl, username, page, chatRoomId, myProfilePic;
  const KeyboardInsertedContentApp(
      {super.key,
      required this.type,
      required this.name,
      required this.profileurl,
      required this.username,
      required this.page,
      required this.chatRoomId,
      required this.myProfilePic});

  // @override
  // Widget build(BuildContext context) {
  //   return const MaterialApp(
  //     home: KeyboardInsertedContentDemo(),
  //   );
  // }
// }

// class KeyboardInsertedContentDemo extends StatefulWidget {
//   const KeyboardInsertedContentDemo({super.key});

  @override
  State<KeyboardInsertedContentApp> createState() =>
      _KeyboardInsertedContentAppState();
}

class _KeyboardInsertedContentAppState
    extends State<KeyboardInsertedContentApp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _controller = TextEditingController();
  ScreenshotController screenshotController = ScreenshotController();
  late String newMessageId;
  Uint8List? bytes;
  bool _focus = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send a sticker')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          bytes != null
              ? Screenshot(
                  controller: screenshotController,
                  child: Container(
                    alignment: Alignment.topCenter,
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.4,
                    child:
                        Image.memory(bytes!, fit: BoxFit.contain, scale: 0.7),
                  ),
                )
              : const Text('Select a sticker...'),
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: TextField(
                  keyboardType: TextInputType.text,
                  onEditingComplete: () {
                    debugPrint('onTap:');
                    // _focus = false;
                    // FocusManager.instance.primaryFocus?.unfocus();
                  },
                  controller: _controller,
                  autofocus: _focus == true,
                  // onChanged: (event) => setState(() {
                  //   debugPrint('change');
                  //   _focus = false;
                  //   FocusManager.instance.primaryFocus?.unfocus();
                  // }),
                  contentInsertionConfiguration: ContentInsertionConfiguration(
                    allowedMimeTypes: const <String>['image/png', 'image/gif'],
                    onContentInserted: (KeyboardInsertedContent data) async {
                      if (data.data != null) {
                        setState(() {
                          bytes = data.data;
                        });
                      }
                    },
                  ),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  setState(() async {
                    await saveImageFile(
                        bytes, widget.chatRoomId, widget.myProfilePic);
                    super.dispose();
                    // ignore: use_build_context_synchronously
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) {
                      return ChatPage(
                          name: widget.name,
                          page: widget.page,
                          profileurl: widget.profileurl,
                          type: widget.type,
                          username: widget.username);
                    }));
                  });
                },
                autofocus: _focus == false,
                minWidth: 0,
                padding: const EdgeInsets.only(
                    top: 10, bottom: 10, right: 5, left: 5),
                shape: const CircleBorder(
                    side: BorderSide(
                        color: Color.fromARGB(255, 20, 20, 156), width: 3)),
                child: const Icon(
                  Icons.telegram,
                  color: Color.fromARGB(255, 20, 20, 156),
                  size: 40,
                ),
              ),
            ],
          ),
          // if (bytes != null)
          //   const Text("Here's the most recently inserted content:"),
          // if (bytes != null) Image.memory(bytes!),
        ],
      ),
    );
  }

  saveImageFile(capturedImage, chatRoomId, myProfilePic) async {
    final directory = (await getApplicationDocumentsDirectory()).path;
    String fileName = 'sticker.png';
    var path = directory;
    final imagePath = await File('$directory/$fileName').create();
    await imagePath.writeAsBytes(capturedImage);
    await sendChatImage(imagePath, fileName, chatRoomId, myProfilePic);
  }

  sendChatImage(File file, fileName, chatRoomId, myProfilePic) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final ext = file.path.split('.').last;
    newMessageId = genMsgID();
    final ref = storage.ref().child('images/$chatRoomId/$newMessageId.$ext');
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
    await sendMessage(true, messageText, 'sticker', newMessageId, fileName,
        chatRoomId, myProfilePic);
  }

  sendMessage(bool sendClicked, String message, String type, newMessageId,
      alias, chatRoomId, myProfilePic) {
    if (message.isNotEmpty) {
      DateTime now = DateTime.now();
      String formatedDate = DateFormat('dd-MM-yyyy HH:mm').format(now);

      Map<String, dynamic> messageInfoMap = {
        'sendBy': _auth.currentUser!.displayName,
        'message': message,
        'time': FieldValue.serverTimestamp(),
        'imgUrl': myProfilePic,
        'cread': '',
        'ts': formatedDate,
        'type': type,
        'alias': alias,
        'messageId': newMessageId,
        'status': '',
        'statusTime': ''
      };
      DatabaseMethods()
          .addMessage(chatRoomId!, newMessageId!, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          'lastMessage': message,
          'lastMessageSentTs': formatedDate,
          'time': FieldValue.serverTimestamp(),
          'lastMessageSendBy': _auth.currentUser!.displayName,
          'messageId': newMessageId
        };
        DatabaseMethods()
            .updateLastMessageSend(chatRoomId!, lastMessageInfoMap);
      });
    }
  }

  genMsgID() {
    return randomAlphaNumeric(10);
  }
}
