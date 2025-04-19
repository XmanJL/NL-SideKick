import 'package:flutter/material.dart';
import 'package:coolapp/screens/history_screen.dart';
import 'package:coolapp/screens/settings_screen.dart';
import 'speech_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Language Buddy',
      debugShowCheckedModeBanner: false,
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Language Buddy!'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ✅ Background image layer
          Positioned.fill(
            child: Image.asset(
              'assets/images/app-bg.jpg', // Make sure this matches your folder
              fit: BoxFit.cover,
            ),
          ),

          // ✅ Foreground content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  child: const Text(
                    'Hello! Ready to start learning?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: DashboardButton(
                    icon: Icons.mic,
                    label: 'Start Listening',
                    backgroundColor: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SpeechScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                DashboardButton(
                  icon: Icons.book,
                  label: 'Vocabulary History',
                  backgroundColor: Colors.deepPurple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                DashboardButton(
                  icon: Icons.settings,
                  label: 'Settings',
                  backgroundColor: Colors.grey,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;

  const DashboardButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor = Colors.teal,
  });

  @override
  State<DashboardButton> createState() => _DashboardButtonState();
}

class _DashboardButtonState extends State<DashboardButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: MediaQuery.of(context).size.width * 0.35,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _isPressed
              ? widget.backgroundColor.withOpacity(0.6)
              : widget.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isPressed
              ? [
                  const BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
