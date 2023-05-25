import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:meditrack/main.dart';

class EditContainer extends StatefulWidget {
  final Message message; // Add a message parameter to the constructor

  const EditContainer(this.message);

  @override
  State<StatefulWidget> createState() => _EditContainerState();
}

class _EditContainerState extends State<EditContainer> {
  late TextEditingController _textController;
  final databaseReference = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.message.text);
  }

  void _updateMessage() {
    String updatedMessage = _textController.text;
    String messageKey = widget.message.key!;

    databaseReference
        .child('messages')
        .child(messageKey)
        .update({'text': updatedMessage})
        .then((_) {
      // Navigate back to the previous page
      Navigator.pop(context);
    }).catchError((error) {
      // Handle error if updating message fails
      print('Error: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Container Page'),
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
                  labelText: 'Edit',
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            ElevatedButton(
              onPressed: _updateMessage,
              child: const Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }
}
