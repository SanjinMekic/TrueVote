import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:truevote_mobile/models/glas.dart';
import 'package:truevote_mobile/providers/base_provider.dart';

class GlasProvider extends BaseProvider<Glas> {
  GlasProvider() : super("Glas");

  @override
  Glas fromJson(data) {
    return Glas.fromJson(data);
  }

    Future<int> getBrojGlasovaZaKandidata(int kandidatId) async {
    final url = Uri.parse('$baseUrl${endpoint}/kandidat/$kandidatId/broj-glasova');
    final headers = createHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data as int;
    } else {
      throw Exception('Greška pri dohvatanju broja glasova za kandidata');
    }
  }

    Future<bool> jeLiZavrsioGlasanje(int izborId, int korisnikId) async {
    final url = Uri.parse('$baseUrl${endpoint}/provjera-zavrsenog-glasanja?izborId=$izborId&korisnikId=$korisnikId');
    final headers = createHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['zavrsio'] == true;
    } else {
      throw Exception('Greška pri provjeri završenog glasanja');
    }
  }

    Future<List<dynamic>> getGlasoviZaKorisnika(int korisnikId) async {
    final url = Uri.parse('$baseUrl${endpoint}/korisnik/$korisnikId/glasovi');
    final headers = createHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data as List<dynamic>;
    } else {
      throw Exception('Greška pri dohvatanju glasova za korisnika');
    }
  }
}