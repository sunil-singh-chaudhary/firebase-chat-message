import 'package:chat_meesage_demo/firebase_options.dart';
import 'package:chat_meesage_demo/firebase_services.dart';
import 'package:chat_meesage_demo/shareprefutils.dart';
import 'package:chat_meesage_demo/signupscree.dart';
import 'package:chat_meesage_demo/userList.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => FirebaseServices(),
      builder: (context, child) => const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String currentUserID;

  @override
  void initState() {
    super.initState();
    // If not, request permission
    requestStoragePermission();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) => GetMaterialApp(
        home: FutureBuilder(
          // Check if user is logged in using SharedPreferences
          future: SharedPreferencesUtil.getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // Check if UID is available
              String? uid = snapshot.data?[SharedPreferencesUtil.KEY_UID];
              if (uid != null) {
                // User is logged in, show UserList screen
                return UserList(
                  currentUserID: uid,
                );
              } else {
                // User is not logged in, show SignUpScreen
                return const SignUpScreen();
              }
            } else {
              // Still loading data, show loading indicator or splash screen
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

  void requestStoragePermission() async {
    await Permission.storage.request();
  }
}
