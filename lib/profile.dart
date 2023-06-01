import 'package:flutter/material.dart';

import 'model/SessionManager.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        title: Center(
          child: Text(
            // '${_user?['username']}',
            'Profile Page',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: SessionManager.getUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final user = snapshot.data!;

            return ListView(
              padding: EdgeInsets.all(16.0),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: [
                CardListTile(
                    user: user,
                    title: 'User Name',
                    field: 'username',
                    icon: Icons.person),
                CardListTile(
                    user: user,
                    title: 'Email Adress',
                    field: 'email',
                    icon: Icons.email),
                CardListTile(
                    user: user,
                    title: 'Confirmed Status',
                    field: 'confirmed',
                    icon: Icons.verified_user),
                CardListTile(
                    user: user,
                    title: 'Blocked Status',
                    field: 'blocked',
                    icon: Icons.block),
              ],
            );
          } else {
            return Center(child: Text('User not found'));
          }
        },
      ),
    );
  }
}

class CardListTile extends StatelessWidget {
  CardListTile(
      {super.key,
      required this.user,
      required this.title,
      required this.field,
      required IconData this.icon});

  final Map<String, dynamic> user;
  final String title;
  final String field;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
          child: ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            title: Text(
              title,
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              user[field].toString() ?? '',
              style: TextStyle(color: Colors.white),
            ),
            leading: Container(
              padding: EdgeInsets.only(right: 12.0),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(width: 1.0, color: Colors.white24),
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),
          ),
        ));
  }
}
