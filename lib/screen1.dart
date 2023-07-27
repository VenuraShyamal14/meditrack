import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Screen1 extends StatefulWidget {
  @override
  _Screen1State createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  List<String> labels = [
    'Container 1',
    'Container 2',
    'Container 3',
    'Container 4',
    'Container 5',
    'Container 6',
    'Container 7',
    'Container 8',
  ];

  List<TextEditingController> controllers = [];
@override
  void initState() {
    super.initState();
    // Initialize the list of TextEditingController
    controllers = List.generate(labels.length, (index) => TextEditingController());

    // Call the function to retrieve the stored data when the widget is initialized
    getContainerData().then((data) {
      setState(() {
        labels = data;
        // Assign the saved data to the corresponding TextEditingController
        for (int i = 0; i < labels.length; i++) {
          controllers[i].text = labels[i];
        }
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
        'Container 1',
        'Container 2',
        'Container 3',
        'Container 4',
        'Container 5',
        'Container 6',
        'Container 7',
        'Container 8',
      ];
    }
  }

   @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Customize Containers'),
    ),
    body: SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (int i = 0; i < labels.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Text('Container ${i + 1}:'),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: controllers[i], // Use the TextEditingController
                          decoration: InputDecoration(border: OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                // Clear the text field when the icon is pressed
                                controllers[i].clear();
                              },),
                        ),
                      ),
                      )
                    ],
                  ),
                ),
              ElevatedButton(
                onPressed: () async {
                  // Check if any of the text fields is empty
                  if (controllers.any((controller) => controller.text.isEmpty)) {
                    // Show an error snackbar if any text field is empty
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter values in all fields!')),
                    );
                  } else {
                    // Save the data to local storage as a single string
                    String combinedData = controllers.map((controller) => controller.text).join(',');
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setString('container_data', combinedData);

                    // Show a snackbar to indicate successful saving
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Data saved successfully!')),
                    );

                    // Print the saved data to the console
                    String savedData = prefs.getString('container_data') ?? '';
                    print('Saved Data: $savedData');
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

}