import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:truevote_desktop/models/korisnik.dart';
import 'package:truevote_desktop/providers/base_provider.dart';

class KorisnikProvider extends BaseProvider<Korisnik> {
  KorisnikProvider() : super("Korisnik");

  @override
  Korisnik fromJson(data) {
    return Korisnik.fromJson(data);
  }

  Future<bool> canDelete(int id) async {
    final url = Uri.parse('$baseUrl${endpoint}/$id/can-delete');
    final headers = createHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['canDelete'] == true;
    } else {
      throw Exception('Greška pri provjeri brisanja korisnika');
    }
  }

    Future<bool> provjeriStaruLozinku(int id, String staraLozinka) async {
    final url = Uri.parse('$baseUrl${endpoint}/$id/provjeri-staru-lozinku');
    final headers = createHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(staraLozinka),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['ispravna'] == true;
    } else {
      throw Exception('Greška pri provjeri stare lozinke');
    }
  }

  Future<bool> provjeriKorisnickoIme(String korisnickoIme) async {
    final url = Uri.parse('$baseUrl${endpoint}/provjeri-korisnicko-ime?korisnickoIme=$korisnickoIme');
    final headers = createHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['postoji'] == true;
    } else {
      throw Exception('Greška pri provjeri korisničkog imena');
    }
  }
}