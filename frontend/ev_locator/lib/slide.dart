import 'package:flutter/material.dart';
import 'main.dart';
import 'pages/login.dart';
import 'pages/info_page.dart'; // Import the new InfoPage

class SlideDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.blue], // Gradient from green to blue
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40, // Adjust the size of the avatar
                  backgroundImage: AssetImage('assets/profile.png'), // Add your profile image
                  backgroundColor: Colors.white, // Fallback background color
                ),
                SizedBox(height: 10),
                Text(
                    GlobalConfig().username.isEmpty
                        ? '@ashuraj437'
                        : '@${GlobalConfig().username}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          ListTile(
            leading: Icon(Icons.login),
            title: Text('Login'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Information'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InfoPage()), // Navigate to InfoPage
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              // Handle Logout action
            },
          ),
        ],
      ),
    );
  }
}
