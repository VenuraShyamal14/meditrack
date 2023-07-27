import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class PrescriptionPage extends StatefulWidget {
  const PrescriptionPage({Key? key}) : super(key: key);

  @override
  State<PrescriptionPage> createState() => _PrescriptionPageState();
}

class ContainerRow extends StatefulWidget {
  final String containerName;
  final ValueChanged<int>
      onSelectedNumberChanged; // Callback to notify selected number changes

  const ContainerRow({
    required this.containerName,
    required this.onSelectedNumberChanged,
  });

  @override
  State<ContainerRow> createState() => _ContainerRowState();
}

class _ContainerRowState extends State<ContainerRow> {
  int _selectedNumber = 0;

  // Method to get the selected number
  int getSelectedNumber() {
    return _selectedNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.containerName,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(width: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  _selectedNumber = (_selectedNumber - 1).clamp(0, 10);
                  widget.onSelectedNumberChanged(_selectedNumber);
                });
              },
            ),
            Text(
              '$_selectedNumber',
              style: const TextStyle(fontSize: 24),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _selectedNumber = (_selectedNumber + 1).clamp(0, 10);
                  widget.onSelectedNumberChanged(_selectedNumber);
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
  final databaseReference = FirebaseDatabase.instance.ref();

  TimeOfDay? _selectedTime;
  List<String> containerNames = [];
  List<int> pickedNumbers = []; // List to store selected numbers

  @override
  void initState() {
    super.initState();
    // Call the function to retrieve the stored data when the widget is initialized
    getContainerData().then((data) {
      setState(() {
        containerNames = data;
        pickedNumbers =
            List.filled(containerNames.length, 0); // Initialize with zeros
      });
    });
  }

  // Function to retrieve the stored data or return a default list
  Future<List<String>> getContainerData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedData = prefs.getString('container_data');

    if (storedData != null && storedData.isNotEmpty) {
      List<String> containerData = storedData.split(',');
      return containerData;
    } else {
      // Return the default list if no data was saved
      return [
        'container1',
        'container2',
        'container3',
        'container4',
        'container5',
        'container6',
        'container7',
        'container8',
      ];
    }
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
      initialEntryMode:
          TimePickerEntryMode.dial, // Set to dial for 24-hour clock
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
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

    int? hour = _selectedTime?.hour;
    int? minute = _selectedTime?.minute;

    String formattedTime = hour != null && minute != null
        ? '${hour.toString().padLeft(2, '0')}${minute.toString().padLeft(2, '0')}'
        : '0000';

    // Combine the time and selected numbers as a single line separated by commas

    String combinedData = '$formattedTime,${pickedNumbers.join(",")}';
    //int numericData = int.parse(combinedData);
    // Push the combined data to the Firebase database

       Map<String, dynamic> newMessageData = {
      'text': combinedData,
    };

    databaseReference.child('messages').push().set(newMessageData);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medication'),
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
                        ContainerRow(
                          containerName: containerNames[index],
                          onSelectedNumberChanged: (value) {
                            setState(() {
                              pickedNumbers[index] = value;
                            });
                          },
                        ),
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
