import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:messagingapp/image_viewer/viewimage.dart';
import 'package:messagingapp/pages/emoji.dart';
import 'package:messagingapp/pages/emuji1.dart';
import 'package:messagingapp/pages/searchpage.dart';
import 'package:messagingapp/pages/signin.dart';
import 'package:messagingapp/pages/temp_screen.dart';
import 'package:messagingapp/service/database.dart';
import 'package:messagingapp/service/shared_pref.dart';
import 'package:random_string/random_string.dart';

import 'package:url_launcher/url_launcher.dart';

class ChatPage extends StatefulWidget {
  final String type, name, profileurl, username, page;
  const ChatPage(
      {super.key,
      required this.type, //= Person or Group
      required this.name, //= chat with
      required this.profileurl, //= picture url
      required this.username, //= chat with
      required this.page}); //= Home or SearchPage

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseStorage _storage = FirebaseStorage.instance;
  TextEditingController messagecontroller = TextEditingController();
  final TextEditingController _controller = TextEditingController();
  Uint8List? bytes;
  Stream? messageStream;
  late String newMessageId;
  String? myUsername, myProfilePic, myName, myEmail, messageId, chatRoomId;
  int inputType = 1; //1-text 2-emoji 3-image 4-file 5-camara
  bool _isUploading = false, _showMore = false;

  double x = 0.0;
  double y = 0.0;
  void _updateLocation(PointerEvent details) {
    setState(() {
      x = details.position.dx;
      y = details.position.dy;
    });
  }

