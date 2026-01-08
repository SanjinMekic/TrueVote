import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:truevote_desktop/layouts/master_screen.dart';
import 'package:truevote_desktop/providers/korisnik_provider.dart';
import 'package:truevote_desktop/models/korisnik.dart';
import 'package:truevote_desktop/providers/auth_provider.dart';
import 'korisnik_form_screen.dart';

class UpravljanjeNalozimaScreen extends StatefulWidget {
  const UpravljanjeNalozimaScreen({super.key});

  @override
  State<UpravljanjeNalozimaScreen> createState() => _UpravljanjeNalozimaScreenState();
}

class _UpravljanjeNalozimaScreenState extends State<UpravljanjeNalozimaScreen> {
  final _imeController = TextEditingController();
  final _prezimeController = TextEditingController();
  final _emailController = TextEditingController();
  final _korisnickoImeController = TextEditingController();
  final _opstinaNazivController = TextEditingController();

  String? _imeFilter;
  String? _prezimeFilter;
  String? _emailFilter;
  String? _korisnickoImeFilter;
  String? _opstinaNazivFilter;

  Korisnik? _loggedInKorisnik;

  @override
  void initState() {
    super.initState();
    _loadLoggedInKorisnik();
  }

  Future<void> _loadLoggedInKorisnik() async {
    final korisnikId = AuthProvider.korisnikId;
    if (korisnikId != null) {
      final provider = Provider.of<KorisnikProvider>(context, listen: false);
      final korisnik = await provider.getById(korisnikId);
      setState(() {
        _loggedInKorisnik = korisnik;
      });
    }
  }

  @override
  void dispose() {
    _imeController.dispose();
    _prezimeController.dispose();
    _emailController.dispose();
    _korisnickoImeController.dispose();
    _opstinaNazivController.dispose();
    super.dispose();
  }

  Future<List<Korisnik>> _fetchKorisnici() async {
    final provider = Provider.of<KorisnikProvider>(context, listen: false);
    final filter = {
      if (_imeFilter != null && _imeFilter!.isNotEmpty) 'ime': _imeFilter,
      if (_prezimeFilter != null && _prezimeFilter!.isNotEmpty) 'prezime': _prezimeFilter,
      if (_emailFilter != null && _emailFilter!.isNotEmpty) 'email': _emailFilter,
      if (_korisnickoImeFilter != null && _korisnickoImeFilter!.isNotEmpty) 'korisnickoIme': _korisnickoImeFilter,
      if (_opstinaNazivFilter != null && _opstinaNazivFilter!.isNotEmpty) 'OpstinaNaziv': _opstinaNazivFilter,
    };
    final result = await provider.get(filter: filter);
    return result.result;
  }

  void _onSearch() {
    setState(() {
      _imeFilter = _imeController.text.isNotEmpty ? _imeController.text : null;
      _prezimeFilter = _prezimeController.text.isNotEmpty ? _prezimeController.text : null;
      _emailFilter = _emailController.text.isNotEmpty ? _emailController.text : null;
      _korisnickoImeFilter = _korisnickoImeController.text.isNotEmpty ? _korisnickoImeController.text : null;
      _opstinaNazivFilter = _opstinaNazivController.text.isNotEmpty ? _opstinaNazivController.text : null;
    });
  }

  void _onClear() {
    _imeController.clear();
    _prezimeController.clear();
    _emailController.clear();
    _korisnickoImeController.clear();
    _opstinaNazivController.clear();
    setState(() {
      _imeFilter = null;
      _prezimeFilter = null;
      _emailFilter = null;
      _korisnickoImeFilter = null;
      _opstinaNazivFilter = null;
    });
  }

  Future<void> _tryDeleteKorisnik(Korisnik korisnik) async {
    final provider = Provider.of<KorisnikProvider>(context, listen: false);
    bool canDelete = false;
    String? error;

    try {
      canDelete = await provider.canDelete(korisnik.id);
    } catch (e) {
      error = "Greška pri provjeri mogućnosti brisanja.";
    }

    if (!canDelete) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Brisanje nije dozvoljeno"),
          content: Text(
            "Korisnik '${korisnik.ime ?? ''} ${korisnik.prezime ?? ''}' je već glasao na izborima i ne može biti obrisan.",
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
          "Da li ste sigurni da želite obrisati '${korisnik.ime ?? ''} ${korisnik.prezime ?? ''}'?",
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
      await provider.delete(korisnik.id);
      setState(() {}); // Refresh FutureBuilder
    }
  }

