import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:truevote_mobile/models/izbor.dart';
import 'package:truevote_mobile/providers/izbor_provider.dart';
import 'package:truevote_mobile/providers/glas_provider.dart';

class IzborStatistikaScreen extends StatefulWidget {
  final Izbor izbor;
  const IzborStatistikaScreen({super.key, required this.izbor});

  @override
  State<IzborStatistikaScreen> createState() => _IzborStatistikaScreenState();
}

class _IzborStatistikaScreenState extends State<IzborStatistikaScreen> {
  bool _isLoading = true;
  List<dynamic> _kandidati = [];
  Map<int, int> _glasovi = {};

  @override
  void initState() {
    super.initState();
    _loadStatistika();
  }

  Future<void> _loadStatistika() async {
    setState(() => _isLoading = true);
    final izborProvider = Provider.of<IzborProvider>(context, listen: false);
    final glasProvider = Provider.of<GlasProvider>(context, listen: false);
    try {
      final kandidati = await izborProvider.getKandidatiByIzbor(widget.izbor.id!);
      Map<int, int> glasovi = {};
      for (final kandidat in kandidati) {
        final id = kandidat['id'];
        try {
          final broj = await glasProvider.getBrojGlasovaZaKandidata(id);
          glasovi[id] = broj;
        } catch (_) {
          glasovi[id] = 0;
        }
      }
      setState(() {
        _kandidati = kandidati;
        _glasovi = glasovi;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _kandidati = [];
        _glasovi = {};
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška pri dohvatanju statistike: $e")),
      );
    }
  }

  Color _generateColor(int idx, int total) {
    final hue = (idx * 360 / total) % 360;
    return HSVColor.fromAHSV(1, hue, 0.7, 0.85).toColor();
  }

  List<PieChartSectionData> _buildPieSections() {
    final ukupno = _glasovi.values.fold<int>(0, (a, b) => a + b);
    if (_kandidati.isEmpty || ukupno == 0) {
      return [
        PieChartSectionData(
          value: 1,
          color: Colors.grey[300],
          title: 'Nema glasova',
          titleStyle: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ];
    }
    return List.generate(_kandidati.length, (idx) {
      final kandidat = _kandidati[idx];
      final broj = _glasovi[kandidat['id']] ?? 0;
      final percent = ukupno > 0 ? (broj / ukupno * 100).toStringAsFixed(1) : "0";
      return PieChartSectionData(
        value: broj.toDouble(),
        color: _generateColor(idx, _kandidati.length),
        title: "$percent%",
        radius: 60,
        titleStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final izbor = widget.izbor;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Statistika izbora",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF2F6FF),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : _kandidati.isEmpty
              ? const Center(
                  child: Text(
                    "Nema kandidata za ovaj izbor.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                izbor.tipIzbora?.naziv ?? "Nepoznat tip izbora",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.location_city, color: Colors.blueGrey, size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    izbor.tipIzbora?.opstina?.naziv ?? "-",
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.blueGrey, size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    izbor.tipIzbora?.opstina?.grad?.naziv ?? "-",
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.flag, color: Colors.blueGrey, size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    izbor.tipIzbora?.opstina?.grad?.drzava?.naziv ?? "-",
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.info_outline, color: Colors.blueGrey, size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Status: ${izbor.status ?? "-"}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        "Statistika kandidata",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(_kandidati.length, (idx) {
                        final kandidat = _kandidati[idx];
                        final brojGlasova = _glasovi[kandidat['id']] ?? 0;
                        final color = _generateColor(idx, _kandidati.length);
                        return Column(
                          children: [
                            ListTile(
                              leading: kandidat['slika'] != null && kandidat['slika'].toString().isNotEmpty
                                  ? CircleAvatar(
                                      backgroundImage: MemoryImage(base64Decode(kandidat['slika'])),
                                      backgroundColor: color,
                                      radius: 28,
                                    )
                                  : CircleAvatar(
                                      backgroundColor: color,
                                      radius: 28,
                                      child: const Icon(Icons.person, color: Colors.white, size: 28),
                                    ),
                              title: Text(
                                "${kandidat['ime'] ?? ''} ${kandidat['prezime'] ?? ''}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              subtitle: Text(
                                "Stranka: ${kandidat['stranka']?['naziv'] ?? '-'}",
                                style: const TextStyle(fontSize: 15),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.13),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.how_to_vote, color: Colors.blueAccent, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      "$brojGlasova",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (idx != _kandidati.length - 1)
                              const Divider(height: 18),
                          ],
                        );
                      }),
                      const SizedBox(height: 18),
                      const Text(
                        "Grafički prikaz",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 260,
                        child: PieChart(
                          PieChartData(
                            sections: _buildPieSections(),
                            centerSpaceRadius: 40,
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}