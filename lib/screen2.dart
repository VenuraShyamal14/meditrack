import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'message.dart';
import 'edit_container.dart';

class Screen2 extends StatefulWidget {
  @override
  _Screen2State createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
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
        Message message = Message(
          key: key,
          text: text,
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
              Map<dynamic, dynamic> values =
                  dataValues.value as Map<dynamic, dynamic>;
              values.forEach((key, value) {
                Message message = Message(
                  key: key,
                  text: value['text'],
                );
                messages.add(message);
              });
            }

            return ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                Message message = messages[index];
                //deviding message to title and rest is for container pill count
                final splited = message.text.split(',');
                String title1 = splited[0];
                final splitedforTime = title1.split('');
                String hour = splitedforTime[0] + splitedforTime[1];
                String min = splitedforTime[2] + splitedforTime[3];
                String time = hour + ":" + min;

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
                      contentPadding: const EdgeInsets.all(
                          16.0), // Padding around the content
                      title: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        'Next Medication Time', // Replace with your desired subtitle text
        style: TextStyle(fontSize: 16), // Set the font size for the subtitle
      ),
      Text(
        time,
        style: const TextStyle(fontSize: 35), // Set the font size for the title
      ),
    ],
  ),
  trailing: const Icon(Icons.edit), // Edit icon
)
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
