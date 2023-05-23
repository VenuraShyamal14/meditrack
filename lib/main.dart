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
  late Stream<int> _ledStream;

  @override
  void initState() {
    super.initState();
    _ledStream = databaseReference.child('test/pot_value').onValue.map((event) {
      return event.snapshot.value as int;
    });
  }

  void _sendMessage() {
    String message = _textController.text;
    _textController.clear();

    databaseReference.child('messages').push().set({
      'text': message,
    });
  }

  void onButton() {
    databaseReference.child('test/led').set(1);
  }

  void offButton() {
    databaseReference.child('test/led').set(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MediTrack'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: 'Enter Prescription',
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
            StreamBuilder<int>(
  stream: _ledStream,
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      int? ledValue = snapshot.data;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          enabled: false,
          decoration: InputDecoration(
            labelText: 'Sensor Value',
          ),
          controller: TextEditingController(text: ledValue.toString()),
        ),
      );
    } else {
      return CircularProgressIndicator();
    }
  },
),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: onButton,
                  child: Text('ON'),
                ),
                SizedBox(width: 16),
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
