import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/korisnik_provider.dart';
import '../providers/glas_provider.dart';
import '../layouts/master_screen.dart';
import 'pocetna_screen.dart';

class GlasanjeScreen extends StatefulWidget {
  final List<dynamic> kandidati;
  final int maxBrojGlasova;

  const GlasanjeScreen({
    super.key,
    required this.kandidati,
    required this.maxBrojGlasova,
  });

  @override
  State<GlasanjeScreen> createState() => _GlasanjeScreenState();
}

class _GlasanjeScreenState extends State<GlasanjeScreen> {
  late List<bool> _checked;
  int _brojOdabranih = 0;
  bool _isLoading = false;
  bool _pinValidan = false;

  @override
  void initState() {
    super.initState();
    _checked = List<bool>.filled(widget.kandidati.length, false);
  }

  void _onChanged(bool? value, int index) {
    if (value == null) return;

    setState(() {
      if (value) {
        if (_brojOdabranih < widget.maxBrojGlasova) {
          _checked[index] = true;
          _brojOdabranih++;
        }
      } else {
        _checked[index] = false;
        _brojOdabranih--;
      }
    });
  }

  Future<void> _provjeriPinIPotvrdiGlasanje() async {
    final korisnikId = AuthProvider.korisnikId;
    if (korisnikId == null) return;

    final pinValidan = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _PinCheckDialog(korisnikId: korisnikId),
    );

    if (pinValidan == true) {
      setState(() {
        _pinValidan = true;
      });
      await _posaljiGlasove(korisnikId);
    }
  }

  Future<void> _posaljiGlasove(int korisnikId) async {
    setState(() {
      _isLoading = true;
    });

    final glasProvider = Provider.of<GlasProvider>(context, listen: false);
    final odabraniKandidati = <dynamic>[];
    for (int i = 0; i < _checked.length; i++) {
      if (_checked[i]) {
        odabraniKandidati.add(widget.kandidati[i]);
      }
    }

    int uspjesno = 0;
    String? errorMsg;

    for (var kandidat in odabraniKandidati) {
      try {
        await glasProvider.insert({
          "korisnikId": korisnikId,
          "kandidatId": kandidat['id'],
        });
        uspjesno++;
      } catch (e) {
        errorMsg = e.toString();
        break;
      }
    }

    setState(() {
      _isLoading = false;
    });

    if (uspjesno == odabraniKandidati.length) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vaš glas je zabilježen. Hvala Vam na učešću!"),
          backgroundColor: Colors.green,
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => MasterScreen(
              child: const PocetnaScreen(),
              initialIndex: 0,
            ),
          ),
          (route) => false,
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Greška pri glasanju: ${errorMsg ?? "Nepoznata greška"}",
          ),
        ),
      );
    }
  }

  Widget _buildKandidatSlika(String? slika) {
    if (slika == null || slika.isEmpty) {
      return const CircleAvatar(
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.person, color: Colors.white),
      );
    }
    try {
      return CircleAvatar(
        backgroundImage: MemoryImage(
          Uri.parse(slika).data != null
              ? Uri.parse(slika).data!.contentAsBytes()
              : base64Decode(slika),
        ),
        backgroundColor: Colors.grey[200],
      );
    } catch (_) {
      return const CircleAvatar(
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.person, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final kandidati = widget.kandidati;
    final maxGlasova = widget.maxBrojGlasova;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Glasanje", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF2F6FF),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Možete odabrati maksimalno $maxGlasova kandidata.",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.separated(
                itemCount: kandidati.length,
                separatorBuilder: (_, __) => const Divider(height: 12),
                itemBuilder: (context, index) {
                  final kandidat = kandidati[index];
                  final disableOthers = _brojOdabranih >= maxGlasova && !_checked[index];
                  return CheckboxListTile(
                    value: _checked[index],
                    onChanged: disableOthers ? null : (v) => _onChanged(v, index),
                    title: Text(
                      "${kandidat['ime'] ?? ''} ${kandidat['prezime'] ?? ''}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    subtitle: Text(
                      "Stranka: ${kandidat['stranka']?['naziv'] ?? '-'}",
                      style: const TextStyle(fontSize: 15),
                    ),
                    secondary: _buildKandidatSlika(kandidat['slika']),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      onPressed: (_brojOdabranih > 0 && !_pinValidan)
                          ? _provjeriPinIPotvrdiGlasanje
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.check),
                          SizedBox(width: 10),
                          Text(
                            "Potvrdi glasanje",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _PinCheckDialog extends StatefulWidget {
  final int korisnikId;
  const _PinCheckDialog({required this.korisnikId});

  @override
  State<_PinCheckDialog> createState() => _PinCheckDialogState();
}

class _PinCheckDialogState extends State<_PinCheckDialog> {
  final List<TextEditingController> _pinControllers =
      List.generate(4, (_) => TextEditingController());
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  String get _pin => _pinControllers.map((c) => c.text).join();

  @override
  void dispose() {
    for (var c in _pinControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submitPin() async {
    setState(() {
      _error = null;
      _isLoading = true;
    });

    if (_pin.length != 4 || !_pin.contains(RegExp(r'^\d{4}$'))) {
      setState(() {
        _error = "PIN mora sadržavati tačno 4 cifre.";
        _isLoading = false;
      });
      return;
    }

    final korisnikProvider = Provider.of<KorisnikProvider>(context, listen: false);
    final isValid = await korisnikProvider.provjeriPin(widget.korisnikId, _pin);

    if (isValid) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _error = "Pogrešan PIN.";
        _isLoading = false;
      });
    }
  }

  void _focusNext(int index) {
    if (_pinControllers[index].text.length == 1 && index < 3) {
      FocusScope.of(context).nextFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      title: Column(
        children: [
          const Icon(Icons.lock, color: Colors.blueAccent, size: 40),
          const SizedBox(height: 8),
          Text(
            "Unesite PIN",
            style: TextStyle(
              color: Colors.blueAccent.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 120),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Text(
                  "Radi sigurnosti, unesite svoj četveroznamenkasti PIN.\n\nNakon uspješnog unosa PIN-a, Vaš glas će biti evidentiran i ova akcija je nepovratna.",
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    return Container(
                      width: 44,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      child: TextFormField(
                        controller: _pinControllers[i],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        obscureText: false,
                        style: const TextStyle(
                          fontSize: 28,
                          letterSpacing: 8,
                          color: Colors.blueAccent,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          counterText: "",
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.blueAccent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.length == 1) _focusNext(i);
                          setState(() {});
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "";
                          }
                          if (!RegExp(r'^\d$').hasMatch(value)) {
                            return "";
                          }
                          return null;
                        },
                      ),
                    );
                  }),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text(
            "Otkaži",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : _submitPin,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  "Potvrdi PIN",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
        ),
      ],
    );
  }
}