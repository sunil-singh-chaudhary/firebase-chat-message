import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_meesage_demo/chatscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'LifecycleManager.dart';
import 'firebase_services.dart';

class UserList extends StatefulWidget {
  String currentUserID;
  UserList({super.key, required this.currentUserID});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  late LifecycleManager lifecycleManager;

  File? _imageFile;
  String myPrfoileImage = "";
  String uerImages = '';
  String? currentusername;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<FirebaseServices>(context, listen: false).uploadImage(
          _imageFile!,
          widget.currentUserID,
        );
      });
    }
  }

  Future<void> _showImageSourceDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                  child: const ListTile(
                    leading: Icon(Icons.photo),
                    title: Text('Pick from Gallery'),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _pickImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                  child: const ListTile(
                    leading: Icon(Icons.camera_alt),
                    title: Text('Take a Photo'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[50],
        actions: [
          InkWell(
            onTap: () {
              _showImageSourceDialog();
            },
            child: Consumer<FirebaseServices>(builder: (context, value, child) {
              debugPrint('get image profile is ${value.profileImage}');

              return CircleAvatar(
                radius: 4.h,
                child: CachedNetworkImage(
                  imageUrl: value.profileImage,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              );
            }),
          ),
          IconButton(icon: const Icon(Icons.add), onPressed: () {})
        ],
        title: ListTile(
          title: Text(
            'What App',
            style: TextStyle(
              fontSize: 12.sp,
            ),
          ),
          subtitle: Text('   $currentusername',
              style: TextStyle(fontSize: 12.sp, color: Colors.green)),
        ),
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
                  uerImages = userData['profileImageUrl']?.toString() ?? '';
                  debugPrint('username - $username');
                  debugPrint('email - $email');
                  debugPrint('uerImages - $uerImages');
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    widget.currentUserID == users[index].id
                        ? myPrfoileImage =
                            userData['profileImageUrl']?.toString() ?? ''
                        : '';
                    Provider.of<FirebaseServices>(context, listen: false)
                        .updateProfileImagePath(myPrfoileImage);

                    setState(() {
                      widget.currentUserID == users[index].id
                          ? currentusername = username
                          : '';
                    });
                  });

                  return widget.currentUserID == users[index].id
                      ? const SizedBox()
                      : ListTile(
                          leading: CircleAvatar(
                            radius: 3.h,
                            backgroundImage: NetworkImage(uerImages),
                          ),
                          title: Text("$username"),
                          subtitle: Text('$email'),
                          onTap: () {
                            Get.to(ChatScreen(
                              userData: userData,
                              receiverID: users[index].id,
                              currentUserID: widget.currentUserID,
                            ));
                            lifecycleManager = LifecycleManager(
                              context: context,
                              currentUserID: widget.currentUserID,
                              receiverID: users[index].id,
                            );
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
