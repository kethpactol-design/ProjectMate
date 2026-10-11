import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState
    extends State<EditProfilePage> {
  final nicknameController = TextEditingController();
  final emailController = TextEditingController();
  final courseController = TextEditingController();
  final yearLevelController = TextEditingController();

  @override
  void dispose() {
    nicknameController.dispose();
    emailController.dispose();
    courseController.dispose();
    yearLevelController.dispose();
    super.dispose();
  }

  Widget buildTextField(
      String label,
      TextEditingController controller,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> saveProfile() async {
    final nickname = nicknameController.text.trim();
    final email = emailController.text.trim();
    final course = courseController.text.trim();
    final yearLevel = yearLevelController.text.trim();

    if (nickname.isEmpty ||
        email.isEmpty ||
        course.isEmpty ||
        yearLevel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('profileNickname', nickname);
    await prefs.setString('profileEmail', email);
    await prefs.setString('profileCourse', course);
    await prefs.setString('profileYearLevel', yearLevel);

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF246BFD),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildTextField(
              'Nickname',
              nicknameController,
            ),
            buildTextField(
              'Email',
              emailController,
            ),
            buildTextField(
              'Course',
              courseController,
            ),
            buildTextField(
              'Year Level',
              yearLevelController,
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF246BFD),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),
                child: const Text('Save Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}