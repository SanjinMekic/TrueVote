import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/korisnik_provider.dart';
import 'login_screen.dart';

class UrediProfilScreen extends StatelessWidget {
  const UrediProfilScreen({super.key});

  void _onPromijeniPin(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PromjenaPinDialog(),
    );
  }

  void _onPromijeniSifru(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PromjenaSifreDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Uredi profil",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF2F6FF),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.settings, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "Uredi svoj profil",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Odaberite opciju koju želite promijeniti.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _onPromijeniSifru(context),
                      icon: const Icon(Icons.lock_reset, color: Colors.white),
                      label: const Text(
                        "Promijeni šifru",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _onPromijeniPin(context),
                      icon: const Icon(Icons.pin, color: Colors.white),
                      label: const Text(
                        "Promijeni PIN",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PromjenaPinDialog extends StatefulWidget {
  const PromjenaPinDialog({super.key});

  @override
  State<PromjenaPinDialog> createState() => _PromjenaPinDialogState();
}

class _PromjenaPinDialogState extends State<PromjenaPinDialog> {
  final List<TextEditingController> _stariPinControllers =
      List.generate(4, (_) => TextEditingController());
  final List<TextEditingController> _noviPinControllers =
      List.generate(4, (_) => TextEditingController());
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    for (var c in _stariPinControllers) {
      c.dispose();
    }
    for (var c in _noviPinControllers) {
      c.dispose();
    }
    super.dispose();
  }

  String get _stariPin => _stariPinControllers.map((c) => c.text).join();
  String get _noviPin => _noviPinControllers.map((c) => c.text).join();

  Future<void> _promijeniPin() async {
    setState(() {
      _error = null;
      _isLoading = true;
    });

    final korisnikProvider = Provider.of<KorisnikProvider>(context, listen: false);
    final korisnikId = AuthProvider.korisnikId;

    if (korisnikId == null) {
      setState(() {
        _error = "Korisnik nije pronađen.";
        _isLoading = false;
      });
      return;
    }

    try {
      final result = await korisnikProvider.promijeniPinSaPorukom(
        korisnikId,
        _stariPin,
        _noviPin,
      );

      if (result['success'] == true) {
        AuthProvider.username = null;
        AuthProvider.password = null;
        AuthProvider.korisnikId = null;
        Navigator.of(context).pop();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "PIN je uspješno promijenjen. Prijavite se ponovo."),
            backgroundColor: Colors.blueAccent,
          ),
        );
      } else {
        setState(() {
          _error = result['message'] ?? "Greška pri promjeni PIN-a!";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _focusNext(List<TextEditingController> controllers, int index) {
    if (controllers[index].text.length == 1 && index < 3) {
      FocusScope.of(context).nextFocus();
    }
  }

  Widget _buildPinRow(List<TextEditingController> controllers, String label) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (i) {
            return Container(
              width: 44,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: TextFormField(
                controller: controllers[i],
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
                  LengthLimitingTextInputFormatter(1),
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
                  if (value.length == 1) _focusNext(controllers, i);
                  setState(() {});
                },
                validator: (value) {
                  return null;
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        "Promjena PIN-a",
        style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 220),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPinRow(_stariPinControllers, "Unesite stari PIN"),
                const SizedBox(height: 18),
                _buildPinRow(_noviPinControllers, "Unesite novi PIN"),
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
          onPressed: _isLoading
              ? null
              : () {
                  _promijeniPin();
                },
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  "Promijeni PIN",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
        ),
      ],
    );
  }
}

class PromjenaSifreDialog extends StatefulWidget {
  const PromjenaSifreDialog({super.key});

  @override
  State<PromjenaSifreDialog> createState() => _PromjenaSifreDialogState();
}

class _PromjenaSifreDialogState extends State<PromjenaSifreDialog> {
  final _formKey = GlobalKey<FormState>();
  final _staraSifraController = TextEditingController();
  final _novaSifraController = TextEditingController();
  final _potvrdaSifreController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _staraSifraController.dispose();
    _novaSifraController.dispose();
    _potvrdaSifreController.dispose();
    super.dispose();
  }

  Future<void> _promijeniSifru() async {
    setState(() {
      _error = null;
      _isLoading = true;
    });

    final staraSifra = _staraSifraController.text;
    final novaSifra = _novaSifraController.text;
    final potvrdaSifre = _potvrdaSifreController.text;

    if (novaSifra != potvrdaSifre) {
      setState(() {
        _error = "Lozinka i potvrda moraju biti iste!";
        _isLoading = false;
      });
      return;
    }
    if (novaSifra.length < 6) {
      setState(() {
        _error = "Lozinka mora imati najmanje 6 karaktera!";
        _isLoading = false;
      });
      return;
    }

    final korisnikProvider = Provider.of<KorisnikProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final korisnikId = AuthProvider.korisnikId;
      if (korisnikId == null) throw Exception("Korisnik nije pronađen.");

      final loginResult = await authProvider.login(AuthProvider.username ?? "", staraSifra);
      if (loginResult == null) {
        setState(() {
          _error = "Stara šifra nije ispravna!";
          _isLoading = false;
        });
        return;
      }

      final updateResult = await korisnikProvider.update(korisnikId, {
        "Lozinka": novaSifra,
        "LozinkaPotvrda": potvrdaSifre,
      });

      if (updateResult != null) {
        AuthProvider.username = null;
        AuthProvider.password = null;
        AuthProvider.korisnikId = null;
        Navigator.of(context).pop();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Šifra je uspješno promijenjena. Prijavite se ponovo."),
            backgroundColor: Colors.blueAccent,
          ),
        );
      } else {
        setState(() {
          _error = "Greška pri promjeni šifre!";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        "Promjena šifre",
        style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _staraSifraController,
                decoration: InputDecoration(
                  labelText: "Stara šifra",
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                obscureText: true,
                validator: (value) =>
                    value == null || value.isEmpty ? "Unesite staru šifru" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _novaSifraController,
                decoration: InputDecoration(
                  labelText: "Nova šifra",
                  prefixIcon: const Icon(Icons.lock_reset),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                obscureText: true,
                validator: (value) =>
                    value == null || value.isEmpty ? "Unesite novu šifru" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _potvrdaSifreController,
                decoration: InputDecoration(
                  labelText: "Potvrda nove šifre",
                  prefixIcon: const Icon(Icons.lock_reset),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                obscureText: true,
                validator: (value) =>
                    value == null || value.isEmpty ? "Potvrdite novu šifru" : null,
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
      actions: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    _promijeniSifru();
                  }
                },
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  "Promijeni šifru",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
        ),
      ],
    );
  }
}