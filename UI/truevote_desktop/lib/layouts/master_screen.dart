import 'package:flutter/material.dart';
import 'package:truevote_desktop/providers/auth_provider.dart';
import 'package:truevote_desktop/screens/login_screen.dart';

class MasterScreen extends StatelessWidget {
  final String title;
  final Widget child;

  const MasterScreen(this.title, this.child, {super.key});

  void _logout(BuildContext context) {
    AuthProvider.username = null;
    AuthProvider.password = null;
    AuthProvider.korisnikId = null;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final korisnickoIme = AuthProvider.username ?? "Korisnik";
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      appBar: AppBar(
  title: Text(
    title,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
  backgroundColor: Colors.blueAccent,
  elevation: 8,
  iconTheme: const IconThemeData(color: Colors.white), // Ikona hamburgera bijela
),
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(32)),
        ),
        child: Stack(
          children: [
            Container(
              color: Colors.white,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.lightBlueAccent],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.person, size: 40, color: Colors.blueAccent),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "TrueVote",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          korisnickoIme,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.home_outlined, color: Colors.blueAccent),
                    title: Text("Početna", style: TextStyle(fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.pop(context);
                      // Dodaj navigaciju na početnu stranicu
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.location_city, color: Colors.blueAccent),
                    title: Text("Geografska administracija", style: TextStyle(fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.pop(context);
                      // Dodaj navigaciju na korisnike
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings_outlined, color: Colors.blueAccent),
                    title: Text("Postavke", style: TextStyle(fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.pop(context);
                      // Dodaj navigaciju na postavke
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.redAccent),
                    title: Text("Odjava", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.redAccent)),
                    onTap: () {
                      Navigator.pop(context);
                      _logout(context);
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                icon: const Icon(Icons.close, size: 28, color: Colors.white), // Promijenjeno u bijelu boju
                onPressed: () {
                  Navigator.pop(context);
                },
                tooltip: "Zatvori meni",
              ),
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    );
  }
}