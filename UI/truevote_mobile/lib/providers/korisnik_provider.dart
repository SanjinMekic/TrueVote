import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:truevote_mobile/models/korisnik.dart';
import 'package:truevote_mobile/providers/base_provider.dart';

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

    Future<bool> kreirajPin(int id, String pin) async {
    final url = Uri.parse('$baseUrl${endpoint}/$id/pin');
    final headers = createHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(pin),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> provjeriPin(int id, String pin) async {
    final url = Uri.parse('$baseUrl${endpoint}/$id/pin/provjera');
    final headers = createHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(pin),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['valid'] == true;
    } else {
      return false;
    }
  }

  Future<Map<String, dynamic>> promijeniPinSaPorukom(int id, String stariPin, String noviPin) async {
    final url = Uri.parse('$baseUrl${endpoint}/$id/promijeni-pin');
    final headers = createHeaders();
    final body = jsonEncode({
      "stariPin": stariPin,
      "noviPin": noviPin,
    });

    final response = await http.put(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        "success": true,
        "message": data["message"] ?? "PIN je uspješno promijenjen."
      };
    } else {
      try {
        final data = jsonDecode(response.body);
        if (data["errors"] != null && data["errors"]["userError"] != null) {
          return {
            "success": false,
            "message": (data["errors"]["userError"] as List).join("\n")
          };
        }
        if (data["message"] != null) {
          return {
            "success": false,
            "message": data["message"]
          };
        }
        return {
          "success": false,
          "message": "Greška pri promjeni PIN-a!"
        };
      } catch (_) {
        return {
          "success": false,
          "message": "Greška pri promjeni PIN-a!"
        };
      }
    }
  }
}