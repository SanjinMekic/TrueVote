import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:truevote_mobile/screens/izbor_detalji_screen.dart';
import '../providers/izbor_provider.dart';
import '../providers/auth_provider.dart';
import '../models/izbor.dart';

class PocetnaScreen extends StatefulWidget {
  const PocetnaScreen({super.key});

  @override
  State<PocetnaScreen> createState() => _PocetnaScreenState();
}

class _PocetnaScreenState extends State<PocetnaScreen> {
  bool _isLoading = true;
  List<Izbor> _izbori = [];

  @override
  void initState() {
    super.initState();
    _loadIzbori();
  }

  Future<void> _loadIzbori() async {
    setState(() => _isLoading = true);

    final izborProvider = Provider.of<IzborProvider>(context, listen: false);
    final korisnikId = AuthProvider.korisnikId;

    if (korisnikId != null) {
      try {
        final izbori = await izborProvider.getAktivniIzboriZaKorisnika(korisnikId);
        setState(() {
          _izbori = izbori;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _izbori = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška pri dohvatanju izbora: $e")),
        );
      }
    } else {
      setState(() {
        _izbori = [];
        _isLoading = false;
      });
    }
  }

  String _formatDatum(DateTime? datum) {
    if (datum == null) return "-";
    return DateFormat('d.M.yyyy. HH:mm').format(datum);
  }

  Widget _buildIzborCard(Izbor izbor) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.how_to_vote, color: Colors.white, size: 28),
                  radius: 26,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    izbor.tipIzbora?.naziv ?? "Nepoznat tip izbora",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        izbor.status ?? "",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.location_city, color: Colors.blueGrey, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    izbor.tipIzbora?.opstina?.naziv ?? "-",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blueGrey, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    izbor.tipIzbora?.opstina?.grad?.naziv ?? "-",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.flag, color: Colors.blueGrey, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    izbor.tipIzbora?.opstina?.grad?.drzava?.naziv ?? "-",
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
                    "Od: ${_formatDatum(izbor.datumPocetka)}",
                    style: const TextStyle(fontSize: 16),
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
                    "Do: ${_formatDatum(izbor.datumKraja)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.info_outline, size: 20),
                label: const Text("Detalji"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  elevation: 2,
                ),
                onPressed: () {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => IzborDetaljiScreen(izbor: izbor),
    ),
  );
},
              ),
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
        title: const Text("Početna", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF2F6FF),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text(
              "Aktivni izbori u vašoj opštini",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                  : _izbori.isEmpty
                      ? const Center(
                          child: Text(
                            "Trenutno nema aktivnih izbora u vašoj opštini.",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _izbori.length,
                          itemBuilder: (context, index) => _buildIzborCard(_izbori[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}