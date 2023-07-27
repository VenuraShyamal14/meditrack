import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'priscription.dart';
import 'edit_container.dart';

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
  final databaseReference = FirebaseDatabase.instance.reference();

  late Stream<int> _ledStream;
  List<Message> messages = [];


  //bottom nav
  int _currentIndex = 1;
  final List<Widget> _screens = [
    Screen1(),
    Screen2(),
    Screen3(),
  ];

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
      Map<dynamic, dynamic> values =
          (snapshot.value as Map<dynamic, dynamic>).cast<dynamic, dynamic>();
      values.forEach((key, value) {
        String text = value["text"];
        bool morning = value["morning"];
        bool lunch = value["lunch"];
        bool dinner = value["dinner"];
        int selectedNumber = value["selectedNumber"];
        Message message = Message(
          key: key,
          text: text,
          morning: morning,
          lunch: lunch,
          dinner: dinner,
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

  void onButton() {
    databaseReference.child('test/led').set(1);
  }

  void offButton() {
    databaseReference.child('test/led').set(0);
  }
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton.small(
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
        items: [
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
  
      


class Message {

  final String key;
  final String text;
  final bool morning;
  final bool lunch;
  final bool dinner;
  final int selectedNumber;

  Message({
    required this.key,
    required this.text,
    required this.morning,
    required this.lunch,
    required this.dinner,
    required this.selectedNumber,
  });
}



class Screen1 extends StatelessWidget {
  final List<String> labels = [
    'Container 1',
    'Container 2',
    'Container 3',
    'Container 4',
    'Container 5',
    'Container 6',
    'Container 7',
    'Container 8',
  ];

  final List<TextEditingController> controllers = List.generate(
    8,
    (index) => TextEditingController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customize Container'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: labels.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      labels[index],
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: controllers[index],
                      decoration: InputDecoration(
                        hintText: 'Enter medicine name',
                      ),
                      // You can add onChanged or controller to handle input.
                      // onChanged: (value) { ... },
                      // controller: yourController,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              // Save the data to local storage as a single string
              String combinedData = controllers.map((controller) => controller.text).join(',');
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('container_data', combinedData);

              // Show a snackbar to indicate successful saving
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('data saved successfully!')),
              );

              // Print the saved data to the console
              String savedData = prefs.getString('container_data') ?? '';
              print('Saved Data: $savedData');
            },
            child: Text('Save'),
          ),
        ),
      ),
    );
  }
}



class Screen2 extends StatelessWidget {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
  List<Message> messages = [];
  void fetchMessages() {
    // Your existing fetchMessages() function
    // ...

    databaseReference.child('messages').once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      messages.clear();
      Map<dynamic, dynamic> values =
          (snapshot.value as Map<dynamic, dynamic>).cast<dynamic, dynamic>();
      values.forEach((key, value) {
        String text = value["text"];
        bool morning = value["morning"];
        bool lunch = value["lunch"];
        bool dinner = value["dinner"];
        int selectedNumber = value["selectedNumber"];
        Message message = Message(
          key: key,
          text: text,
          morning: morning,
          lunch: lunch,
          dinner: dinner,
          selectedNumber: selectedNumber,
        );
        messages.add(message);
      });
      
    }).catchError((error) {
      // Handle error if fetching messages fails
      print('Error: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: databaseReference.child('messages').onValue,
        builder: (BuildContext context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasData) {
            DataSnapshot dataValues = snapshot.data!.snapshot;
            List<Message> messages = [];

            if (dataValues.value != null) {
              Map<dynamic, dynamic> values = dataValues.value as Map<dynamic, dynamic>;
              values.forEach((key, value) {
                Message message = Message(
                  key: key,
                  text: value['text'],
                  morning: value['morning'],
                  lunch: value['lunch'],
                  dinner: value['dinner'],
                  selectedNumber: value['selectedNumber'],
                );
                messages.add(message);
              });
            }

            return ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                Message message = messages[index];
                return InkWell(
                  onTap: () {
                    // Handle individual message tap
                    // You can access the specific message here
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditContainer(message),
                      ),
                    ).then((_) {
                      // Refresh messages after returning from the edit screen
                      fetchMessages();
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Background color
                      borderRadius: BorderRadius.circular(8.0), // Border radius
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5), // Shadow color
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3), // Shadow offset
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0), // Padding around the content
                      title: Text(message.text),
                      trailing: const Icon(Icons.edit), // Edit icon
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class Screen3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
      ),
      body: Center(
        child: Text('This is Screen 3'),
      ),
    );
  }
}

