import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:truevote_desktop/layouts/master_screen.dart';
import 'package:truevote_desktop/providers/kandidat_provider.dart';
import 'package:truevote_desktop/providers/izbor_provider.dart';
import 'package:truevote_desktop/providers/stranka_provider.dart';
import 'package:truevote_desktop/models/kandidat.dart';
import 'package:truevote_desktop/models/izbor.dart';
import 'package:truevote_desktop/models/stranka.dart';
import 'package:file_picker/file_picker.dart';

class KandidatFormScreen extends StatefulWidget {
  final Kandidat? kandidat;
  const KandidatFormScreen({super.key, this.kandidat});

  @override
  State<KandidatFormScreen> createState() => _KandidatFormScreenState();
}

class _KandidatFormScreenState extends State<KandidatFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imeController = TextEditingController();
  final _prezimeController = TextEditingController();
  int? _strankaId;
  int? _izborId;
  String? _slikaPath;

  List<Stranka> _stranke = [];
  List<Izbor> _izbori = [];

  @override
  void initState() {
    super.initState();
    if (widget.kandidat != null) {
      _imeController.text = widget.kandidat!.ime ?? '';
      _prezimeController.text = widget.kandidat!.prezime ?? '';
      _strankaId = widget.kandidat!.strankaId;
      _izborId = widget.kandidat!.izborId;
      _slikaPath = widget.kandidat!.slika;
    }
    _loadDropdowns();
  }

  Future<void> _loadDropdowns() async {
    final izborProvider = Provider.of<IzborProvider>(context, listen: false);
    final izborResult = await izborProvider.get();
    setState(() {
      _izbori = izborResult.result.where((i) => i.status == "Planiran" || i.status == "U toku").toList();
    });

    final strankaProvider = Provider.of<StrankaProvider>(context, listen: false);
    final strankaResult = await strankaProvider.get();
    setState(() {
      _stranke = strankaResult.result;
    });
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

    final provider = Provider.of<KandidatProvider>(context, listen: false);
    final slikaBase64 = await _getSlikaBase64();

    final Map<String, dynamic> request = {
      "ime": _imeController.text,
      "prezime": _prezimeController.text,
      "strankaId": _strankaId,
      "izborId": _izborId,
      "slikaBase64": slikaBase64,
    };

    final isEdit = widget.kandidat != null;

    if (!isEdit) {
      await provider.insert(request);
    } else {
      await provider.update(widget.kandidat!.id, request);
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.kandidat != null;

    return MasterScreen(
      isEdit ? "Uređivanje kandidata" : "Dodavanje kandidata",
      Center(
        child: SizedBox(
          width: 680,
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
                      DropdownButtonFormField<int>(
                        value: _strankaId,
                        decoration: const InputDecoration(
                          labelText: "Stranka *",
                          border: OutlineInputBorder(),
                        ),
                        items: _stranke
                            .map((s) => DropdownMenuItem<int>(
                                  value: s.id,
                                  child: Text(s.naziv ?? ""),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => _strankaId = value),
                        validator: (value) =>
                            value == null ? "Stranka je obavezna." : null,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<int>(
                        value: _izborId,
                        decoration: const InputDecoration(
                          labelText: "Izbor *",
                          border: OutlineInputBorder(),
                        ),
                        items: _izbori
                            .map((i) => DropdownMenuItem<int>(
                                  value: i.id,
                                  child: Text(i.tipIzbora?.naziv ?? ""),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => _izborId = value),
                        validator: (value) =>
                            value == null ? "Izbor je obavezan." : null,
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