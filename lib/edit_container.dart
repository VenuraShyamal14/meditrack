import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meditrack/main.dart';
import 'package:numberpicker/numberpicker.dart';

class EditContainer extends StatefulWidget {
  final Message message;

  const EditContainer(this.message, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditContainerState();
}

class _EditContainerState extends State<EditContainer> {
  late TextEditingController _textController;
  final databaseReference = FirebaseDatabase.instance.reference();

  TimeOfDay? _selectedTime;
  int _selectedNumber = 1; // Define the _selectedNumber variable

  
  bool _morningSelected = false;
  bool _lunchSelected = false;
  bool _dinnerSelected = false;

@override
void initState() {
  super.initState();
  _textController = TextEditingController(text: widget.message.text);

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
          _morningSelected = values['morning'] ?? false;
          _lunchSelected = values['lunch'] ?? false;
          _dinnerSelected = values['dinner'] ?? false;
          _selectedNumber = values['selectedNumber'] ?? 1;
          
          // Retrieve the selected time from the Realtime Database
          int? hour = values['hour'];
          int? minute = values['minute'];
          if (hour != null && minute != null) {
            _selectedTime = TimeOfDay(hour: hour, minute: minute);
          }
        });
      }
    }
  }).catchError((error) {
    print('Error: $error');
  });
}





void _updateMessage() {
  String updatedMessage = _textController.text;
  String messageKey = widget.message.key;

  // Extract hour and minute from selectedTime if available
  int? hour = _selectedTime?.hour;
  int? minute = _selectedTime?.minute;

  Map<String, dynamic> updatedData = {
    'text': updatedMessage,
    'morning': _morningSelected,
    'lunch': _lunchSelected,
    'dinner': _dinnerSelected,
    'selectedNumber': _selectedNumber,
    'hour': hour,
    'minute': minute,
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

  void _selectTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _showNumberPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select a Number'),
        content: NumberPicker(
          minValue: 1,
          maxValue: 10,
          value: _selectedNumber,
          onChanged: (value) {
            setState(() {
              _selectedNumber = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Container Page'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    labelText: 'Edit',
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _morningSelected,
                      onChanged: (value) {
                        setState(() {
                          _morningSelected = value!;
                        });
                      },
                    ),
                    const Text('Morning'),
                    const SizedBox(width: 16),
                    Checkbox(
                      value: _lunchSelected,
                      onChanged: (value) {
                        setState(() {
                          _lunchSelected = value!;
                        });
                      },
                    ),
                    const Text('Lunch'),
                    const SizedBox(width: 16),
                    Checkbox(
                      value: _dinnerSelected,
                      onChanged: (value) {
                        setState(() {
                          _dinnerSelected = value!;
                        });
                      },
                    ),
                    const Text('Dinner'),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _showNumberPicker,
                  child: const Text('SELECT NUMBER OF PILLS'),
                ),
                const SizedBox(height: 16),
                Text(
                  'Selected Number: $_selectedNumber',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
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
