import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:truevote_desktop/models/glas.dart';
import 'package:truevote_desktop/providers/base_provider.dart';

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
}