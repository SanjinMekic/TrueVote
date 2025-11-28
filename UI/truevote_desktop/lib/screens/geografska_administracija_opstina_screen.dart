import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:truevote_desktop/layouts/master_screen.dart';
import 'package:truevote_desktop/providers/opstina_provider.dart';
import 'package:truevote_desktop/providers/grad_provider.dart';
import 'package:truevote_desktop/models/opstina.dart';
import 'package:truevote_desktop/models/grad.dart';

class GeografskaAdministracijaOpstinaScreen extends StatefulWidget {
  const GeografskaAdministracijaOpstinaScreen({super.key});

  @override
  State<GeografskaAdministracijaOpstinaScreen> createState() => _GeografskaAdministracijaOpstinaScreenState();
}

class _GeografskaAdministracijaOpstinaScreenState extends State<GeografskaAdministracijaOpstinaScreen> {
  final _nazivController = TextEditingController();
  final _gradNazivController = TextEditingController();
  final _drzavaNazivController = TextEditingController();
  String? _nazivFilter;
  String? _gradNazivFilter;
  String? _drzavaNazivFilter;

  @override
  void dispose() {
    _nazivController.dispose();
    _gradNazivController.dispose();
    _drzavaNazivController.dispose();
    super.dispose();
  }

  Future<List<Opstina>> _fetchOpstine() async {
    final provider = Provider.of<OpstinaProvider>(context, listen: false);
    final filter = {
      if (_nazivFilter != null && _nazivFilter!.isNotEmpty) 'naziv': _nazivFilter,
      if (_gradNazivFilter != null && _gradNazivFilter!.isNotEmpty) 'GradNaziv': _gradNazivFilter,
      if (_drzavaNazivFilter != null && _drzavaNazivFilter!.isNotEmpty) 'DrzavaNaziv': _drzavaNazivFilter,
    };
    final result = await provider.get(filter: filter);
    return result.result;
  }

  Future<List<Grad>> _fetchGradovi() async {
    final provider = Provider.of<GradProvider>(context, listen: false);
    final result = await provider.get();
    return result.result;
  }

  void _onSearch() {
    setState(() {
      _nazivFilter = _nazivController.text.isNotEmpty ? _nazivController.text : null;
      _gradNazivFilter = _gradNazivController.text.isNotEmpty ? _gradNazivController.text : null;
      _drzavaNazivFilter = _drzavaNazivController.text.isNotEmpty ? _drzavaNazivController.text : null;
    });
  }

  void _onClear() {
    _nazivController.clear();
    _gradNazivController.clear();
    _drzavaNazivController.clear();
    setState(() {
      _nazivFilter = null;
      _gradNazivFilter = null;
      _drzavaNazivFilter = null;
    });
  }

  void _showOpstinaDetalji(Opstina opstina) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.map, color: Colors.blueAccent, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                opstina.naziv ?? "Nepoznata opština",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(
          "ID opštine: ${opstina.id}\nGrad: ${opstina.grad?.naziv ?? ''}\nDržava: ${opstina.grad?.drzava?.naziv ?? ''}",
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

  Future<void> _showAddOpstinaDialog({Opstina? opstina}) async {
    final _formKey = GlobalKey<FormState>();
    final _inputController = TextEditingController(text: opstina?.naziv ?? "");
    int? _selectedGradId = opstina?.gradId;
    bool _isLoading = false;
    String? _error;
    List<Grad> _gradovi = [];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return FutureBuilder<List<Grad>>(
              future: _fetchGradovi(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blueAccent),
                  );
                }
                _gradovi = snapshot.data ?? [];
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
                        child: const Icon(Icons.map, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        opstina == null ? "Dodaj opštinu" : "Uredi opštinu",
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
                              labelText: "Naziv opštine",
                              prefixIcon: const Icon(Icons.map),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF2F6FF),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Unesite naziv opštine";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: _selectedGradId,
                            decoration: InputDecoration(
                              labelText: "Grad",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF2F6FF),
                            ),
                            items: _gradovi
                                .map((grad) => DropdownMenuItem<int>(
                                      value: grad.id,
                                      child: Text(
                                        "${grad.naziv ?? ""} (${grad.drzava?.naziv ?? ""})",
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedGradId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return "Odaberite grad";
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
                      label: Text(opstina == null ? "Spremi" : "Sačuvaj izmjene"),
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
                                  final provider = Provider.of<OpstinaProvider>(context, listen: false);
                                  if (opstina == null) {
                                    await provider.insert({
                                      "naziv": _inputController.text.trim(),
                                      "gradId": _selectedGradId,
                                    });
                                  } else {
                                    await provider.update(opstina.id, {
                                      "naziv": _inputController.text.trim(),
                                      "gradId": _selectedGradId,
                                    });
                                  }
                                  Navigator.of(context).pop(true);
                                } catch (e) {
                                  setState(() {
                                    _error = "Greška pri spremanju opštine.";
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

  Future<void> _tryDeleteOpstina(Opstina opstina) async {
    final provider = Provider.of<OpstinaProvider>(context, listen: false);
    bool canDelete = false;
    String? error;

    try {
      canDelete = await provider.canDelete(opstina.id);
    } catch (e) {
      error = "Greška pri provjeri mogućnosti brisanja.";
    }

    if (!canDelete) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Brisanje nije dozvoljeno"),
          content: Text(
            "Opština '${opstina.naziv ?? ''}' je povezana sa korisnicima ili tipovima izbora i ne može biti obrisana.",
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
          "Da li ste sigurni da želite obrisati '${opstina.naziv ?? ''}'?",
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
      await provider.delete(opstina.id);
      setState(() {}); // Refresh FutureBuilder
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Geografska administracija - Opštine",
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
                      labelText: "Pretraga po nazivu opštine",
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
                    controller: _gradNazivController,
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
                  label: const Text("Dodaj opštinu"),
                  onPressed: () => _showAddOpstinaDialog(),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Opstina>>(
                future: _fetchOpstine(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Greška pri učitavanju opština.",
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                  final opstine = snapshot.data ?? [];
                  if (opstine.isEmpty) {
                    return const Center(
                      child: Text(
                        "Nema opština.",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: opstine.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final opstina = opstine[index];
                      return GestureDetector(
                        onTap: () => _showOpstinaDetalji(opstina),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.map, color: Colors.blueAccent),
                            title: Text(
                              opstina.naziv ?? "Nepoznata opština",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              "Grad: ${opstina.grad?.naziv ?? ''} | Država: ${opstina.grad?.drzava?.naziv ?? ''}",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                  tooltip: "Uredi",
                                  onPressed: () => _showAddOpstinaDialog(opstina: opstina),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  tooltip: "Obriši",
                                  onPressed: () => _tryDeleteOpstina(opstina),
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