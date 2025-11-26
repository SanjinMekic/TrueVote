import 'package:truevote_desktop/providers/auth_provider.dart';
import 'package:truevote_desktop/models/korisnik.dart';
import 'package:truevote_desktop/screens/pocetna_screen.dart';
import 'package:truevote_desktop/layouts/master_screen.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    final authProvider = AuthProvider();

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

        // Pretpostavljamo da je admin ako ima uloga naziv 'Administrator'
        if (response.uloga?.naziv == 'Admin') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MasterScreen(
                "Početna",
                PocetnaScreen(),
              ),
            ),
          );
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            child: Container(
              width: 420,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.15),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 36),
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.2),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(18),
                        child: const Icon(Icons.lock_outline, size: 48, color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Dobrodošli nazad!",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Prijavite se za nastavak",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),
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
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
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
                              : Text(
                                  "Prijavi se",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Zaboravili ste lozinku?",
                          style: TextStyle(
                            color: Colors.blueAccent.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
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