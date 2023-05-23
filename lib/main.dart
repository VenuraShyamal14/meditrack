import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Realtime Database Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final databaseReference = FirebaseDatabase.instance.reference();
  TextEditingController _textController = TextEditingController();
  String _text = '';

  void _sendMessage() {
    String message = _textController.text;
    _textController.clear();

    databaseReference.child('messages').push().set({
      'text': message,
    });
  }

  void onButton() {
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.child('test/led').set(1);
  }

  void offButton() {
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
    databaseReference.child('test/led').set(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Realtime Database Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center the content vertically
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 16), // Add horizontal padding of 16 pixels
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: 'Enter your message',
                ),
                onChanged: (value) {
                  setState(() {
                    _text = value;
                  });
                },
              ),
            ),
            ElevatedButton(
              onPressed: _sendMessage,
              child: Text('Send'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: onButton,
                  child: Text('ON'),
                ),
                SizedBox(
                    width: 16), // Add a gap of 16 pixels between the buttons
                ElevatedButton(
                  onPressed: offButton,
                  child: Text('OFF'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
