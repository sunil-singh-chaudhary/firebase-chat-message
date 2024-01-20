import 'package:chat_meesage_demo/chatscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';

import 'firebase_services.dart';

class UserList extends StatefulWidget {
  String currentUserID;
  UserList({super.key, required this.currentUserID});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('User List')),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: Provider.of<FirebaseServices>(context, listen: false)
              .getAllUsers(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var users = snapshot.data!.docs;

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  var userData = users[index].data() as Map<String, dynamic>;
                  var username = userData['username'];
                  var email = userData['email'];

                  return widget.currentUserID == users[index].id
                      ? const SizedBox()
                      : ListTile(
                          title: Text("$username"),
                          subtitle: Text('$email'),
                          onTap: () {
                            Get.to(ChatScreen(
                              userData: userData,
                              receiverID: users[index].id,
                              currentUserID: widget.currentUserID,
                            ));
                          },
                        );
                },
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return const CircularProgressIndicator();
          }),
    );
  }
}
