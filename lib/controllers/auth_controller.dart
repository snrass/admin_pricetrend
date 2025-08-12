import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _isLogin = true.obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _isResetPassword = false.obs;
  final _isPasswordVisible = false.obs;

  bool get isLogin => _isLogin.value;

  bool get isLoading => _isLoading.value;

  bool get isResetPassword => _isResetPassword.value;

  bool get isPasswordVisible => _isPasswordVisible.value;

  String get errorMessage => _errorMessage.value;

  void toggleAuthMode() {
    _isLogin.value = !_isLogin.value;
    _isResetPassword.value = false;
    _errorMessage.value = '';
  }

  void toggleResetPassword() {
    _isResetPassword.value = !_isResetPassword.value;
    _errorMessage.value = '';
  }

  void togglePasswordVisibility() {
    _isPasswordVisible.value = !_isPasswordVisible.value;
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (_isResetPassword.value) {
        await _authService.resetPassword(email);
        Get.dialog(
          AlertDialog(
            title: Text('Success'),
            content: Text('Password reset link has been sent to your email'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text('OK'),
              ),
            ],
          ),
        );
        _isResetPassword.value = false;
      } else if (isLogin) {
        final result = await _authService.signIn(email, password);
        if (result != null) {
          // Clear form data for security
          emailController.clear();
          passwordController.clear();
          await Get.offAllNamed('/dashboard');
        } else {
          throw 'Invalid email or password';
        }
      } else {
        final result = await _authService.register(email, password);
        if (result != null) {
          // Clear form data for security
          emailController.clear();
          passwordController.clear();
          await Get.offAllNamed('/dashboard');
        } else {
          throw 'Failed to create account';
        }
      }
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading.value = true;
      await _authService.signOut();
      await Get.offAllNamed('/auth');

      // Clear form fields
      emailController.clear();
      passwordController.clear();
      _errorMessage.value = '';
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('OK'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
