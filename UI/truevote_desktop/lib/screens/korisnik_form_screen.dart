import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:truevote_desktop/layouts/master_screen.dart';
import 'package:truevote_desktop/providers/korisnik_provider.dart';
import 'package:truevote_desktop/providers/uloga_provider.dart';
import 'package:truevote_desktop/providers/opstina_provider.dart';
import 'package:truevote_desktop/models/korisnik.dart';
import 'package:truevote_desktop/models/uloga.dart';
import 'package:truevote_desktop/models/opstina.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'dart:io';
import 'dart:convert';

class KorisnikFormScreen extends StatefulWidget {
  final Korisnik? korisnik;
  const KorisnikFormScreen({super.key, this.korisnik});

  @override
  State<KorisnikFormScreen> createState() => _KorisnikFormScreenState();
}

class _KorisnikFormScreenState extends State<KorisnikFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imeController = TextEditingController();
  final _prezimeController = TextEditingController();
  final _emailController = TextEditingController();
  final _korisnickoImeController = TextEditingController();
  final _lozinkaController = TextEditingController();
  final _lozinkaPotvrdaController = TextEditingController();
  int? _ulogaId;
  Opstina? _selectedOpstina;
  String? _slikaPath;

  @override
  void initState() {
    super.initState();
    if (widget.korisnik != null) {
      _imeController.text = widget.korisnik!.ime ?? '';
      _prezimeController.text = widget.korisnik!.prezime ?? '';
      _emailController.text = widget.korisnik!.email ?? '';
      _korisnickoImeController.text = widget.korisnik!.korisnickoIme ?? '';
      _ulogaId = widget.korisnik!.ulogaId;
      if (widget.korisnik!.opstinaId != null) {
        _selectedOpstina = Opstina(id: widget.korisnik!.opstinaId!, naziv: widget.korisnik!.opstina?.naziv);
      }
      _slikaPath = widget.korisnik!.slika;
    }
  }

  @override
  void dispose() {
    _imeController.dispose();
    _prezimeController.dispose();
    _emailController.dispose();
    _korisnickoImeController.dispose();
    _lozinkaController.dispose();
    _lozinkaPotvrdaController.dispose();
    super.dispose();
  }

  Future<void> _pickSlika() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _slikaPath = result.files.single.path;
      });
    }
  }

  Future<String?> _getSlikaBase64() async {
    if (_slikaPath == null || _slikaPath!.isEmpty) return null;
    try {
      base64Decode(_slikaPath!);
      return _slikaPath;
    } catch (_) {}
    final file = File(_slikaPath!);
    if (!await file.exists()) return null;
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  Widget _slikaPreview() {
    if (_slikaPath == null || _slikaPath!.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.person, color: Colors.blueAccent, size: 40),
      );
    }
    try {
      final bytes = base64Decode(_slikaPath!);
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(bytes, width: 80, height: 80, fit: BoxFit.cover),
      );
    } catch (e) {
      if (_slikaPath!.startsWith('http')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(_slikaPath!, width: 80, height: 80, fit: BoxFit.cover),
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(File(_slikaPath!), width: 80, height: 80, fit: BoxFit.cover),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<KorisnikProvider>(context, listen: false);
    final slikaBase64 = await _getSlikaBase64();

    final Map<String, dynamic> request = {
      "ime": _imeController.text,
      "prezime": _prezimeController.text,
      "email": _emailController.text,
      "korisnickoIme": _korisnickoImeController.text,
      "ulogaId": _ulogaId,
      "opstinaId": _selectedOpstina?.id,
      "slikaBase64": slikaBase64,
    };

    final isEdit = widget.korisnik != null;

    if (!isEdit) {
      request["lozinka"] = _lozinkaController.text;
      request["lozinkaPotvrda"] = _lozinkaPotvrdaController.text;
      await provider.insert(request);
    } else {
      request["lozinka"] = null;
      request["lozinkaPotvrda"] = null;
      await provider.update(widget.korisnik!.id, request);
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.korisnik != null;

    return MasterScreen(
      isEdit ? "Uređivanje korisnika" : "Dodavanje korisnika",
      Center(
        child: SizedBox(
          width: 480,
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _imeController,
                        decoration: const InputDecoration(
                          labelText: "Ime *",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? "Ime je obavezno." : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _prezimeController,
                        decoration: const InputDecoration(
                          labelText: "Prezime *",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? "Prezime je obavezno." : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: "Email *",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? "Email je obavezan." : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _korisnickoImeController,
                        decoration: const InputDecoration(
                          labelText: "Korisničko ime *",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? "Korisničko ime je obavezno." : null,
                      ),
                      if (!isEdit) ...[
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _lozinkaController,
                          decoration: const InputDecoration(
                            labelText: "Lozinka *",
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) =>
                              value == null || value.isEmpty ? "Lozinka je obavezna." : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _lozinkaPotvrdaController,
                          decoration: const InputDecoration(
                            labelText: "Potvrda lozinke *",
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) =>
                              value != _lozinkaController.text ? "Lozinke se ne podudaraju." : null,
                        ),
                      ],
                      const SizedBox(height: 14),
                      FutureBuilder<List<Uloga>>(
                        future: Provider.of<UlogaProvider>(context, listen: false).get().then((value) => value.result),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          final uloge = snapshot.data!;
                          return DropdownButtonFormField<int>(
                            value: _ulogaId,
                            decoration: const InputDecoration(
                              labelText: "Uloga *",
                              border: OutlineInputBorder(),
                            ),
                            items: uloge
                                .map((u) => DropdownMenuItem<int>(
                                      value: u.id,
                                      child: Text(u.naziv ?? ""),
                                    ))
                                .toList(),
                            onChanged: (value) => setState(() => _ulogaId = value),
                            validator: (value) =>
                                value == null ? "Uloga je obavezna." : null,
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      FutureBuilder<List<Opstina>>(
  future: Provider.of<OpstinaProvider>(context, listen: false).get().then((value) => value.result),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const CircularProgressIndicator();
    }
    final opstine = snapshot.data!;
    return DropdownSearch<Opstina>(
      items: opstine,
      itemAsString: (o) => o.naziv ?? "",
      selectedItem: _selectedOpstina,
      dropdownDecoratorProps: const DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: "Opština *",
          border: OutlineInputBorder(),
        ),
      ),
      onChanged: (opstina) => setState(() => _selectedOpstina = opstina),
      validator: (opstina) => opstina == null ? "Opština je obavezna." : null,
      popupProps: const PopupProps.menu(
        showSearchBox: true,
      ),
    );
  },
),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _slikaPreview(),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.upload_file),
                              label: const Text("Odaberi sliku"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _pickSlika,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Otkaži"),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.save),
                            label: Text(isEdit ? "Izmijeni" : "Sačuvaj"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _save,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}