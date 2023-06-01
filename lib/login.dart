import 'package:flutter/material.dart';

import 'TodoListPage.dart';
import 'model/SessionManager.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController =
      TextEditingController(text: 'user1@gmail.com');
  final TextEditingController _passwordController =
      TextEditingController(text: '123456');

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hata'),
            content: Text('Lütfen kullanıcı adı ve şifre girin.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Tamam'),
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      await SessionManager.login(username, password);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TodoListPage()),
      );
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hata'),
            content: Text('Giriş yapılamadı. ${error.toString()}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Tamam'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
        title: Center(
          child: Text("Todo List"),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Kullanıcı Adı',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Şifre',
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Giriş butonuna tıklandığında yapılacak işlemler
                // Örneğin, giriş fonksiyonunu çağırabilirsiniz
                _login();
              },
              child: Text('Giriş Yap'),
            ),
          ],
        ),
      ),
    );
  }
}
