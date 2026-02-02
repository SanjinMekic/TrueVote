import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:truevote_desktop/layouts/master_screen.dart';
import 'package:truevote_desktop/providers/stranka_provider.dart';
import 'package:truevote_desktop/models/stranka.dart';
import 'package:url_launcher/url_launcher.dart';
import 'stranka_form_screen.dart';

class StrankaScreen extends StatefulWidget {
  const StrankaScreen({super.key});

  @override
  State<StrankaScreen> createState() => _StrankaScreenState();
}

class _StrankaScreenState extends State<StrankaScreen> {
  final _nazivController = TextEditingController();
  String? _nazivFilter;

  @override
  void dispose() {
    _nazivController.dispose();
    super.dispose();
  }

  Future<List<Stranka>> _fetchStranke() async {
    final provider = Provider.of<StrankaProvider>(context, listen: false);
    final filter = {
      if (_nazivFilter != null && _nazivFilter!.isNotEmpty) 'naziv': _nazivFilter,
    };
    final result = await provider.get(filter: filter);
    return result.result;
  }

  void _onSearch() {
    setState(() {
      _nazivFilter = _nazivController.text.isNotEmpty ? _nazivController.text : null;
    });
  }

  void _onClear() {
    _nazivController.clear();
    setState(() {
      _nazivFilter = null;
    });
  }

  Future<void> _tryDeleteStranka(Stranka stranka) async {
    final provider = Provider.of<StrankaProvider>(context, listen: false);
    bool canDelete = false;
    String? error;

    try {
      canDelete = await provider.canDelete(stranka.id);
    } catch (e) {
      error = "Greška pri provjeri mogućnosti brisanja.";
    }

    if (!canDelete) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Brisanje nije dozvoljeno"),
          content: Text(
            "Stranka '${stranka.naziv ?? ''}' ima kandidate koji su dio te stranke i ne može biti obrisana.",
            style: const TextStyle(color: Colors.red),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("U redu"),
            ),
          ],
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Potvrda brisanja"),
        content: Text(
          "Da li ste sigurni da želite obrisati '${stranka.naziv ?? ''}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Otkaži"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              "Obriši",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await provider.delete(stranka.id);
      setState(() {});
    }
  }

  void _openStrankaForm({Stranka? stranka}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StrankaFormScreen(stranka: stranka),
      ),
    );
    if (result == true) {
      setState(() {});
    }
  }

  Widget _buildLogo(Stranka stranka) {
    if (stranka.logo != null && stranka.logo!.isNotEmpty) {
      try {
        final bytes = base64Decode(stranka.logo!);
        return ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: Image.memory(
            bytes,
            width: 70,
            height: 70,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildDefaultLogo(),
          ),
        );
      } catch (e) {
        if (stranka.logo!.startsWith('http')) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: Image.network(
              stranka.logo!,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildDefaultLogo(),
            ),
          );
        }
      }
    }
    return _buildDefaultLogo();
  }

  Widget _buildDefaultLogo() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(Icons.how_to_vote, color: Colors.white, size: 35),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ne mogu otvoriti link: $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Administracija stranaka",
      Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nazivController,
                    decoration: InputDecoration(
                      labelText: "Pretraga po nazivu stranke",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text("Pretraži"),
                  onPressed: _onSearch,
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.clear),
                  label: const Text("Očisti filter"),
                  onPressed: _onClear,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Dodaj stranku"),
                  onPressed: () => _openStrankaForm(),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Stranka>>(
                future: _fetchStranke(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Greška pri učitavanju stranaka.",
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                  final stranke = snapshot.data ?? [];
                  if (stranke.isEmpty) {
                    return const Center(
                      child: Text(
                        "Nema stranaka.",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: stranke.length,
                    itemBuilder: (context, index) {
                      final stranka = stranke[index];
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.grey.shade50,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                              spreadRadius: 2,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.blueAccent.withOpacity(0.1),
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              height: 90,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                ),
                              ),
                              child: Center(
                                child: _buildLogo(stranka),
                              ),
                            ),
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(height: 74),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        stranka.naziv ?? "",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    if (stranka.opis != null && stranka.opis!.isNotEmpty)
                                      Container(
                                        height: 70,
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.blueAccent.withOpacity(0.2),
                                          ),
                                        ),
                                        child: SingleChildScrollView(
                                          child: Text(
                                            stranka.opis!,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black87,
                                              height: 1.3,
                                            ),
                                            textAlign: TextAlign.justify,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 12),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.blueAccent.withOpacity(0.2),
                                          ),
                                        ),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (stranka.datumOsnivanja != null)
                                                _buildInfoRow(
                                                  Icons.calendar_today,
                                                  "Osnovan",
                                                  DateFormat('dd.MM.yyyy.').format(stranka.datumOsnivanja!),
                                                ),
                                              if (stranka.brojClanova != null)
                                                _buildInfoRow(
                                                  Icons.people,
                                                  "Članovi",
                                                  "${stranka.brojClanova}",
                                                ),
                                              if (stranka.sjediste != null && stranka.sjediste!.isNotEmpty)
                                                _buildInfoRow(
                                                  Icons.location_on,
                                                  "Sjedište",
                                                  stranka.sjediste!,
                                                ),
                                              if (stranka.webUrl != null && stranka.webUrl!.isNotEmpty)
                                                _buildWebRow(stranka.webUrl!),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            icon: const Icon(Icons.edit, size: 16),
                                            label: const Text("Uredi", style: TextStyle(fontSize: 12)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blueAccent,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              padding: const EdgeInsets.symmetric(vertical: 6),
                                            ),
                                            onPressed: () => _openStrankaForm(stranka: stranka),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            icon: const Icon(Icons.delete, size: 16),
                                            label: const Text("Obriši", style: TextStyle(fontSize: 12)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.redAccent,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              padding: const EdgeInsets.symmetric(vertical: 6),
                                            ),
                                            onPressed: () => _tryDeleteStranka(stranka),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.blueAccent),
          const SizedBox(width: 6),
          Text(
            "$label:",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebRow(String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.link, size: 14, color: Colors.blueAccent),
          const SizedBox(width: 6),
          const Text(
            "Web:",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () => _launchUrl(url),
              child: Text(
                url,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.blueAccent,
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}