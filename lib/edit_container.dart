import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meditrack/main.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'message.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class EditContainer extends StatefulWidget {
  final Message message;

  const EditContainer(this.message, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditContainerState();
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


class _EditContainerState extends State<EditContainer> {
  final databaseReference = FirebaseDatabase.instance.ref();

  TimeOfDay? _selectedTime;
  List<String> containerNames = [];
  List<int> pickedNumbers = []; // List to store selected numbers
  int _selectedNumber = 1; // Define the _selectedNumber variable
  String text = 'a';
  String time = 'a';
  
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

    // Fetch current values from the Realtime Database
    databaseReference
        .child('messages')
        .child(widget.message.key)
        .once()
        .then((DatabaseEvent snapshot) {
      DataSnapshot data = snapshot.snapshot;
      if (data.value != null) {
        Map<dynamic, dynamic>? values = data.value as Map<dynamic, dynamic>?;
        if (values != null) {
          setState(() {
            text = values['text'] ?? false;
            String time1 = text.split(',')[0];
            time = time1.split('')[0] + time1.split('')[1] + ":" +time1.split('')[2] +time1.split('')[3];

          });
        }
      }
    }).catchError((error) {
      print('Error: $error');
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


  void _updateMessage() {
    //String updatedMessage = _textController.text;
    String messageKey = widget.message.key;

    int? hour = _selectedTime?.hour;
    int? minute = _selectedTime?.minute;

    String formattedTime = hour != null && minute != null
        ? '${hour.toString().padLeft(2, '0')}${minute.toString().padLeft(2, '0')}'
        : '0000';

    // Combine the time and selected numbers as a single line separated by commas

    String combinedData = '$formattedTime,${pickedNumbers.join(",")}';
    //int numericData = int.parse(combinedData);
    // Push the combined data to the Firebase database
 
    Map<String, dynamic> updatedData = {
      //'text': updatedMessage,
      'text': combinedData,
    };

    databaseReference
        .child('messages')
        .child(messageKey)
        .update(updatedData)
        .then((_) {
      Navigator.pop(context);
    }).catchError((error) {
      print('Error: $error');
    });
  }

  void _deleteMessage() {
    String messageKey = widget.message.key;

    databaseReference.child('messages').child(messageKey).remove().then((_) {
      Navigator.pop(context);
    }).catchError((error) {
      print('Error: $error');
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Container Page'),
      ),
      body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0) ,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Padding(padding: const EdgeInsets.all(16.0)),
                    Container(
                      child: Text(
                        
                        'Selected Time : ',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),

                    const SizedBox(width: 16),
                    // Wrap the Text widget inside a container or ListTile
                    Container(

                      child: Text(
                        time,
                        style: const TextStyle(fontSize: 35),
                      ),
                    ),
                  ],
                ),
                // Add more widgets if needed

                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _selectTime,
                  child: const Text('SELECT TIME'),
                ),

                const SizedBox(height: 16),
                if (_selectedTime != null)
                  Text(
                    'New Time: ${_selectedTime!.format(context)}',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _updateMessage,
                        child: const Text('SAVE'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _deleteMessage,
                        child: const Text('DELETE'),
                      ),
                    ),
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
