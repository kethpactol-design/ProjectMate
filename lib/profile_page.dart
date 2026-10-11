import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'change_password_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final String? userEmail;

  const ProfilePage({
    super.key,
    this.userEmail,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  XFile? profileImage;
  String? savedImagePath;

  String userName = '';
  String profileEmail = '';
  String profileCourse = '';
  String profileYearLevel = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserProfile();
    loadProfilePicture();
    loadSavedProfileDetails();
  }

    Future<void> loadSavedProfileDetails() async {
      final prefs = await SharedPreferences.getInstance();

      if (!mounted) return;

      setState(() {
        userName = prefs.getString('profileNickname') ?? userName;
        profileEmail = prefs.getString('profileEmail') ?? profileEmail;
        profileCourse = prefs.getString('profileCourse') ?? '';
        profileYearLevel = prefs.getString('profileYearLevel') ?? '';
      });
    }

  Future<void> loadUserProfile() async {
    if (widget.userEmail == null || widget.userEmail!.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final user = await DatabaseHelper.instance
          .getUserProfile(widget.userEmail!);

      if (!mounted) return;

      setState(() {
        userName = user?['name'] ?? '';
        profileEmail = user?['email'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profileImagePath');

    if (!mounted) return;

    setState(() {
      savedImagePath = path;
      if (path != null && File(path).existsSync()) {
        profileImage = XFile(path);
      }
    });
  }

  Future<void> loadNickname() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNickname = prefs.getString('profileNickname');

    if (!mounted) return;

    if (savedNickname != null && savedNickname.isNotEmpty) {
      setState(() {
        userName = savedNickname;
      });
    }
  }

  Future<void> editNickname() async {
    final controller = TextEditingController(text: userName);

    final nickname = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Nickname'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Enter your full name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                dialogContext,
                controller.text.trim(),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (!mounted || nickname == null || nickname.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileNickname', nickname);

    if (!mounted) return;

    setState(() {
      userName = nickname;
    });
  }

  Future<void> pickProfilePicture() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening gallery...')),
    );

    try {
      final ImagePicker picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) return;

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('profileImagePath', image.path);

      setState(() {
        profileImage = image;
        savedImagePath = image.path;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gallery error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFF246BFD),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              );

              if (result == true && mounted) {
                await loadSavedProfileDetails();
              }
            },
          ),
        ],
      ),
        body: SingleChildScrollView(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: pickProfilePicture,
              child: CircleAvatar(
                radius: 65,
                backgroundColor: const Color(0xFF246BFD),
                backgroundImage: profileImage != null
                    ? FileImage(File(profileImage!.path))
                    : null,
                child: profileImage == null
                    ? const Icon(
                  Icons.person,
                  size: 65,
                  color: Colors.white,
                )
                    : null,
              ),
            ),
        const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    userName.isEmpty ? 'Your Name' : userName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF172554),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E7FF)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  profileInfoRow(
                    Icons.person_outline,
                    'Nickname',
                    userName,
                  ),
                  const Divider(
                    height: 30,
                    thickness: 0.8,
                    color: Color(0xFFE0E7FF),
                  ),
                  profileInfoRow(
                    Icons.email_outlined,
                    'Email',
                    profileEmail,
                  ),
                  const Divider(
                    height: 30,
                    thickness: 0.8,
                    color: Color(0xFFE0E7FF),
                  ),
                  profileInfoRow(
                    Icons.school_outlined,
                    'Course',
                    profileCourse,
                  ),
                  const Divider(
                    height: 30,
                    thickness: 0.8,
                    color: Color(0xFFE0E7FF),
                  ),
                  profileInfoRow(
                    Icons.calendar_today_outlined,
                    'Year Level',
                    profileYearLevel,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

          ],
        ),
      ),
        ),
    );
  }
  Widget profileInfoRow(
      IconData icon,
      String label,
      String value,
      ) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFE7F0FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF246BFD),
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value.isEmpty ? 'Not set' : value,
                style: const TextStyle(
                  color: Color(0xFF172554),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}