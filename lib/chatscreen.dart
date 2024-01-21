import 'package:chat_meesage_demo/firebase_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// var senderUserID = 'odf1bIwsg0OGnMiSYTdoytW9DIn1';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  String receiverID, currentUserID;

  ChatScreen({
    super.key,
    required this.userData,
    required this.receiverID,
    required this.currentUserID,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  FocusNode focusNode = FocusNode();

  late String username;

  @override
  void initState() {
    super.initState();
    username = widget.userData['username'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
                width: 100,
                child: Text(username, style: const TextStyle(fontSize: 16))),
            Consumer<FirebaseServices>(
              builder: (context, value, child) => SizedBox(
                width: 100,
                child: Text(
                  value.isOnlineYes == true ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        value.isOnlineYes == true ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream: Provider.of<FirebaseServices>(context, listen: false)
                    .getChat(widget.currentUserID, widget.receiverID),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  // Extract message data from snapshot
                  var messages = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var messageData =
                          messages[index].data() as Map<String, dynamic>;
                      var senderId = messageData['senderId'];
                      var receiverId = messageData['receiverId'];
                      var message = messageData['message'];
                      debugPrint('mesage length- $message');
                      debugPrint('current user is- ${widget.currentUserID}');
                      debugPrint('receiver user is $receiverId');

                      var mainAxisAlignment = widget.currentUserID == senderId
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start;

                      return Row(
                        mainAxisAlignment: mainAxisAlignment,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: widget.currentUserID == senderId
                                  ? Colors.blue
                                  : Colors.green,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              message,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your message...',
                    ),
                    focusNode: focusNode,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    var messageText = _messageController.text.trim();
                    Provider.of<FirebaseServices>(context, listen: false)
                        .sendMessage(
                      senderId: widget.currentUserID,
                      receiverId: widget.receiverID,
                      message: messageText,
                    );
                    _messageController.clear();
                    focusNode.unfocus();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
