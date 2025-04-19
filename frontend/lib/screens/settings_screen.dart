import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _playbackSpeed = 1.0;
  int _uncommonWordsCount = 1;
  double _volume = 0.8;

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
              value: _playbackSpeed,
              min: 0.5,
              max: 2.0,
              divisions: 6,
              label: '${_playbackSpeed.toStringAsFixed(1)}x',
              onChanged: (value) {
                setState(() => _playbackSpeed = value);
              },
            ),
            const SizedBox(height: 30),
            const Text(
              'Uncommon Words Count',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            DropdownButton<int>(
              value: _uncommonWordsCount,
              items: [1, 2, 3]
                  .map((count) => DropdownMenuItem(
                        value: count,
                        child: Text(count.toString()),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _uncommonWordsCount = value);
                }
              },
            ),
            const SizedBox(height: 30),
            const Text(
              'Volume',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Slider(
              value: _volume,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: '${(_volume * 100).round()}%',
              onChanged: (value) {
                setState(() => _volume = value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
