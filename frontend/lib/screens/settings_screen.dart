import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  static double playbackSpeed = 1.0;
  static int uncommonWordsCount = 1;
  static double volume = 0.8;

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            const Text(
              'Playback Speed',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Slider(
              value: SettingsScreen.playbackSpeed,
              min: 0.5,
              max: 2.0,
              divisions: 6,
              label: '${SettingsScreen.playbackSpeed.toStringAsFixed(1)}x',
              onChanged: (value) {
                setState(() => SettingsScreen.playbackSpeed = value);
              },
            ),
            const SizedBox(height: 30),
            const Text(
              'Uncommon Words Count',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            DropdownButton<int>(
              value: SettingsScreen.uncommonWordsCount,
              items: [1, 2, 3]
                  .map((count) => DropdownMenuItem(
                        value: count,
                        child: Text(count.toString()),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => SettingsScreen.uncommonWordsCount = value);
                }
              },
            ),
            const SizedBox(height: 30),
            const Text(
              'Volume',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Slider(
              value: SettingsScreen.volume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: '${(SettingsScreen.volume * 100).round()}%',
              onChanged: (value) {
                setState(() => SettingsScreen.volume = value);
              },
            ),
          ],
        ),
      ),
    );
  }
}

