

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';



class PrescriptionPage extends StatefulWidget {
  const PrescriptionPage({super.key});

  @override
  State<PrescriptionPage> createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends State<PrescriptionPage> {
  final TextEditingController _textController = TextEditingController();
  final databaseReference = FirebaseDatabase.instance.reference();

  void _sendMessage() {
    String message = _textController.text;
    _textController.clear();

    databaseReference.child('messages').push().set({
      'text': message,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Page'),
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
                    setState(() {});
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _sendMessage,
                child: const Text('Send'),
              ),
            ]),
      ),
    );
  }
}