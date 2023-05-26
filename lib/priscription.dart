import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:numberpicker/numberpicker.dart';

class PrescriptionPage extends StatefulWidget {
  const PrescriptionPage({Key? key}) : super(key: key);

  @override
  State<PrescriptionPage> createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends State<PrescriptionPage> {
  final TextEditingController _textController = TextEditingController();
  final databaseReference = FirebaseDatabase.instance.reference();

  TimeOfDay? _selectedTime;
  int _selectedNumber = 1;

  bool _morningSelected = false;
  bool _lunchSelected = false;
  bool _dinnerSelected = false;

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

  void _saveMessage() {
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
