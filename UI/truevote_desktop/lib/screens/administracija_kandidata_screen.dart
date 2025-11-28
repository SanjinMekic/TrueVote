import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:truevote_desktop/layouts/master_screen.dart';
import 'package:truevote_desktop/providers/kandidat_provider.dart';
import 'package:truevote_desktop/models/kandidat.dart';
import 'kandidat_form_screen.dart';

class AdministracijaKandidataScreen extends StatefulWidget {
  const AdministracijaKandidataScreen({super.key});

  @override
  State<AdministracijaKandidataScreen> createState() => _AdministracijaKandidataScreenState();
}

class _AdministracijaKandidataScreenState extends State<AdministracijaKandidataScreen> {
  final _imeController = TextEditingController();
  final _prezimeController = TextEditingController();
  final _strankaNazivController = TextEditingController();
  final _izborNazivController = TextEditingController();

  String? _imeFilter;
  String? _prezimeFilter;
  String? _strankaNazivFilter;
  String? _izborNazivFilter;

  @override
  void dispose() {
    _imeController.dispose();
    _prezimeController.dispose();
    _strankaNazivController.dispose();
    _izborNazivController.dispose();
    super.dispose();
  }

  Future<List<Kandidat>> _fetchKandidati() async {
    final provider = Provider.of<KandidatProvider>(context, listen: false);
    final filter = {
      if (_imeFilter != null && _imeFilter!.isNotEmpty) 'ime': _imeFilter,
      if (_prezimeFilter != null && _prezimeFilter!.isNotEmpty) 'prezime': _prezimeFilter,
      if (_strankaNazivFilter != null && _strankaNazivFilter!.isNotEmpty) 'StrankaNaziv': _strankaNazivFilter,
      if (_izborNazivFilter != null && _izborNazivFilter!.isNotEmpty) 'IzborNaziv': _izborNazivFilter,
    };
    final result = await provider.get(filter: filter);
    return result.result;
  }

  void _onSearch() {
    setState(() {
      _imeFilter = _imeController.text.isNotEmpty ? _imeController.text : null;
      _prezimeFilter = _prezimeController.text.isNotEmpty ? _prezimeController.text : null;
      _strankaNazivFilter = _strankaNazivController.text.isNotEmpty ? _strankaNazivController.text : null;
      _izborNazivFilter = _izborNazivController.text.isNotEmpty ? _izborNazivController.text : null;
    });
  }

  void _onClear() {
    _imeController.clear();
    _prezimeController.clear();
    _strankaNazivController.clear();
    _izborNazivController.clear();
    setState(() {
      _imeFilter = null;
      _prezimeFilter = null;
      _strankaNazivFilter = null;
      _izborNazivFilter = null;
    });
  }

  Future<void> _tryDeleteKandidat(Kandidat kandidat) async {
    final provider = Provider.of<KandidatProvider>(context, listen: false);
    bool canDelete = false;
    String? error;

    try {
      canDelete = await provider.canDelete(kandidat.id);
    } catch (e) {
      error = "Greška pri provjeri mogućnosti brisanja.";
    }

    if (!canDelete) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Brisanje nije dozvoljeno"),
          content: Text(
            "Kandidat '${kandidat.ime ?? ''} ${kandidat.prezime ?? ''}' ima glasove u okviru izbora i ne može biti obrisan.",
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
          "Da li ste sigurni da želite obrisati '${kandidat.ime ?? ''} ${kandidat.prezime ?? ''}'?",
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
      await provider.delete(kandidat.id);
      setState(() {}); // Refresh FutureBuilder
    }
  }

  void _openKandidatForm({Kandidat? kandidat}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => KandidatFormScreen(kandidat: kandidat),
      ),
    );
    if (result == true) {
      setState(() {});
    }
  }

  Widget _buildKandidatCard(Kandidat kandidat) {
    Widget avatar;
    if (kandidat.slika != null && kandidat.slika!.isNotEmpty) {
      try {
        final bytes = base64Decode(kandidat.slika!);
        avatar = ClipOval(
          child: Image.memory(
            bytes,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _defaultAvatar(),
          ),
        );
      } catch (e) {
        avatar = _defaultAvatar();
      }
    } else {
      avatar = _defaultAvatar();
    }

    final izbor = kandidat.izbor;
    final tipIzbora = izbor?.tipIzbora;
    final opstina = tipIzbora?.opstina;
    final grad = opstina?.grad;
    final drzava = grad?.drzava;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: const Color(0xFFF2F6FF),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            avatar,
            const SizedBox(width: 22),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${kandidat.ime ?? ''} ${kandidat.prezime ?? ''}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Stranka: ${kandidat.stranka?.naziv ?? ''}",
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Izbor: ${tipIzbora?.naziv ?? ''}",
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Dozvoljeno više glasova: ${tipIzbora?.dozvoljenoViseGlasova == true ? "Da" : "Ne"}",
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Opština: ${opstina?.naziv ?? ''}, Grad: ${grad?.naziv ?? ''}, Država: ${drzava?.naziv ?? ''}",
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  const SizedBox(height: 2),
                  if (izbor?.datumPocetka != null && izbor?.datumKraja != null)
                    Text(
                      "Trajanje: ${DateFormat('dd.MM.yyyy HH:mm').format(izbor!.datumPocetka!)} - ${DateFormat('dd.MM.yyyy HH:mm').format(izbor.datumKraja!)}",
                      style: const TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                  tooltip: "Uredi",
                  onPressed: () => _openKandidatForm(kandidat: kandidat),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  tooltip: "Obriši",
                  onPressed: () => _tryDeleteKandidat(kandidat),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultAvatar() {
    return const CircleAvatar(
      radius: 28,
      backgroundColor: Colors.blueAccent,
      child: Icon(Icons.person, color: Colors.white, size: 32),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Administracija kandidata",
      Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _imeController,
                    decoration: InputDecoration(
                      labelText: "Ime",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _prezimeController,
                    decoration: InputDecoration(
                      labelText: "Prezime",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _strankaNazivController,
                    decoration: InputDecoration(
                      labelText: "Stranka",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _izborNazivController,
                    decoration: InputDecoration(
                      labelText: "Izbor",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  label: const Text("Očisti filtere"),
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
                  label: const Text("Dodaj kandidata"),
                  onPressed: () => _openKandidatForm(),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Kandidat>>(
                future: _fetchKandidati(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Greška pri učitavanju kandidata.",
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                  final kandidati = snapshot.data ?? [];
                  if (kandidati.isEmpty) {
                    return const Center(
                      child: Text(
                        "Nema kandidata.",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: kandidati.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) => _buildKandidatCard(kandidati[index]),
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