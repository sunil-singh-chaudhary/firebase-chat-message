import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_services.dart';

class LifecycleManager with WidgetsBindingObserver {
  final BuildContext context;
  final String currentUserID;
  final String receiverID;
  final FirebaseServices _firebaseServices;

  LifecycleManager({
    required this.context,
    required this.currentUserID,
    required this.receiverID,
  }) : _firebaseServices =
            Provider.of<FirebaseServices>(context, listen: false) {
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  void _init() {
    log("Initialization code");
    _firebaseServices.isOnline(true, currentUserID);
    _firebaseServices.getUserOnlineStatus(receiverID);
  }

  void _dispose() {
    // Dispose code
    log("Dispose code");
    _firebaseServices.isOnline(false, currentUserID);
    _firebaseServices.getUserOnlineStatus(receiverID);
  }

  void _handleAppLifecycleStateChanged(AppLifecycleState state) {
    // Handle app lifecycle state changes
    log("App lifecycle state changed: $state");
    if (state == AppLifecycleState.paused) {
      _firebaseServices.isOnline(false, currentUserID);
      _firebaseServices.getUserOnlineStatus(receiverID);
    }
    if (state == AppLifecycleState.resumed) {
      _firebaseServices.isOnline(true, currentUserID);
      _firebaseServices.getUserOnlineStatus(receiverID);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _handleAppLifecycleStateChanged(state);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dispose();
  }
}
