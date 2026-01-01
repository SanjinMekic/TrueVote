import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:truevote_desktop/models/izbor.dart';
import 'package:truevote_desktop/providers/base_provider.dart';

class IzborProvider extends BaseProvider<Izbor> {
  IzborProvider() : super("Izbor");

  @override
  Izbor fromJson(data) {
    return Izbor.fromJson(data);
  }

    Future<bool> canDelete(int id) async {
    final url = Uri.parse('$baseUrl${endpoint}/$id/can-delete');
    final headers = createHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['canDelete'] == true;
    } else {
      throw Exception('Greška pri provjeri brisanja izbora');
    }
  }

   Future<List<dynamic>> getKandidatiByIzbor(int izborId) async {
    final url = Uri.parse('$baseUrl${endpoint}/$izborId/kandidati');
    final headers = createHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data as List<dynamic>;
    } else {
      throw Exception('Greška pri dohvatanju kandidata za izbor');
    }
  }
}