import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:truevote_desktop/layouts/master_screen.dart';
import 'package:truevote_desktop/providers/grad_provider.dart';
import 'package:truevote_desktop/providers/drzava_provider.dart';
import 'package:truevote_desktop/models/grad.dart';
import 'package:truevote_desktop/models/drzava.dart';

class GeografskaAdministracijaGradScreen extends StatefulWidget {
  const GeografskaAdministracijaGradScreen({super.key});

  @override
  State<GeografskaAdministracijaGradScreen> createState() => _GeografskaAdministracijaGradScreenState();
}

class _GeografskaAdministracijaGradScreenState extends State<GeografskaAdministracijaGradScreen> {
  final _nazivController = TextEditingController();
  final _drzavaNazivController = TextEditingController();
  String? _nazivFilter;
  String? _drzavaNazivFilter;

  @override
  void dispose() {
    _nazivController.dispose();
    _drzavaNazivController.dispose();
    super.dispose();
  }

  Future<List<Grad>> _fetchGradovi() async {
    final provider = Provider.of<GradProvider>(context, listen: false);
    final filter = {
      if (_nazivFilter != null && _nazivFilter!.isNotEmpty) 'naziv': _nazivFilter,
      if (_drzavaNazivFilter != null && _drzavaNazivFilter!.isNotEmpty) 'DrzavaNaziv': _drzavaNazivFilter,
    };
    final result = await provider.get(filter: filter);
    return result.result;
  }

  Future<List<Drzava>> _fetchDrzave() async {
    final provider = Provider.of<DrzavaProvider>(context, listen: false);
    final result = await provider.get();
    return result.result;
  }

  void _onSearch() {
    setState(() {
      _nazivFilter = _nazivController.text.isNotEmpty ? _nazivController.text : null;
      _drzavaNazivFilter = _drzavaNazivController.text.isNotEmpty ? _drzavaNazivController.text : null;
    });
  }

  void _onClear() {
    _nazivController.clear();
    _drzavaNazivController.clear();
    setState(() {
      _nazivFilter = null;
      _drzavaNazivFilter = null;
    });
  }

  void _showGradDetalji(Grad grad) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.location_city, color: Colors.blueAccent, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                grad.naziv ?? "Nepoznat grad",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(
          "ID grada: ${grad.id}\nDržava: ${grad.drzava?.naziv ?? ''}",
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

  Future<void> _showAddGradDialog({Grad? grad}) async {
    final _formKey = GlobalKey<FormState>();
    final _inputController = TextEditingController(text: grad?.naziv ?? "");
    int? _selectedDrzavaId = grad?.drzavaId;
    bool _isLoading = false;
    String? _error;
    List<Drzava> _drzave = [];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return FutureBuilder<List<Drzava>>(
              future: _fetchDrzave(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blueAccent),
                  );
                }
                _drzave = snapshot.data ?? [];
                return AlertDialog(
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
                        child: const Icon(Icons.location_city, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        grad == null ? "Dodaj grad" : "Uredi grad",
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
                              labelText: "Naziv grada",
                              prefixIcon: const Icon(Icons.location_city),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF2F6FF),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Unesite naziv grada";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: _selectedDrzavaId,
                            decoration: InputDecoration(
                              labelText: "Država",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF2F6FF),
                            ),
                            items: _drzave
                                .map((drzava) => DropdownMenuItem<int>(
                                      value: drzava.id,
                                      child: Text(drzava.naziv ?? ""),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDrzavaId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return "Odaberite državu";
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
                      label: Text(grad == null ? "Spremi" : "Sačuvaj izmjene"),
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
                                  final provider = Provider.of<GradProvider>(context, listen: false);
                                  if (grad == null) {
                                    await provider.insert({
                                      "naziv": _inputController.text.trim(),
                                      "drzavaId": _selectedDrzavaId,
                                    });
                                  } else {
                                    await provider.update(grad.id, {
                                      "naziv": _inputController.text.trim(),
                                      "drzavaId": _selectedDrzavaId,
                                    });
                                  }
                                  Navigator.of(context).pop(true);
                                } catch (e) {
                                  setState(() {
                                    _error = "Greška pri spremanju grada.";
                                    _isLoading = false;
                                  });
                                }
                              }
                            },
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
    setState(() {}); // Refresh FutureBuilder
  }

  Future<void> _tryDeleteGrad(Grad grad) async {
    final provider = Provider.of<GradProvider>(context, listen: false);
    bool canDelete = false;
    String? error;

    try {
      canDelete = await provider.canDelete(grad.id);
    } catch (e) {
      error = "Greška pri provjeri mogućnosti brisanja.";
    }

    if (!canDelete) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Brisanje nije dozvoljeno"),
          content: Text(
            "Grad '${grad.naziv ?? ''}' je povezan sa drugim entitetima i ne može biti obrisan.",
            style: const TextStyle(color: Colors.red),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("U redu"),
            ),
          ],
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Potvrda brisanja"),
        content: Text(
          "Da li ste sigurni da želite obrisati '${grad.naziv ?? ''}'?",
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
      await provider.delete(grad.id);
      setState(() {}); // Refresh FutureBuilder
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Geografska administracija - Gradovi",
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
                      labelText: "Pretraga po nazivu grada",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _drzavaNazivController,
                    decoration: InputDecoration(
                      labelText: "Pretraga po nazivu države",
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
                  label: const Text("Očisti filtere"),
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
                  label: const Text("Dodaj grad"),
                  onPressed: () => _showAddGradDialog(),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Grad>>(
                future: _fetchGradovi(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Greška pri učitavanju gradova.",
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                  final gradovi = snapshot.data ?? [];
                  if (gradovi.isEmpty) {
                    return const Center(
                      child: Text(
                        "Nema gradova.",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: gradovi.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final grad = gradovi[index];
                      return GestureDetector(
                        onTap: () => _showGradDetalji(grad),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.location_city, color: Colors.blueAccent),
                            title: Text(
                              grad.naziv ?? "Nepoznat grad",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text("Država: ${grad.drzava?.naziv ?? ''}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                  tooltip: "Uredi",
                                  onPressed: () => _showAddGradDialog(grad: grad),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  tooltip: "Obriši",
                                  onPressed: () => _tryDeleteGrad(grad),
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