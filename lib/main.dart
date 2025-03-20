import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: SpeechReconitionPage(),
    );
  }
}

class SpeechReconitionPage extends StatefulWidget {
  const SpeechReconitionPage({super.key});

  @override
  State<SpeechReconitionPage> createState() => _SpeechReconitionPageState();
}

class _SpeechReconitionPageState extends State<SpeechReconitionPage> {
  final SpeechToText speech = SpeechToText();
  bool _speechEnabled = false;
  String _wordsSpoken = "";
  double _confidence = 0;
  List<stt.LocaleName> _availableLanguages = [];
  String _selectedLanguage = 'en_US'; // Default language

  @override
  void initState() {
    super.initState();
    requestAudioPermission();
  }

  Future<void> requestAudioPermission() async {
    var status2 =
        await [Permission.microphone, Permission.bluetoothConnect].request();

    if (status2.values.every((element) => element.isGranted)) {
      initspeech();
    } else {
      requestAudioPermission();
      await openAppSettings();
    }
  }

  void _startListening() async {
    await speech.listen(onResult: _resultListener, localeId: _selectedLanguage);
    setState(() {});
  }

  void _resultListener(result) async {
    setState(() {
      _wordsSpoken = result.recognizedWords;
      _confidence = result.confidence;
    });
  }

  void _stopListening() async {
    await speech.stop();
    setState(() {});
  }

  void initspeech() async {
    print("Hi");
    _speechEnabled = await speech.initialize(
      onError: (errorNotification) => print(errorNotification),
    );

    if (_speechEnabled) {
      _availableLanguages = await speech.locales();
      setState(() {});
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Voice Recognizer",
              style: TextStyle(color: Colors.white),
            ),
          ),
          backgroundColor: Colors.green,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _languageSelection(),
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Text(
                  "Are you ready to speak? click on Mic Icon",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Text("$_wordsSpoken"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 200.0),
                child: Text(
                  "Confidence: ${_confidence * 100} %",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: speech.isListening ? _stopListening : _startListening,
          backgroundColor: speech.isListening ? Colors.red : Colors.green,
          child: Icon(speech.isNotListening ? Icons.mic : Icons.stop),
        ),
      ),
    );
  }

  Padding _languageSelection() {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: DropdownButton<String>(
        iconEnabledColor: Colors.white,
        focusColor: Colors.black,
        value: _selectedLanguage,
        items:
            _availableLanguages.map((locale) {
              return DropdownMenuItem(
                value: locale.localeId,
                child: Text(locale.name, style: TextStyle(color: Colors.black)),
              );
            }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedLanguage = value!;
          });
        },
      ),
    );
  }
}
