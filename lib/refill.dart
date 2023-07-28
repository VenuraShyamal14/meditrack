import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RefillScreen extends StatefulWidget {
  @override
  _RefillScreenState createState() => _RefillScreenState();
}

class _RefillScreenState extends State<RefillScreen> {
  ValueNotifier<int> selectedValueNotifier = ValueNotifier<int>(1);
  bool isRefilling = false;

  @override
  void initState() {
    super.initState();
    // Add a listener to update Firebase when the selectedValueNotifier changes
    selectedValueNotifier.addListener(() {
      _updateFirebaseContainer(selectedValueNotifier.value);
    });
  }

  void _increaseValue() {
    if (selectedValueNotifier.value < 8) {
      selectedValueNotifier.value++;
    }
  }

  void _decreaseValue() {
    if (selectedValueNotifier.value > 1) {
      selectedValueNotifier.value--;
    }
  }

  void _startRefilling() {
    setState(() {
      isRefilling = true;
    });

    DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
    databaseReference.child('settings/mode').set(1);
  }

  void _finishRefilling() {
    setState(() {
      isRefilling = false;
    });

    DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
    databaseReference.child('settings/mode').set(0);
  }

  void _updateFirebaseContainer(int value) {
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
    databaseReference.child('settings/container').set(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                ValueListenableBuilder<int>(
                  valueListenable: selectedValueNotifier,
                  builder: (context, value, _) {
                    return Text(
                      value.toString(),
                      style: TextStyle(fontSize: 25),
                    );
                  },
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
                  onPressed: isRefilling ? null : _startRefilling,
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
    );
  }
}