  void _openKorisnikForm({Korisnik? korisnik}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => KorisnikFormScreen(korisnik: korisnik),
      ),
    );
    if (result == true) {
      setState(() {});
    }
  }

  Widget _buildKorisnikCard(Korisnik korisnik) {
    final loggedInId = _loggedInKorisnik?.id;
    final isSistemAdmin = _loggedInKorisnik?.sistemAdministrator == true;
    final isAdmin = korisnik.uloga?.naziv == "Admin";
    final isSelf = korisnik.id == loggedInId;

    Widget avatar;
    if (korisnik.slika != null && korisnik.slika!.isNotEmpty) {
      try {
        final bytes = base64Decode(korisnik.slika!);
        avatar = ClipOval(
          child: Image.memory(
            bytes,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _defaultAvatar(korisnik),
          ),
        );
      } catch (e) {
        if (korisnik.slika!.startsWith('http')) {
          avatar = ClipOval(
            child: Image.network(
              korisnik.slika!,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _defaultAvatar(korisnik),
            ),
          );
        } else {
          avatar = _defaultAvatar(korisnik);
        }
      }
    } else {
      avatar = _defaultAvatar(korisnik);
    }

    // Prava za edit/brisanje
    final canEditAdmin = isAdmin && isSistemAdmin && !isSelf;
    final canEditBirac = !isAdmin && !isSelf;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFF2F6FF),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.blueAccent.withOpacity(0.15),
              child: avatar,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${korisnik.ime ?? ''} ${korisnik.prezime ?? ''}",
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    korisnik.korisnickoIme ?? "",
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    korisnik.email ?? "",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Opština: ${korisnik.opstina?.naziv ?? ''}",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  if (korisnik.uloga != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Chip(
                        label: Text(
                          korisnik.uloga!.naziv ?? "",
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: korisnik.uloga!.naziv == "Admin"
                            ? Colors.blueAccent
                            : Colors.green,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              children: [
                if ((isAdmin && canEditAdmin) || (!isAdmin && canEditBirac))
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                    tooltip: "Uredi",
                    onPressed: () => _openKorisnikForm(korisnik: korisnik),
                  ),
                if ((isAdmin && canEditAdmin) || (!isAdmin && canEditBirac))
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    tooltip: "Obriši",
                    onPressed: () => _tryDeleteKorisnik(korisnik),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultAvatar(Korisnik korisnik) {
    return Icon(
      korisnik.uloga?.naziv == "Admin" ? Icons.admin_panel_settings : Icons.person,
      color: Colors.blueAccent,
      size: 32,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Upravljanje nalozima",
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
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _korisnickoImeController,
                    decoration: InputDecoration(
                      labelText: "Korisničko ime",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _opstinaNazivController,
                    decoration: InputDecoration(
                      labelText: "Opština",
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
                  label: const Text("Dodaj korisnika"),
                  onPressed: () => _openKorisnikForm(),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Korisnik>>(
                future: _fetchKorisnici(),
                builder: (context, snapshot) {
                  if (_loggedInKorisnik == null) {
                    return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Greška pri učitavanju korisnika.",
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                  final korisnici = snapshot.data ?? [];
                  final admini = korisnici.where((k) => k.uloga?.naziv == "Admin").toList();
                  final biraci = korisnici.where((k) => k.uloga?.naziv == "Birac").toList();

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (admini.isNotEmpty) ...[
                          const Text(
                            "Administratori",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: admini.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) => _buildKorisnikCard(admini[index]),
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (biraci.isNotEmpty) ...[
                          const Text(
                            "Birači",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: biraci.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) => _buildKorisnikCard(biraci[index]),
                          ),
                        ],
                        if (admini.isEmpty && biraci.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 32),
                              child: Text(
                                "Nema korisnika.",
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ),
                          ),
                      ],
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
}