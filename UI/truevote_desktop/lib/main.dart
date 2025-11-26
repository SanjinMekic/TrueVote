import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:truevote_desktop/providers/auth_provider.dart';
import 'package:truevote_desktop/providers/drzava_provider.dart';
import 'package:truevote_desktop/providers/grad_provider.dart';
import 'package:truevote_desktop/providers/korisnik_provider.dart';
import 'package:truevote_desktop/providers/opstina_provider.dart';
import 'package:truevote_desktop/providers/stranka_provider.dart';
import 'package:truevote_desktop/screens/login_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<KorisnikProvider>(
          create: (_) => KorisnikProvider(),
        ),
        ChangeNotifierProvider<DrzavaProvider>(
          create: (_) => DrzavaProvider(),
        ),
        ChangeNotifierProvider<GradProvider>(
          create: (_) => GradProvider(),
        ),
        ChangeNotifierProvider<OpstinaProvider>(
          create: (_) => OpstinaProvider(),
        ),
        ChangeNotifierProvider<StrankaProvider>(
          create: (_) => StrankaProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrueVote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginPage(),
    );
  }
}