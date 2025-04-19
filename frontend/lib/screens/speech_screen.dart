import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For saving to history
import 'package:speech_to_text_ultra/speech_to_text_ultra.dart';
import 'package:just_audio/just_audio.dart';
import 'settings_screen.dart';

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  bool _isListening = false;
  bool _showListeningPrompt = false;
  String _liveText = '';
  String _finalText = '';
  String _savedSentences = '';
  bool _wasListening = false;
  bool _hasSaved = false;

  // dynamic variables from settings screen
  double playback = SettingsScreen.playbackSpeed;
  int count = SettingsScreen.uncommonWordsCount;
  double volume = SettingsScreen.volume;

  // Method to save the recognized sentence to persistent history
  Future<void> _saveToHistory(String sentence) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> existing = prefs.getStringList('challengingWords') ?? [];

    if (sentence.trim().isNotEmpty && !existing.contains(sentence)) {
      existing.add(sentence.trim());
      await prefs.setStringList('challengingWords', existing);
      debugPrint('Saved to history: $sentence');
    }
  }

  String get _displayText {
    if (_showListeningPrompt) {
      return 'Listening...';
    } else if (!_isListening && _finalText.isEmpty) {
      return 'Tap the mic to start speaking';
    } else {
      return '$_finalText $_liveText';
    }
  }

  void _reset() {
    setState(() {
      _isListening = false;
      _liveText = '';
      _finalText = '';
      _showListeningPrompt = false;
      _wasListening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var player1 = AudioPlayer();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech Page', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instructional helper box
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(top: 16, bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  border: Border.all(color: Colors.teal.shade100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start receiving live audio input feedback and transcription display',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    Text(
                        '1. Toggle the microphone icon to start/stop recording.',
                        style: TextStyle(fontSize: 16)),
                    Text(
                        '2. Click "Help Me" to hear interpretation of the least common words.',
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),

              const Spacer(),

              // Display box showing live/final transcription
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                constraints: const BoxConstraints(
                  minHeight: 100,
                  maxHeight: 200,
                ),
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SingleChildScrollView(
                  child: Column(children: [
                    Text(
                      _displayText,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                  ]),
                ),
              ),

              const SizedBox(height: 16),

              // Show saved sentence below if one exists
              if (_savedSentences.isNotEmpty)
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Recognized Speech:\n$_savedSentences',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),

              // Speech input widget from speech_to_text_ultra package
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpeechToTextUltra(
                    ultraCallback: (liveText, finalText, isListening) {
                      if (isListening && !_wasListening) {
                        setState(() {
                          _showListeningPrompt = true;
                          _hasSaved = false;
                        });
                        Future.delayed(const Duration(seconds: 1), () {
                          if (mounted) {
                            setState(() {
                              _showListeningPrompt = false;
                            });
                          }
                        });
                      }

                      setState(() {
                        _liveText = liveText;
                        _isListening = isListening;
                        _wasListening = isListening;
                      });

                      if (!isListening && !_hasSaved) {
                        _hasSaved = true;

                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (!mounted) return;

                          String resultToSave = finalText.trim().isNotEmpty
                              ? finalText.trim()
                              : liveText.trim();

                          if (resultToSave.isNotEmpty) {
                            setState(() {
                              var spaceCount = 0;
                              var cutOffIndex = -1;

                              for (int i = resultToSave.length - 1;
                                  i >= 0;
                                  i--) {
                                if (resultToSave[i] == ' ') {
                                  spaceCount++;
                                }
                                if (spaceCount == 30) {
                                  cutOffIndex = i;
                                }
                              }
                              if (cutOffIndex != -1) {
                                resultToSave =
                                    resultToSave.substring(cutOffIndex).trim();
                              }

                              _savedSentences = resultToSave;
                            });

                            _saveToHistory(_savedSentences);

                            debugPrint(
                                'saved_sentence variable now has: $_savedSentences');
                            debugPrint('*Settings:');
                            debugPrint('Playback Speed: $playback');
                            debugPrint('Number of Uncommon Words: $count');
                            debugPrint('Volume Level: $volume');
                          }

                          _reset();
                        });
                      }
                    },
                    toStartIcon: const Icon(Icons.mic, size: 50),
                    toPauseIcon: const Icon(Icons.stop, size: 50),
                    startIconColor: Colors.teal,
                    pauseIconColor: Colors.red,
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 160,
                    height: 50,
                    child: FilledButton(
                      onPressed: () async {
                        await player1.setUrl(
                            'http://127.0.0.1:5000/content/$_savedSentences/$count');
                        player1.setVolume(volume);
                        player1.setSpeed(playback);
                        player1.play();
                      },
                      child:
                          const Text("Help me", style: TextStyle(fontSize: 18)),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
