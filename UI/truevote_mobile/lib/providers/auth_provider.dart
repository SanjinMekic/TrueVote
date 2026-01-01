import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:truevote_mobile/models/korisnik.dart';
import 'package:truevote_mobile/providers/base_provider.dart';

class AuthProvider extends BaseProvider<Korisnik> {
  AuthProvider() : super("Korisnik");

  static String? username;
  static String? password;
  static int? korisnikId;

  static void setUser(Korisnik korisnik) {
    korisnikId = korisnik.id;
  }

  Future<Korisnik?> login(String username, String password) async {
    try {
      final url = Uri.parse("${baseUrl}Korisnik/login");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final user = Korisnik.fromJson(jsonDecode(response.body));
        return user;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}