import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:numberpicker/numberpicker.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
User? _user;

class PrescriptionPage extends StatefulWidget {
  const PrescriptionPage({Key? key}) : super(key: key);

  @override
  State<PrescriptionPage> createState() => _PrescriptionPageState();
}

class ContainerRow extends StatefulWidget {
  final String containerName;

  ContainerRow({required this.containerName});

  @override
  State<ContainerRow> createState() => _ContainerRowState();
}

class _ContainerRowState extends State<ContainerRow> {
  int _selectedNumber = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.containerName,
            style: TextStyle(fontSize: 20),
          ),
        ),
        SizedBox(width: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  _selectedNumber = (_selectedNumber - 1).clamp(0, 10);
                });
              },
            ),
            Text(
              '$_selectedNumber',
              style: TextStyle(fontSize: 24),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _selectedNumber = (_selectedNumber + 1).clamp(0, 10);
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _PrescriptionPageState extends State<PrescriptionPage> {
  final TextEditingController _textController = TextEditingController();
  final databaseReference = FirebaseDatabase.instance.reference();

  TimeOfDay? _selectedTime;
  int _selectedNumber = 0;

  bool _morningSelected = false;
  bool _lunchSelected = false;
  bool _dinnerSelected = false;

  // List of container names
  List<String> containerNames = [
    'container1',
    'container2',
    'container3',
    'container4',
    'container5',
    'container6',
    'container7',
    'container8',
  ];

  // Function to build each row
  Widget buildContainerRow(String containerName) {
    return ContainerRow(containerName: containerName);
  }

  void _selectTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
      initialEntryMode: TimePickerEntryMode.dial, // Set to dial for 24-hour clock
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Widget buildNumberPicker() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: () {
            setState(() {
              _selectedNumber = (_selectedNumber - 1).clamp(0, 10);
            });
          },
        ),
        Text(
          '$_selectedNumber',
          style: TextStyle(fontSize: 24),
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            setState(() {
              _selectedNumber = (_selectedNumber + 1).clamp(0, 10);
            });
          },
        ),
      ],
    );
  }

  Future<void> signIn() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: 'shamalbandara14@gmail.com',
        password: '12345678',
      );
    } on FirebaseAuthException catch (e) {
      // Handle authentication errors here
      print('Failed to sign in: $e');
    }
  }

  void _saveMessage() {
    signIn();
    String newMessage = _textController.text;

    int? hour = _selectedTime?.hour;
    int? minute = _selectedTime?.minute;

    Map<String, dynamic> newMessageData = {
      'text': newMessage,
      'morning': _morningSelected,
      'lunch': _lunchSelected,
      'dinner': _dinnerSelected,
      'selectedNumber': _selectedNumber,
      'hour': hour,
      'minute': minute,
    };

    databaseReference.child('messages').push().set(newMessageData);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Container Page'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _selectTime,
                  child: const Text('SELECT TIME'),
                ),
                const SizedBox(height: 16),
                if (_selectedTime != null)
                  Text(
                    'Selected Time: ${_selectedTime!.format(context)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                const SizedBox(height: 16),

                // Use ListView.builder to create the rows dynamically
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: containerNames.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        buildContainerRow(containerNames[index]),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveMessage,
                        child: const Text('SAVE'),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],

                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
