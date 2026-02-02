import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:truevote_desktop/layouts/master_screen.dart';
import 'package:truevote_desktop/providers/stranka_provider.dart';
import 'package:truevote_desktop/models/stranka.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';

class StrankaFormScreen extends StatefulWidget {
  final Stranka? stranka;
  const StrankaFormScreen({super.key, this.stranka});

  @override
  State<StrankaFormScreen> createState() => _StrankaFormScreenState();
}

class _StrankaFormScreenState extends State<StrankaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nazivController = TextEditingController();
  final _opisController = TextEditingController();
  final _datumController = TextEditingController();
  final _brojClanovaController = TextEditingController();
  final _sjedisteController = TextEditingController();
  final _webUrlController = TextEditingController();

  String? _logoPath;

  @override
  void initState() {
    super.initState();
    if (widget.stranka != null) {
      _nazivController.text = widget.stranka!.naziv ?? '';
      _opisController.text = widget.stranka!.opis ?? '';
      _datumController.text = widget.stranka!.datumOsnivanja != null
          ? DateFormat('dd.MM.yyyy').format(widget.stranka!.datumOsnivanja!)
          : '';
      _brojClanovaController.text = widget.stranka!.brojClanova?.toString() ?? '';
      _sjedisteController.text = widget.stranka!.sjediste ?? '';
      _webUrlController.text = widget.stranka!.webUrl ?? '';
      _logoPath = widget.stranka!.logo;
    }
  }

  @override
  void dispose() {
    _nazivController.dispose();
    _opisController.dispose();
    _datumController.dispose();
    _brojClanovaController.dispose();
    _sjedisteController.dispose();
    _webUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _logoPath = result.files.single.path;
      });
    }
  }

  Future<String?> _getLogoBase64() async {
    if (_logoPath == null || _logoPath!.isEmpty) return null;
    if (_logoPath!.startsWith('http')) return null;
    try {
      base64Decode(_logoPath!);
      return _logoPath;
    } catch (_) {}
    final file = File(_logoPath!);
    if (!await file.exists()) return null;
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  Widget _logoPreview() {
    if (_logoPath == null || _logoPath!.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.how_to_vote, color: Colors.blueAccent, size: 40),
      );
    }
    try {
      final bytes = base64Decode(_logoPath!);
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(bytes, width: 80, height: 80, fit: BoxFit.cover),
      );
    } catch (e) {
      if (_logoPath!.startsWith('http')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(_logoPath!, width: 80, height: 80, fit: BoxFit.cover),
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(File(_logoPath!), width: 80, height: 80, fit: BoxFit.cover),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<StrankaProvider>(context, listen: false);

    final logoBase64 = await _getLogoBase64();

    DateTime? parsedDate;
    if (_datumController.text.isNotEmpty) {
      try {
        parsedDate = DateFormat('dd.MM.yyyy').parse(_datumController.text);
      } catch (_) {
        parsedDate = null;
      }
    }

    final Map<String, dynamic> request = {
      "naziv": _nazivController.text,
      "opis": _opisController.text,
      "datumOsnivanja": parsedDate?.toIso8601String(),
      "brojClanova": _brojClanovaController.text.isNotEmpty ? int.parse(_brojClanovaController.text) : null,
      "sjediste": _sjedisteController.text,
      "webUrl": _webUrlController.text.isNotEmpty ? _webUrlController.text : null,
      "logoBase64": logoBase64,
    };

    if (widget.stranka == null) {
      await provider.insert(request);
    } else {
      await provider.update(widget.stranka!.id, request);
    }

    Navigator.of(context).pop(true);
  }

  Future<void> _pickDate() async {
    DateTime? initialDate = DateTime.now();
    if (_datumController.text.isNotEmpty) {
      initialDate = DateTime.tryParse(_datumController.text) ?? DateTime.now();
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _datumController.text = DateFormat('dd.MM.yyyy').format(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      widget.stranka == null ? "Dodavanje stranke" : "Uređivanje stranke",
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
                        controller: _nazivController,
                        decoration: const InputDecoration(
                          labelText: "Naziv *",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? "Naziv je obavezan." : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _opisController,
                        decoration: const InputDecoration(
                          labelText: "Opis *",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                        validator: (value) =>
                            value == null || value.isEmpty ? "Opis je obavezan." : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _datumController,
                        decoration: InputDecoration(
                          labelText: "Datum osnivanja",
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: _pickDate,
                          ),
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _brojClanovaController,
                        decoration: const InputDecoration(
                          labelText: "Broj članova",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (int.tryParse(value) == null) {
                              return "Broj članova mora biti valjan broj.";
                            }
                            if (int.parse(value) <= 0) {
                              return "Broj članova mora biti veći od 0.";
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _sjedisteController,
                        decoration: const InputDecoration(
                          labelText: "Sjedište *",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? "Sjedište je obavezno." : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _webUrlController,
                        decoration: const InputDecoration(
                          labelText: "Web URL",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final uri = Uri.tryParse(value);
                            if (uri == null || !uri.hasScheme || (!uri.hasAbsolutePath && uri.host.isEmpty)) {
                              return "Unesite valjan URL.";
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _logoPreview(),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.upload_file),
                                  label: const Text("Odaberi logo"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white
                                  ),
                                  onPressed: _pickLogo,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Logo je opcionalan",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
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
                            label: Text(widget.stranka == null ? "Sačuvaj" : "Izmijeni"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white
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