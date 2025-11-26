import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:truevote_desktop/layouts/master_screen.dart';
import 'package:truevote_desktop/providers/drzava_provider.dart';
import 'package:truevote_desktop/models/drzava.dart';

class GeografskaAdministracijaScreen extends StatefulWidget {
  const GeografskaAdministracijaScreen({super.key});

  @override
  State<GeografskaAdministracijaScreen> createState() => _GeografskaAdministracijaScreenState();
}

class _GeografskaAdministracijaScreenState extends State<GeografskaAdministracijaScreen> {
  final _nazivController = TextEditingController();
  String? _nazivFilter;

  @override
  void dispose() {
    _nazivController.dispose();
    super.dispose();
  }

  Future<List<Drzava>> _fetchDrzave() async {
    final provider = Provider.of<DrzavaProvider>(context, listen: false);
    final filter = {
      if (_nazivFilter != null && _nazivFilter!.isNotEmpty) 'naziv': _nazivFilter,
    };
    final result = await provider.get(filter: filter);
    return result.result;
  }

  void _onSearch() {
    setState(() {
      _nazivFilter = _nazivController.text.isNotEmpty ? _nazivController.text : null;
    });
  }

  void _onClear() {
    _nazivController.clear();
    setState(() {
      _nazivFilter = null;
    });
  }

  void _showDrzavaDetalji(Drzava drzava) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.flag, color: Colors.blueAccent, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                drzava.naziv ?? "Nepoznata država",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(
          "ID države: ${drzava.id}",
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Zatvori"),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddDrzavaDialog({Drzava? drzava}) async {
    final _formKey = GlobalKey<FormState>();
    final _inputController = TextEditingController(text: drzava?.naziv ?? "");
    bool _isLoading = false;
    String? _error;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.lightBlueAccent],
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.flag, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Text(
                  drzava == null ? "Dodaj državu" : "Uredi državu",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
            content: SizedBox(
              width: 350,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _inputController,
                      decoration: InputDecoration(
                        labelText: "Naziv države",
                        prefixIcon: const Icon(Icons.flag),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF2F6FF),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Unesite naziv države";
                        }
                        return null;
                      },
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
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
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Otkaži"),
              ),
              ElevatedButton.icon(
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(drzava == null ? "Spremi" : "Sačuvaj izmjene"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          setState(() {
                            _isLoading = true;
                            _error = null;
                          });
                          try {
                            final provider = Provider.of<DrzavaProvider>(context, listen: false);
                            if (drzava == null) {
                              await provider.insert({
                                "naziv": _inputController.text.trim(),
                              });
                            } else {
                              await provider.update(drzava.id, {
                                "naziv": _inputController.text.trim(),
                              });
                            }
                            Navigator.of(context).pop(true);
                          } catch (e) {
                            setState(() {
                              _error = "Greška pri spremanju države.";
                              _isLoading = false;
                            });
                          }
                        }
                      },
              ),
            ],
          ),
        );
      },
    );
    setState(() {}); // Refresh FutureBuilder
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Geografska administracija - Države",
      Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nazivController,
                    decoration: InputDecoration(
                      labelText: "Pretraga po nazivu",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search),
                  label: const Text("Pretraži"),
                  onPressed: _onSearch,
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.clear),
                  label: const Text("Očisti filter"),
                  onPressed: _onClear,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Dodaj državu"),
                  onPressed: () => _showAddDrzavaDialog(),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Drzava>>(
                future: _fetchDrzave(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Greška pri učitavanju država.",
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                  final drzave = snapshot.data ?? [];
                  if (drzave.isEmpty) {
                    return const Center(
                      child: Text(
                        "Nema država.",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: drzave.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final drzava = drzave[index];
                      return GestureDetector(
                        onTap: () => _showDrzavaDetalji(drzava),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.flag, color: Colors.blueAccent),
                            title: Text(
                              drzava.naziv ?? "Nepoznata država",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                  tooltip: "Uredi",
                                  onPressed: () => _showAddDrzavaDialog(drzava: drzava),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  tooltip: "Obriši",
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Potvrda brisanja"),
                                        content: Text(
                                          "Da li ste sigurni da želite obrisati '${drzava.naziv ?? ''}'?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: const Text("Otkaži"),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            child: const Text(
                                              "Obriši",
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      final provider = Provider.of<DrzavaProvider>(context, listen: false);
                                      await provider.delete(drzava.id);
                                      setState(() {}); // Refresh FutureBuilder
                                    }
                                  },
                                ),
                              ],
                            ),
                            tileColor: const Color(0xFFF2F6FF),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}