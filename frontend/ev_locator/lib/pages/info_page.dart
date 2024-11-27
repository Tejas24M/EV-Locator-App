import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Information'),
      ),
      body: SingleChildScrollView(  // Wrap the entire body in a scroll view
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Image.asset('assets/logo.png', width: 100, height: 100),
                  SizedBox(height: 10),
                  Text(
                    'Hmara EV',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            MenuOption(title: 'Contact Us', onTap: () {}),
            MenuOption(title: 'About', onTap: () {}),
            MenuOption(title: 'FAQ', onTap: () {}),
            MenuOption(title: 'Privacy', onTap: () {}),
            MenuOption(title: 'Refund', onTap: () {}),
            MenuOption(title: 'Feedback', onTap: () {}),
            SizedBox(height: 20),  // Add some space before social media section
            SocialMediaRow(),
            SizedBox(height: 10),
            Text(
              'IIT BOMBAY , Powai ,Mumbai,',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'https://haramaev.com/',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'info@hamaraev.com',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuOption extends StatelessWidget {
  final String title;
  final Function() onTap;

  MenuOption({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}

class SocialMediaRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: FaIcon(FontAwesomeIcons.facebook),
          onPressed: () {},
        ),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.instagram),
          onPressed: () {},
        ),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.twitter),
          onPressed: () {},
        ),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.youtube),
          onPressed: () {},
        ),
      ],
    );
  }
}
