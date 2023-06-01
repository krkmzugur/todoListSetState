import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SessionManager {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> isLoggedIn() async {
    await init();
    return _prefs!.getBool('isLoggedIn') ?? false;
  }

  static Future<void> login(String username, String password) async {
    await init();

    final apiUrl =
        'http://192.168.1.94:1337/api/auth/local'; // API URL'nizi buraya ekleyin

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final jwt = data['jwt'] as String;
      final user = data['user'] as Map<String, dynamic>;

      await _prefs!.setBool('isLoggedIn', true);
      await _prefs!.setString('jwt', jwt);
      await saveUser(user); // Kullanıcı bilgilerini kaydet
    } else {
      throw Exception('Giriş yapılamadı. Hata kodu: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>?> getUser() async {
    await init();
    final userJson = _prefs!.getString('user');
    if (userJson != null) {
      return jsonDecode(userJson) as Map<String, dynamic>;
    }
    return null;
  }

  // static Future<Map<String, dynamic>> getProfileUser() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final userData = prefs.getStringList('user');
  //
  //   if (userData != null) {
  //     final user = {
  //       'id': int.parse(userData[0]),
  //       'username': userData[1],
  //       'email': userData[2],
  //       'provider': userData[3],
  //       'confirmed': userData[4] == 'true',
  //       'blocked': userData[5] == 'true',
  //       'createdAt': DateTime.parse(userData[6]),
  //       'updatedAt': DateTime.parse(userData[7]),
  //     };
  //
  //     return user;
  //   } else {
  //     throw Exception('Kullanıcı verisi bulunamadı.');
  //   }
  // }

  static Future<void> saveUser(Map<String, dynamic> user) async {
    await init();
    await _prefs!.setString('user', jsonEncode(user));
  }

  static Future<String?> getJwt() async {
    await init();
    final jwt = await _prefs!.getString('jwt');
    return jwt;
  }

  static Future<void> logout() async {
    await init();
    await _prefs!.setBool('isLoggedIn', false);
    await _prefs!.remove('jwt');
    await _prefs!.remove('user');
  }
}
