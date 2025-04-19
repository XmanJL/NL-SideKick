import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // This list holds the user's challenging words
  List<String> _challengingWords = [];

  @override
  void initState() {
    super.initState();
    _loadWords(); // Load from SharedPreferences when screen starts
  }

  // Load the challenging words from persistent storage
  Future<void> _loadWords() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _challengingWords = prefs.getStringList('challengingWords') ?? [];
    });
  }

  // Remove a word from the list and update SharedPreferences
  Future<void> _removeWord(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _challengingWords.removeAt(index);
      prefs.setStringList('challengingWords', _challengingWords);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('History Page', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: _challengingWords.isEmpty
          ? const Center(
              child: Text(
                'No challenging sentences yet!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'My List of Struggling Sentences:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _challengingWords.length,
                      itemBuilder: (context, index) {
                        final word = _challengingWords[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal,
                              child: Text(
                                '${index + 1}', // Index number
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              word,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              color: Colors.redAccent,
                              onPressed: () => _removeWord(index),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
