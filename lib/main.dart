import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediTrack',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final databaseReference = FirebaseDatabase.instance.reference();
  final TextEditingController _textController = TextEditingController();
  late Stream<int> _ledStream;
  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    _ledStream = databaseReference.child('test/pot_value').onValue.map((event) {
      return event.snapshot.value as int;
    });

    fetchMessages();
  }


void fetchMessages() {
  databaseReference.child('messages').once().then((DatabaseEvent event) {
    DataSnapshot snapshot = event.snapshot;
    messages.clear();
    Map<dynamic, dynamic> values = (snapshot.value as Map<dynamic, dynamic>).cast<dynamic, dynamic>();
    values.forEach((key, value) {
      Message message = Message(text: value["text"]);
      messages.add(message);
    });
    setState(() {});
  }).catchError((error) {
    // Handle error if fetching messages fails
    print('Error: $error');
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
        title: const Text('MediTrack'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Enter Prescription',
                ),
                onChanged: (value) {
                  setState(() {
                  });
                },
              ),
            ),
            ElevatedButton(
              onPressed: _sendMessage,
              child: const Text('Send'),
            ),
            StreamBuilder<int>(
              stream: _ledStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  int? ledValue = snapshot.data;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Sensor Value',
                      ),
                      controller: TextEditingController(text: ledValue.toString()),
                    ),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: onButton,
                  child: const Text('ON'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: offButton,
                  child: const Text('OFF'),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  Message message = messages[index];
                  return ListTile(
                    title: Text(message.text),
                    onTap: () {
                      // Handle individual message tap
                      // You can access the specific message here
                      print(message.text);
                    },
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

class Message {
  final String text;

  Message({required this.text});
}
