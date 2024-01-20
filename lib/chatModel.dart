import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  bool isOnline;
  Timestamp lastOnline;
  String msg;
  String receiver;
  String sender;

  ChatMessage({
    required this.isOnline,
    required this.lastOnline,
    required this.msg,
    required this.receiver,
    required this.sender,
  });

  Map<String, dynamic> toJson() {
    return {
      'isOnline': isOnline,
      'lastOnline': lastOnline,
      'msg': msg,
      'receiver': receiver,
      'sender': sender,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      isOnline: json['isOnline'],
      lastOnline: json['lastOnline'] as Timestamp,
      msg: json['msg'],
      receiver: json['receiver'],
      sender: json['sender'],
    );
  }

}



  // // Convert ChatMessage to JSON
  // Map<String, dynamic> jsonRepresentation = originalMessage.toJson();
  // print('JSON Representation: $jsonRepresentation');

  // // Convert JSON to ChatMessage
  // ChatMessage recreatedMessage = ChatMessage.fromJson(jsonRepresentation);
  // print('Recreated ChatMessage: $recreatedMessage');

