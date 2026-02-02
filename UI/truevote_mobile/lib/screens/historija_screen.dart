import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/glas_provider.dart';
import '../providers/auth_provider.dart';
import '../models/izbor.dart';
import 'izbor_statistika_screen.dart';

class HistorijaScreen extends StatefulWidget {
  const HistorijaScreen({super.key});

  @override
  State<HistorijaScreen> createState() => _HistorijaScreenState();
}

class _HistorijaScreenState extends State<HistorijaScreen> {
  bool _isLoading = true;
  List<dynamic> _glasovi = [];

  @override
  void initState() {
    super.initState();
    _loadHistorija();
  }

  Future<void> _loadHistorija() async {
    setState(() => _isLoading = true);
    final glasProvider = Provider.of<GlasProvider>(context, listen: false);
    final korisnikId = AuthProvider.korisnikId;

    if (korisnikId != null) {
      try {
        final glasovi = await glasProvider.getGlasoviZaKorisnika(korisnikId);
        setState(() {
          _glasovi = glasovi;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _glasovi = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška pri dohvatanju historije glasanja: $e")),
        );
      }
    } else {
      setState(() {
        _glasovi = [];
        _isLoading = false;
      });
    }
  }

  String _formatDatum(String? datum) {
    if (datum == null) return "-";
    try {
      final date = DateTime.parse(datum);
      return DateFormat('d.M.yyyy. HH:mm').format(date);
    } catch (_) {
      return datum;
    }
  }

  Widget _buildKandidatSlika(dynamic kandidat) {
    final slika = kandidat?['slika'];
    if (slika == null || slika == "" || slika == "System.Byte[]") {
      return const CircleAvatar(
        radius: 24,
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.person, color: Colors.white, size: 28),
      );
    }
    try {
      return CircleAvatar(
        radius: 24,
        backgroundImage: MemoryImage(base64Decode(slika)),
        backgroundColor: Colors.grey[200],
      );
    } catch (_) {
      return const CircleAvatar(
        radius: 24,
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.person, color: Colors.white, size: 28),
      );
    }
  }

  Widget _buildGlasCard(dynamic glas) {
    final kandidat = glas['kandidat'];
    final izbor = kandidat?['izbor'];
    final tipIzbora = izbor?['tipIzbora'];

    return Card(
      elevation: 7,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildKandidatSlika(kandidat),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${kandidat?['ime'] ?? ''} ${kandidat?['prezime'] ?? ''}",
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      if (kandidat?['stranka']?['naziv'] != null)
                        Text(
                          "Stranka: ${kandidat?['stranka']?['naziv']}",
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                    ],
                  ),
                ),
                if (izbor != null)
                  IconButton(
                    icon: const Icon(Icons.bar_chart, color: Colors.blueAccent),
                    tooltip: "Statistika izbora",
                    onPressed: () {
                      final izborObj = Izbor.fromJson(Map<String, dynamic>.from(izbor));
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => IzborStatistikaScreen(
                            izbor: izborObj,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.how_to_vote, color: Colors.blueGrey, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    tipIzbora?['naziv'] ?? "-",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_city, color: Colors.blueGrey, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    tipIzbora?['opstina']?['naziv'] ?? "-",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.date_range, color: Colors.blueGrey, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Datum glasanja: ${_formatDatum(glas['vrijemeGlasanja'])}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Divider(),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.account_circle, color: Colors.blueGrey, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Ime: ${kandidat?['ime'] ?? '-'}",
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.account_circle_outlined, color: Colors.blueGrey, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Prezime: ${kandidat?['prezime'] ?? '-'}",
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            if (kandidat?['stranka']?['naziv'] != null)
              Row(
                children: [
                  const Icon(Icons.groups, color: Colors.blueGrey, size: 20),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Stranka: ${kandidat?['stranka']?['naziv']}",
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.blueGrey, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Početak: ${_formatDatum(izbor?['datumPocetka'])}",
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: Colors.blueGrey, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Kraj: ${_formatDatum(izbor?['datumKraja'])}",
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historija glasanja", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF2F6FF),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                  : _glasovi.isEmpty
                      ? const Center(
                          child: Text(
                            "Nemate evidentiranih glasanja.",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _glasovi.length,
                          itemBuilder: (context, index) => _buildGlasCard(_glasovi[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}