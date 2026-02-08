import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:truevote_mobile/screens/uredi_profil_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/korisnik_provider.dart';
import '../models/korisnik.dart';
import 'login_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  Future<Korisnik?>? _korisnikFuture;
  String? _profilnaSlikaBase64;
  bool _isUploading = false;
  String? _slikaError;

  @override
  void initState() {
    super.initState();
    final korisnikId = AuthProvider.korisnikId;
    if (korisnikId != null) {
      _korisnikFuture = Provider.of<KorisnikProvider>(
        context,
        listen: false,
      ).getById(korisnikId);
    }
  }

  void _logout() {
    AuthProvider.username = null;
    AuthProvider.password = null;
    AuthProvider.korisnikId = null;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showFullImage(String base64Image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: InteractiveViewer(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black,
              ),
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  base64Decode(base64Image),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageAndUpload(int korisnikId) async {
    setState(() {
      _slikaError = null;
    });
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      final ext = result.files.single.extension?.toLowerCase();
      if (ext == 'heic') {
        setState(() {
          _slikaError =
              "HEIC format nije dozvoljen. Dozvoljeni su samo PNG, JPG i JPEG.";
        });
        return;
      }
      setState(() {
        _isUploading = true;
      });
      try {
        final base64 = base64Encode(result.files.single.bytes!);
        final korisnikProvider = Provider.of<KorisnikProvider>(context, listen: false);
        await korisnikProvider.update(korisnikId, {"slikaBase64": base64});
        setState(() {
          _profilnaSlikaBase64 = base64;
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profilna slika je uspješno ažurirana.")),
        );
      } catch (e) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška pri ažuriranju slike: $e")),
        );
      }
    }
  }

  Future<void> _showEditEmailDialog(Korisnik korisnik) async {
  final TextEditingController emailController =
      TextEditingController(text: korisnik.email ?? "");
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? error;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Izmijeni email"),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return "Email je obavezan";
  }
  if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(value.trim())) {
    return "Unesite validan email!";
  }
  return null;
},
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text("Otkaži"),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      setState(() {
                        isLoading = true;
                        error = null;
                      });
                      try {
                        final korisnikProvider = Provider.of<KorisnikProvider>(context, listen: false);
                        await korisnikProvider.update(korisnik.id!, {
                          "email": emailController.text.trim(),
                        });
                        setState(() {
                          isLoading = false;
                        });
                        if (mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Email je uspješno ažuriran.")),
                          );
                          setState(() {});
                        }
                        if (this.mounted) {
                          this.setState(() {
                            final korisnikId = AuthProvider.korisnikId;
                            if (korisnikId != null) {
                              _korisnikFuture = Provider.of<KorisnikProvider>(
                                context,
                                listen: false,
                              ).getById(korisnikId);
                            }
                          });
                        }
                      } catch (e) {
                        setState(() {
                          isLoading = false;
                          error = "Greška: $e";
                        });
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Sačuvaj"),
            ),
          ],
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
          contentTextStyle: const TextStyle(color: Colors.black87),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF2F6FF),
      body: FutureBuilder<Korisnik?>(
        future: _korisnikFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            );
          }
          final korisnik = snapshot.data;
          if (korisnik == null) {
            return const Center(
              child: Text(
                "Nema podataka o korisniku.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          final korisnikId = korisnik.id!;
          final slikaZaPrikaz = _profilnaSlikaBase64 ?? korisnik.slika;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        onTap: (slikaZaPrikaz != null && slikaZaPrikaz.isNotEmpty)
                            ? () => _showFullImage(slikaZaPrikaz)
                            : null,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.blueAccent,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: (slikaZaPrikaz != null && slikaZaPrikaz.isNotEmpty)
                                ? Image.memory(
                                    base64Decode(slikaZaPrikaz),
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                  )
                                : Container(
                                    color: Colors.blueAccent,
                                    child: const Icon(
                                      Icons.person,
                                      size: 64,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 8,
                        child: Material(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          elevation: 3,
                          child: IconButton(
                            icon: _isUploading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.edit, color: Colors.blueAccent),
                            tooltip: "Uredi profilnu sliku",
                            onPressed: _isUploading
                                ? null
                                : () => _pickImageAndUpload(korisnikId),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_slikaError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _slikaError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 18,
                      ),
                      child: Column(
                        children: [
                          _buildDisabledInput(
                            label: "Ime",
                            value: korisnik.ime ?? "",
                            icon: Icons.badge_outlined,
                          ),
                          const SizedBox(height: 16),
                          _buildDisabledInput(
                            label: "Prezime",
                            value: korisnik.prezime ?? "",
                            icon: Icons.badge,
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => _showEditEmailDialog(korisnik),
                            child: AbsorbPointer(
                              child: TextFormField(
                                initialValue: korisnik.email ?? "",
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.blueAccent),
                                  suffixIcon: const Icon(Icons.edit, color: Colors.blueAccent),
                                  filled: true,
                                  fillColor: const Color(0xFFF2F6FF),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
                                  ),
                                  labelStyle: const TextStyle(color: Colors.blueAccent),
                                ),
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDisabledInput(
                            label: "Korisničko ime",
                            value: korisnik.korisnickoIme ?? "",
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 16),
                          _buildDisabledInput(
                            label: "Opština",
                            value: korisnik.opstina?.naziv ?? "",
                            icon: Icons.location_city,
                          ),
                          const SizedBox(height: 16),
                          _buildDisabledInput(
                            label: "Grad",
                            value: korisnik.opstina?.grad?.naziv ?? "",
                            icon: Icons.location_on,
                          ),
                          const SizedBox(height: 16),
                          _buildDisabledInput(
                            label: "Država",
                            value: korisnik.opstina?.grad?.drzava?.naziv ?? "",
                            icon: Icons.public,
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const UrediProfilScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Uredi",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _logout,
                                  icon: const Icon(
                                    Icons.logout,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Odjavi se",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildDisabledInput({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: const Color(0xFFF2F6FF),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
        ),
        labelStyle: const TextStyle(color: Colors.blueAccent),
      ),
      style: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}