import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';



import 'refill.dart';
import 'login.dart';
import 'qr.dart';


final Uri _url = Uri.parse('http://notyabaya.rf.gd/index.php');

class Screen3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: buildButtonWithIconAndText(
                  icon: Icons.bolt,
                  label: 'Refill',
                  description: 'Refill your medication',
                  onPressed: () {
                    // Navigate to RefillScreen when Button 1 is pressed
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RefillScreen()),
                    );

                   
                  },
                ),
              ),
              Expanded(
                child: buildButtonWithIconAndText(
                  icon: Icons.app_shortcut_sharp,
                  label: 'Add Devices',
                  description: 'Add devices to the app',
                  onPressed: () {
                    // Navigate to RefillScreen when Button 1 is pressed
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QrScreen()),
                    );

                   
                  },
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: buildButtonWithIconAndText(
                  icon: Icons.logout,
                  label: 'Logout',
                  description: 'Log out from your account',
                  onPressed: () {
                    // Handle button 2 press
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AuthScreen()),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: buildButtonWithIconAndText(
                  icon: Icons.help,
                  label: 'Help',
                  description: 'Get help and support',
                  onPressed: _launchUrl,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
Future<void> _launchUrl() async {
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}
  Widget buildButtonWithIconAndText({
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: Color.fromARGB(22, 203, 198, 198),
        padding: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.black,
            size: 30,
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 25, color: Colors.black),
              ),
              Text(
                description,
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
