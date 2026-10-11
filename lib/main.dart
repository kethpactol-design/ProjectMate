import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProjectMateApp());
}

class ProjectMateApp extends StatefulWidget {
  const ProjectMateApp({super.key});

  @override
  State<ProjectMateApp> createState() => _ProjectMateAppState();
}

class _ProjectMateAppState extends State<ProjectMateApp> {
  bool isLoggedIn = false;
  bool isChecking = true;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isChecking) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ProjectMate',
      theme: ThemeData(
        fontFamily: 'Arial',
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF003399),
              Color(0xFF001A55),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Blue waves at the bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 260,
              child: CustomPaint(
                painter: WavePainter(),
                child: Container(),
              ),
            ),

            // Welcome screen content
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // App logo
                  const Icon(
                    Icons.school,
                    size: 105,
                    color: Color(0xFF00BFFF),
                  ),

                  const Icon(
                    Icons.groups,
                    size: 115,
                    color: Colors.white,
                  ),

                  const SizedBox(height: 25),

                  // App name
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Project',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: 'Mate',
                          style: TextStyle(
                            color: Color(0xFF00A8FF),
                          ),
                        ),
                      ],
                    ),
                    style: TextStyle(
                      fontSize: 43,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // App slogan
                  const Text(
                    'Plan  ·  Track  ·  Achieve',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Get Started button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF001A55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 15),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 65),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Draw the blue waves
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // First wave
    paint.color = const Color(0xFF003DAD);

    final wave1 = Path();
    wave1.moveTo(0, size.height * 0.15);
    wave1.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.45,
      size.width,
      size.height * 0.10,
    );
    wave1.lineTo(size.width, size.height);
    wave1.lineTo(0, size.height);
    wave1.close();

    canvas.drawPath(wave1, paint);

    // Second wave
    paint.color = const Color(0xFF0066E8);

    final wave2 = Path();
    wave2.moveTo(0, size.height * 0.45);
    wave2.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.75,
      size.width,
      size.height * 0.40,
    );
    wave2.lineTo(size.width, size.height);
    wave2.lineTo(0, size.height);
    wave2.close();

    canvas.drawPath(wave2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// Temporary screen for the Get Started button
class NextScreen extends StatelessWidget {
  const NextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ProjectMate'),
        backgroundColor: const Color(0xFF003399),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Welcome to ProjectMate!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}