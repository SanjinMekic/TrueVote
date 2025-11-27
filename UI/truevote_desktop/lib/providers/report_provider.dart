import 'dart:convert';

import 'package:http/http.dart' as client;
import 'package:truevote_desktop/models/report.dart';
import 'package:truevote_desktop/providers/base_provider.dart';

class ReportProvider extends BaseProvider<Report> {
  ReportProvider() : super("Report");

  @override
  Report fromJson(data) {
    return Report.fromJson(data);
  }

  Future<Report> getSummary() async {
    var url = "$baseUrl$endpoint/summary";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await client.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Greška pri dohvaćanju reporta: ${response.statusCode}");
    }
  }
}