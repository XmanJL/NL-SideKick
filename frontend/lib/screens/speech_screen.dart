import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For saving to history
import 'package:speech_to_text_ultra/speech_to_text_ultra.dart';
import 'package:just_audio/just_audio.dart';
import 'settings_screen.dart';
import 'package:scrollable_text_indicator/scrollable_text_indicator.dart';

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

    // Add only if it's non-empty and not a duplicate
    if (sentence.trim().isNotEmpty && !existing.contains(sentence)) {
      existing.add(sentence.trim());
      await prefs.setStringList('challengingWords', existing);
      debugPrint('Saved to history: $sentence');
    }
  }

  // Text to display in the main speech bubble
  String get _displayText {
    if (_showListeningPrompt) {
      return 'Listening...';
    } else if (!_isListening && _finalText.isEmpty) {
      return 'Tap the mic to start speaking';
    } else {
      return '$_finalText $_liveText';
    }
  }



  // Resets live session state (not persistent saved sentence)
  void _reset() {
    setState(() {
      _isListening = false;
      _liveText = '';
      _finalText = '';
      _showListeningPrompt = false;
      _wasListening = false;
      // _hasSaved stays false until next session
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> tokenizedString;
    List<String> truncatedString;

    var player1 = AudioPlayer();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lang Bud'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
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
                      child: Column(
                      children:[Text(
                        _displayText,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 70),
                      ]
                    )
                  ),
            ),
              // Show saved sentence below if one exists
              const SizedBox(height: 10),
              if (_savedSentences.isNotEmpty)
                Container(
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

              const SizedBox(height: 10),

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

                      // When user stops talking and we haven't saved yet
                      if (!isListening && !_hasSaved) {
                        _hasSaved = true; // Lock to prevent saving again

                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (!mounted) return;

                          String resultToSave = finalText.trim().isNotEmpty
                              ? finalText.trim()
                              : liveText.trim();

                          if (resultToSave.isNotEmpty) {
                            setState(() {

                              var spaceCount = 0;
                              var cutOffIndex = -1;

                              for (int i = resultToSave.length - 1; i >= 0; i--){

                                if (resultToSave[i] == ' '){
                                  spaceCount++;
                                }
                                if (spaceCount == 30){
                                  cutOffIndex = i;
                                }
                              }
                              if (cutOffIndex != -1){

                                resultToSave = resultToSave.substring(cutOffIndex, resultToSave.length);

                              }

                              _savedSentences = resultToSave;
                            });

                            // Save the result into SharedPreferences history
                            _saveToHistory(_savedSentences);

                            debugPrint('saved_sentence variable now has: $_savedSentences');
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
                  const SizedBox(height: 10),
                  FilledButton(onPressed: () async {

                    await player1.setUrl('http://127.0.0.1:5000/content/$_savedSentences/$count');
                    player1.setVolume(volume);
                    player1.setSpeed(playback);
                    player1.play();
                  }, child: const Text("Help me"),


                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

