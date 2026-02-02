import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:truevote_desktop/layouts/master_screen.dart';
import 'package:truevote_desktop/models/pitanje.dart';
import 'package:truevote_desktop/models/kategorija.dart';
import 'package:truevote_desktop/providers/pitanje_provider.dart';
import 'package:truevote_desktop/providers/kategorija_provider.dart';

class UpravljanjeFAQScreen extends StatefulWidget {
  const UpravljanjeFAQScreen({super.key});

  @override
  State<UpravljanjeFAQScreen> createState() => _UpravljanjeFAQScreenState();
}

class _UpravljanjeFAQScreenState extends State<UpravljanjeFAQScreen> {
  List<Kategorija> _kategorije = [];
  Map<int, List<Pitanje>> _faqPoKategoriji = {};
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _kategorijaSearchController = TextEditingController();
  String _searchFilter = "";
  String _kategorijaFilter = "";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _kategorijaSearchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final kategorijaProvider = Provider.of<KategorijaProvider>(context, listen: false);
    final pitanjeProvider = Provider.of<PitanjeProvider>(context, listen: false);

    final kategorijeResult = await kategorijaProvider.get(
      filter: _kategorijaFilter.isNotEmpty ? {'naziv': _kategorijaFilter} : null,
    );
    final pitanjaResult = await pitanjeProvider.get(
      filter: _searchFilter.isNotEmpty ? {'pitanjeText': _searchFilter} : null,
    );

