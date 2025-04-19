# Language Buddy

Presented by the Team 16: <mark>The No Lives</mark>

- **Team Member**: Rickey Ho, Jasper Liu, Jason Lin
- **3-min Demo** Link:

**Inspiration**: As a multilingual speaker, I often find it frustrating to keep up with lectures, especially when professors throw around technical jargons. Even in casual conversations, I sometimes feel awkward when I can’t recognize higher-level vocabulary used by my friends. That’s why our team built this app — as a set of training wheels to help bridge the gap in understanding and make communication smoother and more confident for non-native English speakers.

## Project Features

The Dashboard screen has the following options:

1. The Speech Screen: where the client will receive live audio input feedback and transcription display
2. The History Screen: where the client can review a scrollable list of challenging words and delete individual words
3. The Setting Screen: allows the client to adjust the Playback Speed (0.5x – 2.0x), Number of Uncommon Words (1-3), and Audio Volume (0–100%).

## Project Mechanism

A mobile app designed to help non-native English speakers understand the most challenging aspects of the English language.

1. Frontend: The app listens to the user's surroundings and captures the spoken sentence in real time. This sentence is then sent to the backend for analysis.

2. Backend: Using a frequency word database, the backend identifies the two least common, and therefore most challenging words in the sentence (excluding punctuation and numbers). It then sends the full sentence to the ChatGPT API, requesting a brief and simple explanation of those two uncommon words based on the sentence context.

3. Frontend (Audio Playback): The backend converts the explanation into an audio file and sends it back to the frontend, which plays the recording — helping the user understand the vocabulary in a seamless, spoken format.

## Next Steps
