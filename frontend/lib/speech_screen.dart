import 'package:flutter/material.dart';
import 'package:speech_to_text_ultra/speech_to_text_ultra.dart';

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

  // Text to display
  String get _displayText {
    if (_showListeningPrompt) {
      return '🎙 Listening...';
    } else if (!_isListening && _finalText.isEmpty) {
      return '🎙 Tap the mic to start speaking';
    } else {
      return '$_finalText $_liveText';
    }
  }

  // Reset current listening state, but NOT saved sentences
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

              // Display box
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
                child: Center(
                  child: Text(
                    _displayText,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Show saved sentence
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

              // Mic button
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

                  // ✅ Move this guard to block all future saves immediately
                  if (!isListening && !_hasSaved) {
                    _hasSaved = true; // <-- mark it as saved BEFORE the delay

                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (!mounted) return;

                      String resultToSave = finalText.trim().isNotEmpty
                          ? finalText.trim()
                          : liveText.trim();

                      if (resultToSave.isNotEmpty) {
                        setState(() {
                          _savedSentences = '$resultToSave.';
                        });

                        // ✅ Print only once
                        debugPrint(
                            '✅ saved_sentence variable now has: $_savedSentences');
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
            ],
          ),
        ),
      ),
    );
  }
}