  popUpMenu(messageId) {}
  noPhoto(xName) {
    String initial = '';
    var splitName = xName.split(' ');
    splitName.length > 1
        ? initial = splitName[0].substring(0, 1) + splitName[1].substring(0, 1)
        : initial = splitName[0].substring(0, 1);
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

  getthesharedpref() async {
    myUsername = await SharedPreferenceHelper().getUserName();
    myProfilePic = await SharedPreferenceHelper().getUserPic();
    myName = await SharedPreferenceHelper().getDisplayName();
    myEmail = await SharedPreferenceHelper().getUserEmail();

    chatRoomId = getChatRoomIdbyUsername(widget.name, myName!);
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    await getAndSetMessage();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ontheload();
  }

  getChatRoomIdbyUsername(String a, String b) {
    var nameArray = [a, b];
    nameArray.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return '${nameArray[0]}_${nameArray[1]}';
  }

  viewImage(imageFile) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          content: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: CachedNetworkImage(
                      fit: BoxFit.contain,
                      imageUrl: imageFile,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          image: DecorationImage(
                            image: imageProvider,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Container(
                          width: 35,
                          height: 35,
                          decoration:
                              const BoxDecoration(shape: BoxShape.circle),
                          child:
                              const CircularProgressIndicator(strokeWidth: 3)),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    )),
              ),
            ],
          ),
          insetPadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          // clipBehavior: Clip.antiAliasWithSaveLayer,
        );
      },
    );
  }

  Future<void> _launchUrl(pdfFile) async {
    final Uri url = Uri.parse(pdfFile);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget chatMessageTile(String message, bool sendByMe, String ts, String read,
      String type, String alias, String status, String statusTime) {
    String buffName = alias, tfName = '';
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
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        status == 'Delete'
            ? const SizedBox()
            : status == 'Unsend'
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
                                  '${widget.name} unsend a message',
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
                            read == ''
                                ? const SizedBox()
                                : const Text(
                                    'Read',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 10,
                                    ),
                                  ),
                            Text(
                              initSRDate(ts),
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(),
        status == 'Delete' || status == 'Unsend'
            ? const SizedBox()
            : sendByMe
                ? const SizedBox()
                : widget.profileurl.isEmpty
                    ? Flexible(
                        child: Container(
                            alignment: Alignment.center,
                            height: 45,
                            width: 45,
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 217, 201, 81),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
                            child: Text(
                              noPhoto(widget.name),
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 19, 47, 94)),
                            )),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Image.network(
                          widget.profileurl,
                          height: 45,
                          width: 45,
                          fit: BoxFit.cover,
                        ),
                      ),
        status == 'Delete' || status == 'Unsend'
            ? const SizedBox()
            : type == 'text'
                ? Container(
                    decoration: sendByMe
                        ? const BoxDecoration(
                            color: Color.fromARGB(255, 209, 249, 234),
                            borderRadius: BorderRadius.all(Radius.circular(20)))
                        : const BoxDecoration(
                            color: Color.fromARGB(201, 198, 242, 250),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 0.0,
                        minHeight: 0.0,
                        maxWidth: 250.0,
                        maxHeight: 100.0,
                      ),
                      child: Text(
                        message,
                        maxLines: null,
                        softWrap: true,
                        textAlign: sendByMe ? TextAlign.end : TextAlign.start,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )
                : type == 'image'
                    ? GestureDetector(
                        onTap: () {
                          const ImageViewer(
                            title: 'view image',
                          );
                          // viewImage(message);
                        },
                        child: Container(
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
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
                              imageUrl: message,
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
                    : type == 'sticker'
                        ? SizedBox(
                            width: MediaQuery.of(context).size.width * 0.25,
                            height: MediaQuery.of(context).size.height * 0.25,
                            child: CachedNetworkImage(
                              imageUrl: message,
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ))
                        : type.startsWith('.xls') || type.startsWith('.csv')
                            ? Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 10),
                                decoration: const BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
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
                            : type.startsWith('.pdf')
                                ? GestureDetector(
                                    onTap: (() {
                                      _launchUrl(message);
                                    }),
                                    child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 10),
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
                                : type.startsWith('.ppt')
                                    ? GestureDetector(
                                        onTap: (() {
                                          _launchUrl(message);
                                        }),
                                        child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 10),
                                            // decoration: const BoxDecoration(
                                            //     color: Color.fromARGB(255, 217, 201, 81),
                                            //     borderRadius:
                                            //         BorderRadius.all(Radius.circular(10))),
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
                                    : type.startsWith('.doc')
                                        ? GestureDetector(
                                            onTap: (() {
                                              _launchUrl(message);
                                            }),
                                            child: Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 10),
                                                decoration: const BoxDecoration(
                                                    color: Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
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
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 10),
                                            // decoration: const BoxDecoration(
                                            //     color:
                                            //         Color.fromARGB(255, 217, 201, 81),
                                            //     borderRadius: BorderRadius.all(
                                            //         Radius.circular(10))),
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
        status == 'Delete' || status == 'Unsend'
            ? const SizedBox()
            : sendByMe
                ? const SizedBox()
                : Text(
                    initSRDate(ts),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 10,
                    ),
                  )
      ],
    );
  }

  Widget chatMessage() {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 224, 218, 228),
        image: DecorationImage(
            opacity: 0.15,
            image: AssetImage("images/NongEnDu_Tran.png"),
            // image: NetworkImage(
            //     'https://img.freepik.com/premium-vector/cute-little-student-girl-cartoon_96373-287.jpg'),
            fit: BoxFit.cover),
      ),
      child: StreamBuilder(
          stream: messageStream,
          builder: (context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return const Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 177, 21, 10)),
                  ),
                );
              case ConnectionState.waiting:
                return const Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 73, 44, 2)),
                  ),
                );
              case ConnectionState.active:
              // return const CircularProgressIndicator(
              //     color: Color.fromARGB(255, 15, 119, 19));
              case ConnectionState.done:
                return snapshot.hasData
                    ? ListView.builder(
                        primary: true,
                        addAutomaticKeepAlives: true,
                        padding: const EdgeInsets.only(bottom: 90, top: 130),
                        itemCount: snapshot.data.docs.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          DocumentSnapshot ds = snapshot.data.docs[index];
                          if (snapshot.data.docs[index]['sendBy'].toString() !=
                              _auth.currentUser!.displayName.toString()) {
                            if (snapshot.data.docs[index]['cread'] == '') {
                              DatabaseMethods().updateMessageRead(chatRoomId!,
                                  snapshot.data.docs[index]['messageId']);
                            }
                          }
                          _firestore.batch().commit();
                          return GestureDetector(
                            onLongPress: (() async {
                              if (snapshot.data.docs[index]['sendBy']
                                      .toString() ==
                                  _auth.currentUser!.displayName.toString()) {
                                // popUpMenu(snapshot.data.docs[index]['messageId']);
                                int? value = await showMenu<int>(
                                    context: context,
                                    position: RelativeRect.fromLTRB(x, y, x, y),
                                    items: [
                                      const PopupMenuItem(
                                          value: 1, child: Text('Unsend')),
                                      const PopupMenuItem(
                                          value: 2, child: Text('Delete')),
                                    ]);
                                switch (value) {
                                  case 1:
                                    DatabaseMethods().updateMessageUD(
                                        chatRoomId!,
                                        snapshot.data.docs[index]['messageId'],
                                        'Unsend');
                                    break;
                                  case 2:
                                    DatabaseMethods().updateMessageUD(
                                        chatRoomId!,
                                        snapshot.data.docs[index]['messageId'],
                                        'Delete');
                                    break;
                                }
                              }
                            }),
                            child: chatMessageTile(
                                ds['message'],
                                myName == ds['sendBy'],
                                ds['ts'],
                                ds['cread'].toString(),
                                ds['type'],
                                ds['alias'],
                                ds['status'],
                                ds['statusTime']),
                          );
                        })
                    : const Center();
            }
          }),
    );
  }

  //send chat image
  sendChatImage(File file, fileName) async {
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
    await sendMessage(true, messageText, 'image', newMessageId, fileName);
  }

  sendChatFile(file, fileName) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    File fFile = File(file);
    final ext = '.${fFile.path.split('.').last}';
    newMessageId = genMsgID();
    final ref = storage.ref().child('documents/$chatRoomId/$newMessageId.$ext');
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
    await sendMessage(true, messageText, ext, newMessageId, fileName);
  }

  sendMessage(
      bool sendClicked, String message, String type, newMessageId, alias) {
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
          'lastMessageSendBy': myUsername,
          'messageId': newMessageId
        };
        DatabaseMethods()
            .updateLastMessageSend(chatRoomId!, lastMessageInfoMap);
        if (sendClicked) {
          messageId = null;
        }
        messagecontroller.clear();
      });
    }
  }

  genMsgID() {
    return randomAlphaNumeric(10);
  }

  getAndSetMessage() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    setState(() {});
  }

  keyboardEmoji() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextField(
          controller: _controller,
          contentInsertionConfiguration: ContentInsertionConfiguration(
            allowedMimeTypes: const <String>['image/png', 'image/gif'],
            onContentInserted: (KeyboardInsertedContent data) async {
              if (data.data != null) {
                setState(() {
                  bytes = data.data;
                  if (bytes != null) {
                    const Text("Here's the most recently inserted content:");
                  }
                  if (bytes != null) Image.memory(bytes!);
                });
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 224, 218, 228),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white70,
          ),
          onPressed: () {
            _firestore.terminate();
            widget.page == 'Home'
                ? Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const TempScreen()))
                : Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchPage()));
          },
        ),
        backgroundColor: const Color.fromARGB(255, 57, 6, 119),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chat with:',
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
            Text(
              widget.name,
              style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500),
            )
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white70,
            ),
            onPressed: () {
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
      body: ConstrainedBox(
        constraints: BoxConstraints.tight(Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height)),
        child: MouseRegion(
          onHover: _updateLocation,
          child: Column(
            children: [
              Expanded(child: chatMessage()),
              if (_isUploading)
                const Padding(
                  padding: EdgeInsets.only(right: 25, bottom: 15),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: CircularProgressIndicator(),
                  ),
                ),
              _chatInput()
            ],
          ),
        ),
      ),
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
                                              type: widget.type,
                                              name: widget.name,
                                              profileurl: widget.profileurl,
                                              username: widget.username,
                                              page: widget.page,
                                              chatRoomId: chatRoomId!,
                                              myProfilePic: myProfilePic!)));
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
                        child: TextField(
                      controller: messagecontroller,
                      // contentInsertionConfiguration:
                      //     ContentInsertionConfiguration(
                      //   allowedMimeTypes: [
                      //     "image/png", /*...*/
                      //   ],
                      //   onContentInserted:
                      //       (KeyboardInsertedContent data) async {
                      //     if (data.data != null) {
                      //       setState(() {
                      //         bytes = data.data;
                      //       });
                      //     }
                      //   },
                      //   // onContentInserted: (_) {/*your cb here*/},
                      // ),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: Colors.blueAccent),
                          border: InputBorder.none),
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
                sendMessage(
                    true, messagecontroller.text, 'text', newMessageId, '');
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
