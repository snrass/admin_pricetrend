import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (route == '/auth' && user != null) {
      // If user is logged in and tries to access auth screen, redirect to dashboard
      return RouteSettings(name: '/dashboard');
    }

    if (route == '/dashboard' && user == null) {
      // If user is not logged in and tries to access dashboard, redirect to auth
      return RouteSettings(name: '/auth');
    }

    return null;
  }
}
