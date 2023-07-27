import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RefillScreen extends StatefulWidget {
  @override
  _RefillScreenState createState() => _RefillScreenState();
}

class _RefillScreenState extends State<RefillScreen> {
  int selectedValue = 1; // Initial selected value for the number picker
  bool isRefilling = false; // Flag to track whether refilling is in progress

  void _increaseValue() {
    if (selectedValue < 8) {
      setState(() {
        selectedValue++;
      });
    }
  }

  void _decreaseValue() {
    if (selectedValue > 1) {
      setState(() {
        selectedValue--;
      });
    }
  }

  void _startRefilling() {
    // Disable the back button when "Start" is pressed
    setState(() {
      isRefilling = true;
    });

    // Set Firebase Realtime Database settings to true
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
    databaseReference.child('settings/mode').set(1);
    databaseReference.child('settings/container').set(selectedValue);
  }

  void _finishRefilling() {
    // Enable the back button when "Finish" is pressed
    setState(() {
      isRefilling = false;
    });

    // Handle "Finish" button press
    // Add your code here
    // Set Firebase Realtime Database settings to true
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
    databaseReference.child('settings/mode').set(0);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !isRefilling, // Disable back button if refilling is in progress
      child: Scaffold(
        appBar: AppBar(
          title: Text('Refill Screen'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Select the container to refill',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _decreaseValue,
                    icon: Icon(Icons.remove),
                  ),
                  SizedBox(width: 16),
                  Text(
                    selectedValue.toString(),
                    style: TextStyle(fontSize: 25),
                  ),
                  SizedBox(width: 16),
                  IconButton(
                    onPressed: _increaseValue,
                    icon: Icon(Icons.add),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: isRefilling ? null : _startRefilling, // Disable "Start" button when refilling is in progress
                    child: Text('Start'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _finishRefilling,
                    
                    child: Text('Finish'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
