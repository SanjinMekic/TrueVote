import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:truevote_mobile/screens/glasanje_screen.dart';
import 'package:truevote_mobile/screens/biometrija_screen.dart';
import 'package:truevote_mobile/screens/izbor_statistika_screen.dart';
import '../models/izbor.dart';
import '../providers/izbor_provider.dart';
import '../providers/glas_provider.dart';
import '../providers/auth_provider.dart';
import 'kandidat_detalji_screen.dart';

class IzborDetaljiScreen extends StatefulWidget {
  final Izbor izbor;
  const IzborDetaljiScreen({super.key, required this.izbor});

  @override
  State<IzborDetaljiScreen> createState() => _IzborDetaljiScreenState();
}

class _IzborDetaljiScreenState extends State<IzborDetaljiScreen> {
  bool _isLoading = true;
  List<dynamic> _kandidati = [];
  bool _jeZavrsioGlasanje = false;
  bool _provjeraGlasanjaLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKandidati();
    _provjeriJeLiZavrsioGlasanje();
  }

  Future<void> _loadKandidati() async {
    setState(() => _isLoading = true);
    final izborProvider = Provider.of<IzborProvider>(context, listen: false);
    try {
      final kandidati = await izborProvider.getKandidatiByIzbor(
        widget.izbor.id!,
      );
      setState(() {
        _kandidati = kandidati;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _kandidati = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška pri dohvatanju kandidata: $e")),
      );
    }
  }

  Future<void> _provjeriJeLiZavrsioGlasanje() async {
    setState(() {
      _provjeraGlasanjaLoading = true;
    });
    final glasProvider = Provider.of<GlasProvider>(context, listen: false);
    final korisnikId = AuthProvider.korisnikId;
    final izborId = widget.izbor.id;
    if (korisnikId == null || izborId == null) {
      setState(() {
        _jeZavrsioGlasanje = false;
        _provjeraGlasanjaLoading = false;
      });
      return;
    }
    try {
      final zavrsio = await glasProvider.jeLiZavrsioGlasanje(izborId, korisnikId);
      setState(() {
        _jeZavrsioGlasanje = zavrsio;
        _provjeraGlasanjaLoading = false;
      });
    } catch (e) {
      setState(() {
        _jeZavrsioGlasanje = false;
        _provjeraGlasanjaLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Greška pri provjeri glasanja: $e")),
      );
    }
  }

  String _formatDatum(DateTime? datum) {
    if (datum == null) return "-";
    return "${datum.day}.${datum.month}.${datum.year}. ${datum.hour.toString().padLeft(2, '0')}:${datum.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildKandidatSlika(String? slika) {
    if (slika == null || slika.isEmpty) {
      return const CircleAvatar(
        radius: 24,
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.person, color: Colors.white, size: 28),
      );
    }
    try {
      return CircleAvatar(
        radius: 24,
        backgroundImage: MemoryImage(
          Uri.parse(slika).data != null
              ? Uri.parse(slika).data!.contentAsBytes()
              : base64Decode(slika),
        ),
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

  void _kreniGlasanje() {
    final tipIzbora = widget.izbor.tipIzbora;
    final maxGlasova = tipIzbora?.maxBrojGlasova ?? 1;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BiometrijaScreen(
          onSuccess: () {
            Navigator.of(context).pop(); // zatvori biometriju
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => GlasanjeScreen(
                  kandidati: _kandidati,
                  maxBrojGlasova: maxGlasova,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final izbor = widget.izbor;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detalji izbora",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            tooltip: "Statistika",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => IzborStatistikaScreen(izbor: izbor),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF2F6FF),
      body: Padding(
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
                        const Icon(
                          Icons.location_city,
                          color: Colors.blueGrey,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          izbor.tipIzbora?.opstina?.naziv ?? "-",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.blueGrey,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          izbor.tipIzbora?.opstina?.grad?.naziv ?? "-",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.flag,
                          color: Colors.blueGrey,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          izbor.tipIzbora?.opstina?.grad?.drzava?.naziv ?? "-",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.date_range,
                          color: Colors.blueGrey,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Od: ${_formatDatum(izbor.datumPocetka)}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.date_range,
                          color: Colors.blueGrey,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Do: ${_formatDatum(izbor.datumKraja)}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.blueGrey,
                          size: 20,
                        ),
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
            const SizedBox(height: 24),
            const Text(
              "Kandidati",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 10),
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.blueAccent),
                  )
                : _kandidati.isEmpty
                ? const Text(
                    "Nema kandidata za ovaj izbor.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  )
                : Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _kandidati.length,
                      separatorBuilder: (_, __) => const Divider(height: 18),
                      itemBuilder: (context, index) {
                        final kandidat = _kandidati[index];
                        return ListTile(
                          leading: _buildKandidatSlika(kandidat['slika']),
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
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => KandidatDetaljiScreen(kandidat: kandidat),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 24),
_provjeraGlasanjaLoading
    ? const Center(child: CircularProgressIndicator())
    : Padding(
  padding: const EdgeInsets.symmetric(horizontal: 0),
  child: SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
      onPressed: _jeZavrsioGlasanje ? null : _kreniGlasanje,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.how_to_vote),
          SizedBox(width: 10),
          Text(
            "Započni glasanje",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  ),
),
            if (_jeZavrsioGlasanje && !_provjeraGlasanjaLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    "Glasali ste na ovom izboru.",
                    style: const TextStyle(
                      color: Color.fromARGB(255, 22, 228, 56),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}