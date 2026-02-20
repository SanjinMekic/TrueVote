import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

enum _SupportState { unknown, supported, unsupported }

class BiometrijaScreen extends StatefulWidget {
  final VoidCallback onSuccess;

  const BiometrijaScreen({super.key, required this.onSuccess});

  @override
  State<BiometrijaScreen> createState() => _BiometrijaScreenState();
}

class _BiometrijaScreenState extends State<BiometrijaScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;
  bool _biometricPassed = false;

  @override
  void initState() {
    super.initState();
    auth.isDeviceSupported().then(
      (bool isSupported) => setState(
        () => _supportState = isSupported
            ? _SupportState.supported
            : _SupportState.unsupported,
      ),
    );
  }

  Future<void> _authenticateWithBiometrics() async {
    if (_isAuthenticating) return;
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Potvrdite svoj identitet',
        biometricOnly: false,
      );
      setState(() {
        _isAuthenticating = false;
        _authorized = authenticated ? 'Authorized' : 'Not Authorized';
        _biometricPassed = authenticated;
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Unexpected Error - ${e.message}';
        _biometricPassed = false;
      });
      if (e.code == 'NotEnrolled' || e.code == 'PasscodeNotSet' || e.code == 'NotAvailable') {
        _showNoAuthDialog();
      }
    }
    if (!mounted) return;
    if (authenticated) {
      widget.onSuccess();
    }
  }

  void _showNoAuthDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nema postavljene zaštite"),
        content: const Text(
          "Na vašem uređaju nije postavljen nijedan sigurnosni metod. "
          "Molimo vas da postavite PIN, uzorak, lozinku, otisak prsta ili prepoznavanje lica u postavkama uređaja, pa se vratite u aplikaciju.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("U redu"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Autentifikacija", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF2F6FF),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(top: 30, bottom: 100),
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (_supportState == _SupportState.unknown)
                    const CircularProgressIndicator()
                  else if (_supportState == _SupportState.unsupported)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
                      child: Column(
                        children: [
                          const Text(
                            'Vaš uređaj nema postavljenu nikakvu vrstu zaštite.',
                            style: TextStyle(fontSize: 18, color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Molimo vas da postavite PIN, uzorak, lozinku, otisak prsta ili prepoznavanje lica u postavkama uređaja, pa se vratite u aplikaciju.",
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
                      child: Text(
                        "Radi vaše sigurnosti i zaštite integriteta glasanja, potrebno je da potvrdite svoj identitet putem biometrijske autentifikacije (otisak prsta ili lice) ili uzorak/PIN. Ova provjera osigurava da samo vi možete pristupiti i glasati sa svog uređaja.",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              )
            ],
          ),
          if (_supportState == _SupportState.supported)
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: _isAuthenticating
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.fingerprint),
                    label: Text(
                      _isAuthenticating ? "Autentifikacija..." : "Autentifikuj se",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    onPressed: _isAuthenticating ? null : _authenticateWithBiometrics,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}