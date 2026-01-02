import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class KandidatDetaljiScreen extends StatelessWidget {
  final Map<String, dynamic> kandidat;
  const KandidatDetaljiScreen({super.key, required this.kandidat});

  Widget _buildKandidatSlika(String? slika) {
    if (slika == null || slika.isEmpty) {
      return const CircleAvatar(
        radius: 48,
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.person, color: Colors.white, size: 56),
      );
    }
    try {
      return CircleAvatar(
        radius: 48,
        backgroundImage: MemoryImage(
          Uri.parse(slika).data != null
              ? Uri.parse(slika).data!.contentAsBytes()
              : base64Decode(slika),
        ),
        backgroundColor: Colors.grey[200],
      );
    } catch (_) {
      return const CircleAvatar(
        radius: 48,
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.person, color: Colors.white, size: 56),
      );
    }
  }

  Widget _buildStrankaLogo(String? logo) {
    if (logo == null || logo.isEmpty) {
      return const CircleAvatar(
        radius: 32,
        backgroundColor: Colors.green,
        child: Icon(Icons.flag, color: Colors.white, size: 36),
      );
    }
    try {
      return CircleAvatar(
        radius: 32,
        backgroundImage: MemoryImage(
          Uri.parse(logo).data != null
              ? Uri.parse(logo).data!.contentAsBytes()
              : base64Decode(logo),
        ),
        backgroundColor: Colors.grey[200],
      );
    } catch (_) {
      return const CircleAvatar(
        radius: 32,
        backgroundColor: Colors.green,
        child: Icon(Icons.flag, color: Colors.white, size: 36),
      );
    }
  }

  String _formatDatum(String? datum) {
    if (datum == null) return "-";
    try {
      final d = DateTime.parse(datum);
      return "${d.day}.${d.month}.${d.year}.";
    } catch (_) {
      return datum;
    }
  }

  void _openUrl(BuildContext context, String url) async {
  String fixedUrl = url.trim();
  if (!fixedUrl.startsWith('http://') && !fixedUrl.startsWith('https://')) {
    fixedUrl = 'https://$fixedUrl';
  }
  final uri = Uri.parse(fixedUrl);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Nije moguće otvoriti link.")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final stranka = kandidat['stranka'];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalji kandidata", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF2F6FF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Kandidat slika, ime i prezime
            _buildKandidatSlika(kandidat['slika']),
            const SizedBox(height: 18),
            Text(
              "${kandidat['ime'] ?? ''} ${kandidat['prezime'] ?? ''}",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Stranka card
            if (stranka != null)
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildStrankaLogo(stranka['logo']),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              stranka['naziv'] ?? "-",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (stranka['opis'] != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline, color: Colors.blueGrey, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                stranka['opis'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      if (stranka['datumOsnivanja'] != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.blueGrey, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              "Osnovana: ${_formatDatum(stranka['datumOsnivanja'])}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                      if (stranka['brojClanova'] != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.people, color: Colors.blueGrey, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              "Broj članova: ${stranka['brojClanova']}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                      if (stranka['sjediste'] != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.blueGrey, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              "Sjedište: ${stranka['sjediste']}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                      if (stranka['webUrl'] != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.link, color: Colors.blueGrey, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _openUrl(context, stranka['webUrl']),
                                child: Text(
                                  stranka['webUrl'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.blueAccent,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}