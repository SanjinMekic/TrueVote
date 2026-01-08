import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:truevote_mobile/screens/pocetna_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/korisnik_provider.dart';
import '../layouts/master_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _passwordError;
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _passwordError = null;
      _isLoading = true;
    });

    final username = _usernameController.text;
    final password = _passwordController.text;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final response = await authProvider.login(username, password);

      if (response == null) {
        setState(() {
          _passwordError = "Pogrešno korisničko ime ili lozinka";
        });
      } else {
        AuthProvider.username = username;
        AuthProvider.password = password;
        AuthProvider.setUser(response);

        // Dozvoljena rola je 'Birac'
        if (response.uloga?.naziv == 'Birac') {
          final korisnikProvider = Provider.of<KorisnikProvider>(context, listen: false);
          final korisnik = await korisnikProvider.getById(response.id);

          // NOVA LOGIKA: Pin može biti "ima" ili "nema"
          if (korisnik != null && korisnik.pin == "nema") {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => _PinDialog(
                korisnikId: korisnik.id,
                onPinCreated: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => MasterScreen(child: const PocetnaScreen()),
                    ),
                  );
                },
              ),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MasterScreen(child: const PocetnaScreen()),
              ),
            );
          }
        } else {
          setState(() {
            _passwordError = "Nemate prava";
          });
        }
      }
    } catch (e) {
      setState(() {
        _passwordError = "Greška prilikom prijave";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.blueAccent, Colors.lightBlueAccent],
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: const Icon(Icons.lock_outline, size: 48, color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Dobrodošli!",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Prijavite se za nastavak",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: "Korisničko ime",
                          prefixIcon: const Icon(Icons.person_outline),
                          filled: true,
                          fillColor: const Color(0xFFF2F6FF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? "Unesite korisničko ime" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: "Lozinka",
                          prefixIcon: const Icon(Icons.lock_outline),
                          filled: true,
                          fillColor: const Color(0xFFF2F6FF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        obscureText: true,
                        validator: (value) =>
                            value == null || value.isEmpty ? "Unesite lozinku" : null,
                      ),
                      if (_passwordError != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _passwordError!,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    _login();
                                  }
                                },
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Prijavi se",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
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

class _PinDialog extends StatefulWidget {
  final int korisnikId;
  final VoidCallback onPinCreated;

  const _PinDialog({required this.korisnikId, required this.onPinCreated, super.key});

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final List<TextEditingController> _pinControllers =
      List.generate(4, (_) => TextEditingController());
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    for (var c in _pinControllers) {
      c.dispose();
    }
    super.dispose();
  }

  String get _pin => _pinControllers.map((c) => c.text).join();

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
    final success = await korisnikProvider.kreirajPin(widget.korisnikId, _pin);

    if (success) {
      Navigator.of(context).pop();
      widget.onPinCreated();
    } else {
      setState(() {
        _error = "Greška pri kreiranju PIN-a.";
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
            "Dobrodošli u TrueVote!",
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
          constraints: const BoxConstraints(minHeight: 220),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Text(
                  "Prije nastavka, potrebno je da kreirate svoj sigurnosni PIN.\n\n"
                  "Ovaj četveroznamenkasti broj koristićete prilikom glasanja. "
                  "PIN je važan za sigurnost vašeg glasa i pristup glasanju, zato ga pažljivo zapamtite!",
                  style: TextStyle(fontSize: 15, color: Colors.black87),
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