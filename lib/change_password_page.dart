import 'package:flutter/material.dart';
import 'database_helper.dart';

class ChangePasswordPage extends StatefulWidget {
  final String? userEmail;

  const ChangePasswordPage({
    super.key,
    this.userEmail,
  });

  @override
  State<ChangePasswordPage> createState() =>
      _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isSaving = false;
  bool hideCurrent = true;
  bool hideNew = true;
  bool hideConfirm = true;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> savePassword() async {
    final currentPassword = currentPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (widget.userEmail == null || widget.userEmail!.isEmpty) {
      showMessage('Your account email could not be found.');
      return;
    }

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      showMessage('Please fill in all fields.');
      return;
    }

    if (newPassword.length < 8) {
    showMessage('Your new password must be at least 8 characters.');
    return;
    }

    if (newPassword != confirmPassword) {
      showMessage('The new passwords do not match.');
      return;
    }

    if (currentPassword == newPassword) {
      showMessage('Choose a different new password.');
      return;
    }

    setState(() => isSaving = true);

    try {
      final success =
      await DatabaseHelper.instance.changeUserPassword(
        widget.userEmail!,
        currentPassword,
        newPassword,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully!'),
          ),
        );
        Navigator.pop(context);
      } else {
        showMessage('Your current password is incorrect.');
      }
    } catch (e) {
      showMessage('Could not change the password. Please try again.');
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: const Color(0xFF246BFD),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          const Icon(
          Icons.lock_reset,
          size: 70,
          color: Color(0xFF246BFD),
        ),
        const SizedBox(height: 16),
        const Text(
          'Update Your Password',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
          const Text(
            'Enter your current password and choose a new one.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          TextField(
            controller: currentPasswordController,
            obscureText: hideCurrent,
            decoration: InputDecoration(
              labelText: 'Current Password',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  hideCurrent ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() => hideCurrent = !hideCurrent);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: newPasswordController,
            obscureText: hideNew,
            decoration: InputDecoration(
              labelText: 'New Password',
              helperText: 'At least 8 characters',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_reset),
              suffixIcon: IconButton(
                icon: Icon(
                  hideNew ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() => hideNew = !hideNew);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: confirmPasswordController,
            obscureText: hideConfirm,
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.verified_user_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  hideConfirm ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() => hideConfirm = !hideConfirm);
                },
              ),
            ),
          ),
          const SizedBox(height: 28),

          ElevatedButton(
            onPressed: isSaving ? null : savePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF246BFD),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
              'Save Changes',
              style: TextStyle(fontSize: 16),
            ),
          ),
          ],
        ),
      ),
    );
  }
}