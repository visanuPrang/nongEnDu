import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:messagingapp/screens/chat_home.dart';
import 'package:messagingapp/service/database.dart';
import 'package:messagingapp/service/shared_pref.dart';
import 'package:random_string/random_string.dart';

class ChatPage extends StatefulWidget {
  final String type, name, profileurl, username, page;
  const ChatPage(
      {super.key,
      required this.type,
      required this.name,
      required this.profileurl,
      required this.username,
      required this.page});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messagecontroller = TextEditingController();
  Stream? messageStream;
  String? myUsername, myProfilePic, myName, myEmail, messageId, chatRoomId;

  noPhoto(xName) {
    String initial = '';
    var splitName = xName.split(' ');
    splitName.length > 1
        ? initial = splitName[0].substring(0, 1) + splitName[1].substring(0, 1)
        : initial = splitName[0].substring(0, 1);
    return initial;
  }

  getthesharedpref() async {
    myUsername = await SharedPreferenceHelper().getUserName();
    myProfilePic = await SharedPreferenceHelper().getUserPic();
    myName = await SharedPreferenceHelper().getDisplayName();
    myEmail = await SharedPreferenceHelper().getUserEmail();

    chatRoomId = getChatRoomIdbyUsername(widget.username, myUsername!);
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
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return '${b}_$a';
    } else {
      return '${a}_$b';
    }
  }

  Widget chatMessageTile(String message, bool sendByMe, String ts) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        sendByMe
            ? Text(
                ts,
                style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              )
            : const SizedBox(),
        sendByMe
            ? const SizedBox()
            : widget.profileurl.isEmpty
                ? Container(
                    alignment: Alignment.center,
                    height: 45,
                    width: 45,
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 217, 201, 81),
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: Text(
                      noPhoto(widget.name),
                      style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 19, 47, 94)),
                    ))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.network(
                      widget.profileurl,
                      height: 45,
                      width: 45,
                      fit: BoxFit.cover,
                    ),
                  ),
        Flexible(
          child: Container(
            width: MediaQuery.of(context).size.width * .65,
            padding: const EdgeInsets.all(
                15), //.only(top: 10, bottom: 10, right: 5),
            // margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
            margin: const EdgeInsets.only(right: 10, bottom: 10),
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
                  ? const Color.fromARGB(255, 234, 236, 240)
                  : const Color.fromARGB(255, 211, 228, 243),
            ),
            child: Text(
              message,
              textAlign: sendByMe ? TextAlign.end : TextAlign.start,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
        sendByMe
            ? const SizedBox()
            : Text(
                ts,
                style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              )
      ],
    );
  }

  Widget chatMessage() {
    return StreamBuilder(
        stream: messageStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: const EdgeInsets.only(bottom: 90, top: 130),
                  itemCount: snapshot.data.docs.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return chatMessageTile(
                        ds['message'], myName == ds['sendBy'], ds['ts']);
                  })
              : const Center();
        });
  }

  updateUser(bool sendClicked) {
    if (messagecontroller.text != '') {
      var userId = '2277485770';
      Map<String, dynamic> userInfoMap = {
        'Name': 'yx02 nong En-Du',
      };

      DatabaseMethods().updateUserInfo(userId, userInfoMap);
      //     .then((value) {
      // });
    }
  }

  addMessage(bool sendClicked) {
    if (messagecontroller.text != '') {
      String message = messagecontroller.text;
      messagecontroller.text = '';
      DateTime now = DateTime.now();
      String formatedDate = DateFormat('HH:mm').format(now);
      Map<String, dynamic> messageInfoMap = {
        'message': message,
        'sendBy': myName,
        'ts': formatedDate,
        'time': FieldValue.serverTimestamp(),
        'imgUrl': myProfilePic,
      };
      messageId ??= randomAlphaNumeric(10);
      DatabaseMethods()
          .addMessage(chatRoomId!, messageId!, messageInfoMap)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          'lastMessage': message,
          'lastMessageSentTs': formatedDate,
          'time': FieldValue.serverTimestamp(),
          'lastMessageSendBy': myUsername,
        };
        DatabaseMethods()
            .updateLastMessageSend(chatRoomId!, lastMessageInfoMap);
        if (sendClicked) {
          messageId = null;
        }
      });
    }
  }

  getAndSetMessage() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // backgroundColor: const Color(0xff553370),
        appBar: AppBar(
          // automaticallyImplyLeading: false,
          flexibleSpace: _appBar(),
        ),
        body: Column(
          children: [
            const Expanded(
              child: Text('data'),
            ),
            _chatInput(),
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChatHomePage()));
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black87,
              )),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'user name',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500),
              ),
              Text(
                'second line text',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {}, // => Navigator.pop(context),
                      icon: const Icon(Icons.emoji_emotions,
                          color: Colors.blueAccent)),
                  const Expanded(
                      child: TextField(
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.blueAccent),
                        border: InputBorder.none),
                  )),
                  IconButton(
                      onPressed: () {}, // => Navigator.pop(context),
                      icon: const Icon(Icons.image, color: Colors.blueAccent)),
                  IconButton(
                      onPressed: () {}, // => Navigator.pop(context),
                      icon: const Icon(Icons.camera_alt_rounded,
                          color: Colors.blueAccent)),
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: () {},
            minWidth: 0,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 5),
            shape: const CircleBorder(),
            // color: Colors.green,
            child: const Icon(
              Icons.telegram,
              color: Colors.green,
              size: 40,
            ),
          )
        ],
      ),
    );
  }
}
