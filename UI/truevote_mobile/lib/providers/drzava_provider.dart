import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:truevote_mobile/models/drzava.dart';
import 'package:truevote_mobile/providers/base_provider.dart';

class DrzavaProvider extends BaseProvider<Drzava> {
  DrzavaProvider() : super("Drzava");

  @override
  Drzava fromJson(data) {
    return Drzava.fromJson(data);
  }

  Future<bool> canDelete(int id) async {
    final url = Uri.parse('$baseUrl${endpoint}/$id/can-delete');
    final headers = createHeaders();
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['canDelete'] == true;
    } else {
      throw Exception('Greška pri provjeri brisanja države');
    }
  }
}
