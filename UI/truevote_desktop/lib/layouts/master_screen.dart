import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:truevote_desktop/providers/auth_provider.dart';
import 'package:truevote_desktop/providers/korisnik_provider.dart';
import 'package:truevote_desktop/models/korisnik.dart';
import 'package:truevote_desktop/screens/administracija_stranki_screen.dart';
import 'package:truevote_desktop/screens/faq_screen.dart';
import 'package:truevote_desktop/screens/geografska_administracija_drzava_screen.dart';
import 'package:truevote_desktop/screens/geografska_administracija_gradova_screen.dart';
import 'package:truevote_desktop/screens/geografska_administracija_opstina_screen.dart';
import 'package:truevote_desktop/screens/grafovi_screen.dart';
import 'package:truevote_desktop/screens/login_screen.dart';
import 'package:truevote_desktop/screens/upravljanje_nalozima_screen.dart';
import 'dart:convert';

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

  Widget _buildUserAvatar(BuildContext context) {
    final korisnikId = AuthProvider.korisnikId;
    if (korisnikId == null) {
      return _defaultAvatar();
    }
    return FutureBuilder<Korisnik>(
      future: Provider.of<KorisnikProvider>(context, listen: false).getById(korisnikId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _defaultAvatar();
        }
        final korisnik = snapshot.data;
        if (korisnik == null || korisnik.slika == null || korisnik.slika!.isEmpty) {
          return _defaultAvatar();
        }
        try {
          final bytes = base64Decode(korisnik.slika!);
          return Container(
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
            child: ClipOval(
              child: Image.memory(
                bytes,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _defaultAvatar(),
              ),
            ),
          );
        } catch (e) {
          return _defaultAvatar();
        }
      },
    );
  }

  Widget _defaultAvatar() {
    return Container(
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
      child: const Icon(
        Icons.person,
        size: 40,
        color: Colors.blueAccent,
      ),
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
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
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
                        _buildUserAvatar(context),
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
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.home_outlined,
                      color: Colors.blueAccent,
                    ),
                    title: Text(
                      "Početna",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      // Dodaj navigaciju na početnu stranicu
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.flag,
                      color: Colors.blueAccent,
                    ),
                    title: Text(
                      "Administracija država",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const GeografskaAdministracijaScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.location_city,
                      color: Colors.blueAccent,
                    ),
                    title: Text(
                      "Administracija gradova",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const GeografskaAdministracijaGradScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.map,
                      color: Colors.blueAccent,
                    ),
                    title: Text(
                      "Administracija opština",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const GeografskaAdministracijaOpstinaScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.how_to_vote,
                      color: Colors.blueAccent,
                    ),
                    title: Text(
                      "Administracija stranki",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const StrankaScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.how_to_vote,
                      color: Colors.blueAccent,
                    ),
                    title: Text(
                      "Upravljanje nalozima",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const UpravljanjeNalozimaScreen(),
                        ),
                      );
                    },
                  ),
                   ListTile(
                    leading: Icon(
                      Icons.how_to_vote,
                      color: Colors.blueAccent,
                    ),
                    title: Text(
                      "FAQ Sekcija",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const UpravljanjeFAQScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.how_to_vote,
                      color: Colors.blueAccent,
                    ),
                    title: Text(
                      "Grafovi",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                               GrafoviScreen(),
                        ),
                      );
                    },
                  ),
                 const Divider(),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.redAccent),
                    title: Text(
                      "Odjava",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.redAccent,
                      ),
                    ),
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
                icon: const Icon(
                  Icons.close,
                  size: 28,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                tooltip: "Zatvori meni",
              ),
            ),
          ],
        ),
      ),
      body: Container(padding: const EdgeInsets.all(24), child: child),
    );
  }
}