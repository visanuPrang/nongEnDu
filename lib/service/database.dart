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

  createChatRoom(
      String chatRoomId, Map<String, dynamic> chatRoomInfoMap) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('chatroom')
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

  Future addMessage(String chatRoomId, String messageId,
      Map<String, dynamic> messageInfoMap) async {
    return FirebaseFirestore.instance
        .collection('chatrooms')
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

  updateMessageUD(String chatRoomId, String msgId, String status) {
    DateTime now = DateTime.now();
    String formatedDate = DateFormat('dd-MM-yyyy HH:mm').format(now);
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('chats')
        .doc(msgId)
        .update({'status': status, 'statusTime': formatedDate});
  }

  Future<Stream<QuerySnapshot>> getChatRoomMessages(chatRoomId) async {
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('chats')
        .orderBy('time', descending: true)
        .snapshots();
  }

  Future<QuerySnapshot> getUserInfo(String username) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
  }

  Future<Stream<QuerySnapshot>> getChatRooms() async {
    String? myUsername = await SharedPreferenceHelper().getUserName();
    return FirebaseFirestore.instance
        .collection('chatrooms')
        .orderBy('time', descending: true)
        .where('users', arrayContains: myUsername!)
        .snapshots();
  }
}
