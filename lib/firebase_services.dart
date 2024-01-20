import 'package:chat_meesage_demo/shareprefutils.dart';
import 'package:chat_meesage_demo/userList.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class FirebaseServices extends ChangeNotifier {
  // Function to send a message
  Future<void> sendMessage(
      {required String senderId,
      required String receiverId,
      required String message}) async {
    // Sort the ids to ensure consistency in the collection name
    List<String> ids = [senderId, receiverId]..sort();
    // Construct the chat room ID
    String chatRoomId = "${ids[0]}_${ids[1]}";
    debugPrint('chatroom id- $chatRoomId');

    DocumentReference senderDoc = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomId)
        .collection('userschat')
        .doc(senderId);

    DocumentReference receiverDoc = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomId)
        .collection('userschat')
        .doc(receiverId);

    // Update sender and receiver documents with the message
    await senderDoc.collection('messages').add({
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await receiverDoc.collection('messages').add({
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

// Function to fetch messages for a specific chat room
  Stream<QuerySnapshot> getChat(String senderId, String receiverId) {
    // Sort the ids to ensure consistency in the collection name
    List<String> ids = [senderId, receiverId]..sort();

    // Construct the chat room ID
    String chatRoomId = "${ids[0]}_${ids[1]}";
    debugPrint('getchat betwneen $chatRoomId');

    // Get a reference to the sender document within the chat room
    CollectionReference senderCollection = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomId)
        .collection('userschat')
        .doc(senderId)
        .collection('messages');

    // Listen to changes in the sender's message collection
    return senderCollection.orderBy('timestamp').snapshots();
  }

// Fetch User List
  Stream<QuerySnapshot> getAllUsers() {
    return FirebaseFirestore.instance.collection('users').snapshots();
  }

  //REGISTER USER ON FIRESTORE USER TAB

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      SharedPreferencesUtil.saveUserData(username, email, uid);
      Get.to(UserList(currentUserID: uid));

      await addUserToFirestore(uid, username, email); //add firesstore too
    } catch (e) {
      debugPrint("Error during sign up: $e");
    }
  }

  Future<void> addUserToFirestore(
      String uid, String username, String email) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'username': username,
      'email': email,
    });
  }
}
