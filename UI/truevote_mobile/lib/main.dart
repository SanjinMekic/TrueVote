import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/drzava_provider.dart';
import 'providers/glas_provider.dart';
import 'providers/grad_provider.dart';
import 'providers/izbor_provider.dart';
import 'providers/kandidat_provider.dart';
import 'providers/kategorija_provider.dart';
import 'providers/korisnik_provider.dart';
import 'providers/opstina_provider.dart';
import 'providers/pitanje_provider.dart';
import 'providers/stranka_provider.dart';
import 'providers/tip_izbora_provider.dart';
import 'providers/uloga_provider.dart';
import 'screens/login_screen.dart';

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
        ChangeNotifierProvider<UlogaProvider>(
          create: (_) => UlogaProvider(),
        ),
        ChangeNotifierProvider<KategorijaProvider>(
          create: (_) => KategorijaProvider(),
        ),
        ChangeNotifierProvider<PitanjeProvider>(
          create: (_) => PitanjeProvider(),
        ),
        ChangeNotifierProvider<TipIzboraProvider>(
          create: (_) => TipIzboraProvider(),
        ),
        ChangeNotifierProvider<IzborProvider>(
          create: (_) => IzborProvider(),
        ),
        ChangeNotifierProvider<KandidatProvider>(
          create: (_) => KandidatProvider(),
        ),
        ChangeNotifierProvider<GlasProvider>(
          create: (_) => GlasProvider(),
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
      title: 'TrueVote Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: const LoginScreen(),
    );
  }
}