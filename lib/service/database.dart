// import 'dart:math';
import 'dart:developer';
// import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:messagingapp/service/shared_pref.dart';

class DatabaseMethods {
  Future addUserDetails(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .set(userInfoMap);
  }

  //add group to users for list view
  Future addUserGroupDetails(
      Map<String, dynamic> userGroupInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .set(userGroupInfoMap);
  }

  Future addGroupDetails(Map<String, dynamic> groupInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection('groups')
        .doc(id)
        .set(groupInfoMap);
  }

  Future<QuerySnapshot> getUserbyemail(String email) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where('E-mail', isEqualTo: email)
        .get();
  }

  Future<QuerySnapshot> getUserbyUID(String uid) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where('Id', isEqualTo: uid)
        .get();
  }

  Future<QuerySnapshot> search(String username) async =>
      await FirebaseFirestore.instance.collection('users').get();

  Future<QuerySnapshot> getAllUser() async =>
      await FirebaseFirestore.instance.collection('users').get();

  Future<QuerySnapshot> getAllLastMessage(roomId) async =>
      await FirebaseFirestore.instance
          .collection('chatrooms')
          // .where('chatRoomId', isEqualTo: roomId)
          .get();

  createChatRoom(
      String chatRoomId, Map<String, dynamic> chatRoomInfoMap) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .get();
    if (snapshot.exists) {
      return true;
    } else {
      return FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(chatRoomId)
          .set(chatRoomInfoMap);
    }
  }

  updateUserInfo(String userId, Map<String, dynamic> userInfoMap) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update(userInfoMap);
  }

  Future addMessage(String usersGroups, String chatRoomId, String messageId,
      Map<String, dynamic> messageInfoMap) async {
    return FirebaseFirestore.instance
        .collection(usersGroups)
        .doc(chatRoomId)
        .collection('chats')
        .doc(messageId)
        .set(messageInfoMap);
  }

  updateLastMessageSend(
      String chatRoomId, Map<String, dynamic> lastMessageInfoMap) {
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .set(lastMessageInfoMap);
  }

  updateMessageRead(String chatRoomId, String msgId) {
    DateTime now = DateTime.now();
    String formatedDate = DateFormat('dd-MM-yyyy HH:mm').format(now);
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('chats')
        .doc(msgId)
        .update({'cread': formatedDate});
  }

  updateToken(String uid, String token, String authToken) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'token': token, 'tokenAuthMsg': authToken});
  }

  updateMessageUD(
      String usersGroup, String chatRoomId, String msgId, String status) {
    DateTime now = DateTime.now();
    String formatedDate = DateFormat('dd-MM-yyyy HH:mm').format(now);
    return FirebaseFirestore.instance
        .collection(usersGroup)
        .doc(chatRoomId)
        .collection('chats')
        .doc(msgId)
        .update({'status': status, 'statusTime': formatedDate});
  }

  getUserInRoom(userId) async {
    List userStatus = [];
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((value) {
      userStatus.add(value.data());
    });
    return '${userStatus[0]['chatRoom']}|${userStatus[0]['status']}|${userStatus[0]['token']}';
  }

  Future<Stream<QuerySnapshot>> getChatRoomMessages(chatRoomId) async {
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('chats')
        .orderBy('time', descending: true)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getAllUserList() async {
    return FirebaseFirestore.instance
        .collection('users')
        .orderBy('Name', descending: false)
        .snapshots();
  }

  Future<QuerySnapshot> getUserInfo(String username) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
  }

  // Future<QuerySnapshot>
  getLastMessage(String roomId) async {
    debugPrint('roomId==>$roomId');
    await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(roomId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      // debugPrint('$roomId=>${documentSnapshot.exists}');
      if (documentSnapshot.exists) {
        return documentSnapshot.data();
      }
      // debugPrint('Document does not exist on the database');
      return 'n/a';
    });
  }

  Widget getLastMessageX(thisChatRoomId) {
    CollectionReference lastMessage =
        FirebaseFirestore.instance.collection('chatrooms');
    return FutureBuilder<DocumentSnapshot>(
        future: lastMessage.doc(thisChatRoomId).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          // debugPrint('getLastMessage');
          if (snapshot.hasError) {
            // debugPrint('${snapshot.hasError}');
            return const Text('Something went worng');
          }
          if (snapshot.hasData && !snapshot.data!.exists) {
            // debugPrint("lastMessage: ${snapshot.data}");
            return const Text('Document dose not exist');
          }
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            // debugPrint("lastMessage: ${data['lastMessage']}");
            return Text("lastMessage: ${data['lastMessage']}");
          }
          return const Text('loading');
        });
  }

  // Future<QuerySnapshot> getLastMessage(String thisChatRoomId) async {
  //   var lastMessageMap = [];
  //   return await FirebaseFirestore.instance
  //       .collection('chatrooms')
  //       .where('chatRoomId', isEqualTo: thisChatRoomId)
  //       .get()
  //       .then((map) {
  //     lastMessageMap.add({
  //       'Name': map['Name'],
  //       'E-mail': map['E-mail'],
  //       'uid': map['Id'],
  //       'Photo': map['Photo'],
  //       'isAdmin': true,
  //     });
  //   });
  // }

  Future<Stream<QuerySnapshot>> getChatRooms() async {
    String? myUsername = await SharedPreferenceHelper().getUserName();
    log('getChatRooms==>[$myUsername]');
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .orderBy('time', descending: true)
        .where('users', arrayContains: myUsername!)
        .snapshots();
  }
}
