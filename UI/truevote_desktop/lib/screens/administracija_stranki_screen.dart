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
      setState(() {}); // Refresh FutureBuilder
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
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            bytes,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildDefaultLogo(),
          ),
        );
      } catch (e) {
        if (stranka.logo!.startsWith('http')) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              stranka.logo!,
              width: 56,
              height: 56,
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
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.how_to_vote, color: Colors.blueAccent, size: 32),
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.7,
                    ),
                    itemCount: stranke.length,
                    itemBuilder: (context, index) {
                      final stranka = stranke[index];
                      return Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  _buildLogo(stranka),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      stranka.naziv ?? "",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (stranka.opis != null && stranka.opis!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    stranka.opis!,
                                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                                    maxLines: 6,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              Expanded(
                                child: Wrap(
                                  spacing: 16,
                                  runSpacing: 8,
                                  children: [
                                    if (stranka.datumOsnivanja != null)
                                      Chip(
                                        avatar: const Icon(Icons.calendar_today, size: 18, color: Colors.blueAccent),
                                        label: Text(
                                          DateFormat('dd.MM.yyyy.').format(stranka.datumOsnivanja!),
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        backgroundColor: Colors.blueAccent.withOpacity(0.08),
                                      ),
                                    if (stranka.brojClanova != null)
                                      Chip(
                                        avatar: const Icon(Icons.people, size: 18, color: Colors.blueAccent),
                                        label: Text(
                                          "${stranka.brojClanova} članova",
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        backgroundColor: Colors.blueAccent.withOpacity(0.08),
                                      ),
                                    if (stranka.sjediste != null && stranka.sjediste!.isNotEmpty)
                                      Chip(
                                        avatar: const Icon(Icons.location_on, size: 18, color: Colors.blueAccent),
                                        label: Text(
                                          stranka.sjediste!,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        backgroundColor: Colors.blueAccent.withOpacity(0.08),
                                      ),
                                    if (stranka.webUrl != null && stranka.webUrl!.isNotEmpty)
                                      ActionChip(
                                        avatar: const Icon(Icons.link, size: 18, color: Colors.blueAccent),
                                        label: SizedBox(
                                          width: 100,
                                          child: Text(
                                            stranka.webUrl!,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.blueAccent,
                                              decoration: TextDecoration.underline,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        onPressed: () => _launchUrl(stranka.webUrl!),
                                        backgroundColor: Colors.blueAccent.withOpacity(0.08),
                                      ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Tooltip(
                                    message: "Uredi",
                                    child: IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                      onPressed: () => _openStrankaForm(stranka: stranka),
                                    ),
                                  ),
                                  Tooltip(
                                    message: "Obriši",
                                    child: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                                      onPressed: () => _tryDeleteStranka(stranka),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
}