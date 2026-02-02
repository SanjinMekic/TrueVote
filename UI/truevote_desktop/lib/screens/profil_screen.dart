import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:truevote_desktop/layouts/master_screen.dart';
import 'package:truevote_desktop/models/korisnik.dart';
import 'package:truevote_desktop/providers/korisnik_provider.dart';
import 'package:truevote_desktop/providers/auth_provider.dart';
import 'package:truevote_desktop/screens/login_screen.dart';
import 'package:file_picker/file_picker.dart';

class ProfilScreen extends StatefulWidget {
  final Korisnik korisnik;
  const ProfilScreen({super.key, required this.korisnik});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imeController = TextEditingController();
  final _prezimeController = TextEditingController();
  final _emailController = TextEditingController();
  String? _slikaPath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _imeController.text = widget.korisnik.ime ?? '';
    _prezimeController.text = widget.korisnik.prezime ?? '';
    _emailController.text = widget.korisnik.email ?? '';
    _slikaPath = widget.korisnik.slika;
  }

  @override
  void dispose() {
    _imeController.dispose();
    _prezimeController.dispose();
    _emailController.dispose();
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
    setState(() => _isSaving = true);

    final provider = Provider.of<KorisnikProvider>(context, listen: false);
    final slikaBase64 = await _getSlikaBase64();

    final Map<String, dynamic> request = {
      "ime": _imeController.text,
      "prezime": _prezimeController.text,
      "email": _emailController.text,
      "slikaBase64": slikaBase64,
      "lozinka": null,
      "lozinkaPotvrda": null,
    };

    try {
      await provider.update(widget.korisnik.id, request);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil uspješno ažuriran.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška pri ažuriranju profila: $e")),
        );
      }
    }
    setState(() => _isSaving = false);
  }

  Future<void> _showChangePasswordDialog() async {
    final _formKey = GlobalKey<FormState>();
    final _staraController = TextEditingController();
    final _novaController = TextEditingController();
    final _potvrdaController = TextEditingController();
    bool _isLoading = false;
    String? _error;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Row(
              children: [
                const Icon(Icons.lock, color: Colors.blueAccent, size: 28),
                const SizedBox(width: 12),
                const Text("Promjena lozinke", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: SizedBox(
              width: 350,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _staraController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Stara lozinka",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.isEmpty ? "Unesite staru lozinku" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _novaController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Nova lozinka",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Unesite novu lozinku";
                        if (v.length < 6) return "Nova lozinka mora imati najmanje 6 karaktera";
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _potvrdaController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Potvrda lozinke",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Unesite potvrdu lozinke";
                        if (v != _novaController.text) return "Lozinke se ne podudaraju";
                        return null;
                      },
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.of(context).pop();
                      },
                child: const Text("Otkaži"),
              ),
              ElevatedButton.icon(
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: const Text("Spremi"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          setState(() {
                            _isLoading = true;
                            _error = null;
                          });
                          final provider = Provider.of<KorisnikProvider>(context, listen: false);
                          bool ispravnaStara = false;
                          try {
                            ispravnaStara = await provider.provjeriStaruLozinku(
                              widget.korisnik.id,
                              _staraController.text,
                            );
                          } catch (e) {
                            setState(() {
                              _error = "Greška pri provjeri stare lozinke.";
                              _isLoading = false;
                            });
                            return;
                          }
                          if (!ispravnaStara) {
                            setState(() {
                              _error = "Stara lozinka nije ispravna.";
                              _isLoading = false;
                            });
                            return;
                          }
                          try {
                            await provider.update(widget.korisnik.id, {
                              "lozinka": _novaController.text,
                              "lozinkaPotvrda": _potvrdaController.text,
                              "staraLozinka": _staraController.text,
                            });
                            if (mounted) {
                              Navigator.of(context).pop();
                              AuthProvider.username = null;
                              AuthProvider.password = null;
                              AuthProvider.korisnikId = null;
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => const LoginPage()),
                                (route) => false,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Lozinka uspješno promijenjena. Prijavite se ponovo.")),
                              );
                            }
                          } catch (e) {
                            setState(() {
                              _error = "Greška pri promjeni lozinke.";
                              _isLoading = false;
                            });
                          }
                        }
                      },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Moj profil",
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
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          _slikaPreview(),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                              tooltip: "Promijeni sliku",
                              onPressed: _pickSlika,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
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
                        enabled: false,
                        initialValue: widget.korisnik.korisnickoIme ?? "",
                        decoration: const InputDecoration(
                          labelText: "Korisničko ime",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        enabled: false,
                        initialValue: widget.korisnik.uloga?.naziv ?? "",
                        decoration: const InputDecoration(
                          labelText: "Uloga",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        enabled: false,
                        initialValue: widget.korisnik.opstina?.naziv ?? "",
                        decoration: const InputDecoration(
                          labelText: "Opština",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.lock),
                            label: const Text("Promijeni lozinku"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _showChangePasswordDialog,
                          ),
                          ElevatedButton.icon(
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: const Text("Sačuvaj"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _isSaving ? null : _save,
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