    setState(() {
      _kategorije = kategorijeResult.result;
      _faqPoKategoriji = {};
      for (var kat in _kategorije) {
        final faqs = pitanjaResult.result.where((f) => f.kategorijaId == kat.id).toList();
        if (faqs.isNotEmpty || _searchFilter.isEmpty) {
          _faqPoKategoriji[kat.id] = faqs;
        }
      }
      _isLoading = false;
    });
  }

  Future<void> _kreirajKategoriju() async {
    final _formKey = GlobalKey<FormState>();
    final nazivController = TextEditingController();
    final opisController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Colors.blueAccent, Colors.lightBlueAccent]),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.category, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            const Text("Kreiraj kategoriju", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nazivController,
                  decoration: const InputDecoration(
                    labelText: "Naziv kategorije *",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Naziv kategorije je obavezan.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: opisController,
                  decoration: const InputDecoration(
                    labelText: "Opis kategorije *",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Opis kategorije je obavezan.";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Otkaži"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                Navigator.of(context).pop(true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
            child: const Text("Kreiraj"),
          ),
        ],
      ),
    );
    if (result == true) {
      final provider = Provider.of<KategorijaProvider>(context, listen: false);
      await provider.insert({
        'naziv': nazivController.text.trim(),
        'opis': opisController.text.trim(),
      });
      _fetchData();
    }
  }

  Future<void> _urediKategoriju(Kategorija kategorija) async {
    final _formKey = GlobalKey<FormState>();
    final nazivController = TextEditingController(text: kategorija.naziv);
    final opisController = TextEditingController(text: kategorija.opis);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Colors.blueAccent, Colors.lightBlueAccent]),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.category, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            const Text("Uredi kategoriju", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nazivController,
                  decoration: const InputDecoration(
                    labelText: "Naziv kategorije *",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Naziv kategorije je obavezan.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: opisController,
                  decoration: const InputDecoration(
                    labelText: "Opis kategorije *",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Opis kategorije je obavezan.";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Otkaži"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                Navigator.of(context).pop(true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
            child: const Text("Sačuvaj"),
          ),
        ],
      ),
    );
    if (result == true) {
      final provider = Provider.of<KategorijaProvider>(context, listen: false);
      await provider.update(kategorija.id, {
        'naziv': nazivController.text.trim(),
        'opis': opisController.text.trim(),
      });
      _fetchData();
    }
  }

  Future<void> _obrisiKategoriju(Kategorija kategorija) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Potvrda brisanja"),
        content: Text("Obrisati kategoriju '${kategorija.naziv ?? ""}' i sva njena pitanja?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Otkaži"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Obriši", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final provider = Provider.of<KategorijaProvider>(context, listen: false);
      await provider.delete(kategorija.id);
      _fetchData();
    }
  }

  Future<void> _urediPitanje(Pitanje pitanje) async {
    final _formKey = GlobalKey<FormState>();
    int? kategorijaId = pitanje.kategorijaId;
    final pitanjeController = TextEditingController(text: pitanje.pitanjeText);
    final odgovorController = TextEditingController(text: pitanje.odgovorText);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [Colors.blueAccent, Colors.lightBlueAccent]),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.question_answer, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              const Text("Uredi pitanje i odgovor", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: kategorijaId,
                    items: _kategorije
                        .map((k) => DropdownMenuItem(
                              value: k.id,
                              child: Text(k.naziv ?? ""),
                            ))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        kategorijaId = v;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Kategorija *",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null) {
                        return "Kategorija je obavezna.";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: pitanjeController,
                    decoration: const InputDecoration(
                      labelText: "Pitanje *",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Pitanje je obavezno.";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: odgovorController,
                    decoration: const InputDecoration(
                      labelText: "Odgovor *",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Odgovor je obavezan.";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Otkaži"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(true);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
              child: const Text("Sačuvaj"),
            ),
          ],
        ),
      ),
    );
    if (result == true) {
      final provider = Provider.of<PitanjeProvider>(context, listen: false);
      await provider.update(pitanje.id, {
        'kategorijaId': kategorijaId,
        'pitanjeText': pitanjeController.text.trim(),
        'odgovorText': odgovorController.text.trim(),
        'datumKreiranja': pitanje.datumKreiranja?.toIso8601String() ?? DateTime.now().toIso8601String(),
      });
      _fetchData();
    }
  }

  Future<void> _obrisiPitanje(Pitanje pitanje) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Potvrda brisanja"),
        content: const Text("Obrisati ovo pitanje i odgovor?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Otkaži"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Obriši", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final provider = Provider.of<PitanjeProvider>(context, listen: false);
      await provider.delete(pitanje.id);
      _fetchData();
    }
  }

  Future<void> _kreirajPitanje() async {
    final _formKey = GlobalKey<FormState>();
    int? kategorijaId = _kategorije.isNotEmpty ? _kategorije.first.id : null;
    final pitanjeController = TextEditingController();
    final odgovorController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [Colors.blueAccent, Colors.lightBlueAccent]),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.question_answer, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              const Text("Kreiraj pitanje i odgovor", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: kategorijaId,
                    items: _kategorije
                        .map((k) => DropdownMenuItem(
                              value: k.id,
                              child: Text(k.naziv ?? ""),
                            ))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        kategorijaId = v;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Kategorija *",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null) {
                        return "Kategorija je obavezna.";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: pitanjeController,
                    decoration: const InputDecoration(
                      labelText: "Pitanje *",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Pitanje je obavezno.";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: odgovorController,
                    decoration: const InputDecoration(
                      labelText: "Odgovor *",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Odgovor je obavezan.";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Otkaži"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(true);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
              child: const Text("Kreiraj"),
            ),
          ],
        ),
      ),
    );
    if (result == true) {
      final provider = Provider.of<PitanjeProvider>(context, listen: false);
      await provider.insert({
        'kategorijaId': kategorijaId,
        'pitanjeText': pitanjeController.text.trim(),
        'odgovorText': odgovorController.text.trim(),
        'datumKreiranja': DateTime.now().toIso8601String(),
      });
      _fetchData();
    }
  }

  void _onSearchPressed() {
    setState(() {
      _searchFilter = _searchController.text;
      _kategorijaFilter = _kategorijaSearchController.text;
    });
    _fetchData();
  }

  void _onClearFilterPressed() {
    setState(() {
      _searchController.clear();
      _kategorijaSearchController.clear();
      _searchFilter = "";
      _kategorijaFilter = "";
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final filtriraneKategorije = _kategorije
        .where((kategorija) =>
            _searchFilter.isEmpty ||
            (_faqPoKategoriji[kategorija.id]?.isNotEmpty ?? false))
        .toList();

    final nemaRezultata = (_searchFilter.isNotEmpty || _kategorijaFilter.isNotEmpty) && filtriraneKategorije.isEmpty;

    return MasterScreen(
      "Upravljanje FAQ sekcijom",
      Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Kreiraj kategoriju"),
                  onPressed: _kreirajKategoriju,
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_comment),
                  label: const Text("Kreiraj pitanje i odgovor"),
                  onPressed: _kategorije.isEmpty ? null : _kreirajPitanje,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: "Pretraži pitanja",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _kategorijaSearchController,
                    decoration: const InputDecoration(
                      labelText: "Pretraži kategorije po nazivu",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _onSearchPressed,
                  icon: const Icon(Icons.search),
                  label: const Text("Pretraži"),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _onClearFilterPressed,
                  icon: const Icon(Icons.clear),
                  label: const Text("Očisti filtere"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (nemaRezultata)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Text(
                    "Nema rezultata.",
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: ExpansionPanelList.radio(
                    expandedHeaderPadding: EdgeInsets.zero,
                    children: filtriraneKategorije.map((kategorija) {
                      final faqs = _faqPoKategoriji[kategorija.id] ?? [];
                      return ExpansionPanelRadio(
                        value: kategorija.id,
                        headerBuilder: (context, isExpanded) => ListTile(
                          title: Text(
                            kategorija.naziv ?? "",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                          ),
                          subtitle: kategorija.opis != null && kategorija.opis!.isNotEmpty
                              ? Text(kategorija.opis ?? "", style: const TextStyle(color: Colors.black54))
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                tooltip: "Uredi kategoriju",
                                onPressed: () => _urediKategoriju(kategorija),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                tooltip: "Obriši kategoriju",
                                onPressed: () => _obrisiKategoriju(kategorija),
                              ),
                            ],
                          ),
                        ),
                        body: faqs.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text("Nema pitanja u ovoj kategoriji."),
                              )
                            : Column(
                                children: faqs
                                    .map(
                                      (faq) => Card(
                                        elevation: 2,
                                        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        color: const Color(0xFFF2F6FF),
                                        child: ListTile(
                                          title: Text(
                                            faq.pitanjeText ?? "",
                                            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blueAccent),
                                          ),
                                          subtitle: Padding(
                                            padding: const EdgeInsets.only(top: 4.0),
                                            child: Text(
                                              faq.odgovorText ?? "",
                                              style: const TextStyle(color: Colors.black87),
                                            ),
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                                tooltip: "Uredi",
                                                onPressed: () => _urediPitanje(faq),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                                tooltip: "Obriši",
                                                onPressed: () => _obrisiPitanje(faq),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}