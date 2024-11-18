import 'package:flutter/material.dart';
import 'package:planma_app/user_profiile/edit_user.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String username = 'Johndoe';
  String firstName = 'John';
  String lastName = 'Doe';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.yellow,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              username,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$firstName $lastName',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final updatedData = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(
                      username: username,
                      firstName: firstName,
                      lastName: lastName,
                    ),
                  ),
                );

                if (updatedData != null) {
                  setState(() {
                    username = updatedData['username'];
                    firstName = updatedData['firstName'];
                    lastName = updatedData['lastName'];
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                backgroundColor: Color(0xFF173F70),
              ),
              child: Text(
                'Edit Profile',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.schedule),
                    title: Text('Sleep & Wake Time'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Handle Sleep & Wake Time tap
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.alarm),
                    title: Text('Reminder Offset'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Handle Reminder Offset tap
                    },
                  ),
                ],
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                // Handle Logout
              },
            ),
          ],
        ),
      ),
    );
  }
}
