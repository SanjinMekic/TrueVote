import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pitanje_provider.dart';
import '../providers/kategorija_provider.dart';
import '../models/pitanje.dart';
import '../models/kategorija.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> with AutomaticKeepAliveClientMixin {
  List<Kategorija> _kategorije = [];
  Map<int, List<Pitanje>> _faqPoKategoriji = {};
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  String _searchFilter = "";

  @override
  bool get wantKeepAlive => false; // Bitno: uvijek false da se ekran ne kešira

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Osvježi FAQ svaki put kad se ekran prikaže (kad se klikne Q&A tab)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pozovi refresh svaki put kad se ekran prikaže
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final kategorijaProvider = Provider.of<KategorijaProvider>(context, listen: false);
    final pitanjeProvider = Provider.of<PitanjeProvider>(context, listen: false);

    final kategorijeResult = await kategorijaProvider.get();
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

  void _onSearchChanged(String value) {
    setState(() {
      _searchFilter = value;
    });
    _fetchData();
  }

  void _onClearFilterPressed() {
    setState(() {
      _searchController.clear();
      _searchFilter = "";
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final filtriraneKategorije = _kategorije
        .where((kategorija) =>
            _searchFilter.isEmpty ||
            (_faqPoKategoriji[kategorija.id]?.isNotEmpty ?? false))
        .toList();

    final nemaRezultata = (_searchFilter.isNotEmpty) && filtriraneKategorije.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Q&A",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF2F6FF),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Pretraži pitanja",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _onClearFilterPressed,
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: _onSearchChanged,
              onChanged: (value) {
                setState(() {}); // Za prikaz X dugmeta
              },
              textInputAction: TextInputAction.search,
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.blueAccent),
                ),
              )
            else if (nemaRezultata)
              Expanded(
                child: Center(
                  child: Text(
                    "Nema rezultata.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView(
                  children: filtriraneKategorije.map((kategorija) {
                    final faqs = _faqPoKategoriji[kategorija.id] ?? [];
                    return ExpansionTile(
                      title: Text(
                        kategorija.naziv ?? "",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      subtitle: kategorija.opis != null && kategorija.opis!.isNotEmpty
                          ? Text(kategorija.opis ?? "", style: const TextStyle(color: Colors.black54))
                          : null,
                      children: faqs.isEmpty
                          ? [
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text("Nema pitanja u ovoj kategoriji."),
                              )
                            ]
                          : faqs
                              .map(
                                (faq) => Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
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
                                  ),
                                ),
                              )
                              .toList(),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}