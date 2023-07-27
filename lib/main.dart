import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'priscription.dart';
import 'message.dart';
import 'screen1.dart';
import 'screen2.dart';
import 'screen3.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final databaseReference = FirebaseDatabase.instance.ref();

  List<Message> messages = [];


  //bottom nav
  int _currentIndex = 1;
  final List<Widget> _screens = [
    Screen1(),
    Screen2(),
    Screen3(),
  ];

  void fetchMessages() {
    databaseReference.child('messages').once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      messages.clear();
      Map<dynamic, dynamic> values =
          (snapshot.value as Map<dynamic, dynamic>).cast<dynamic, dynamic>();
      values.forEach((key, value) {
        String text = value["text"];
        int selectedNumber = value["selectedNumber"];
        Message message = Message(
          key: key,
          text: text,
          selectedNumber: selectedNumber,
        );
        messages.add(message);
      });
      setState(() {});
    }).catchError((error) {
      // Handle error if fetching messages fails
      print('Error: $error');
    });
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PrescriptionPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Edit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
  
      













