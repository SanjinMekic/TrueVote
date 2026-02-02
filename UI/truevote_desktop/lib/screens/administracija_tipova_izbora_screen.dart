import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:truevote_desktop/layouts/master_screen.dart';
import 'package:truevote_desktop/providers/tip_izbora_provider.dart';
import 'package:truevote_desktop/providers/opstina_provider.dart';
import 'package:truevote_desktop/models/tip_izbora.dart';
import 'package:truevote_desktop/models/opstina.dart';

class AdministracijaTipovaIzboraScreen extends StatefulWidget {
  const AdministracijaTipovaIzboraScreen({super.key});

  @override
  State<AdministracijaTipovaIzboraScreen> createState() => _AdministracijaTipovaIzboraScreenState();
}

class _AdministracijaTipovaIzboraScreenState extends State<AdministracijaTipovaIzboraScreen> {
  Future<List<TipIzbora>> _fetchTipoviIzbora() async {
    final provider = Provider.of<TipIzboraProvider>(context, listen: false);
    final result = await provider.get();
    return result.result;
  }

  Future<List<Opstina>> _fetchOpstine() async {
    final provider = Provider.of<OpstinaProvider>(context, listen: false);
    final result = await provider.get();
    return result.result;
  }

  Future<void> _showTipIzboraDialog({TipIzbora? tipIzbora}) async {
    final _formKey = GlobalKey<FormState>();
    final _nazivController = TextEditingController(text: tipIzbora?.naziv ?? "");
    bool _dozvoljenoViseGlasova = tipIzbora?.dozvoljenoViseGlasova ?? false;
    int _maxBrojGlasova = tipIzbora?.maxBrojGlasova ?? 1;
    int? _selectedOpstinaId = tipIzbora?.opstinaId;
    bool _isLoading = false;
    String? _error;

    List<Opstina> _opstine = await _fetchOpstine();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                    child: const Icon(Icons.how_to_vote, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      tipIzbora == null ? "Dodaj tip izbora" : "Uredi tip izbora",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _nazivController,
                          decoration: InputDecoration(
                            labelText: "Naziv tipa izbora",
                            prefixIcon: const Icon(Icons.how_to_vote),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF2F6FF),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Unesite naziv tipa izbora";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: _selectedOpstinaId,
                                decoration: InputDecoration(
                                  labelText: "Opština",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF2F6FF),
                                ),
                                items: _opstine
                                    .map((opstina) => DropdownMenuItem<int>(
                                          value: opstina.id,
                                          child: Text(
                                            "${opstina.naziv ?? ""} (${opstina.grad?.naziv ?? ""}, ${opstina.grad?.drzava?.naziv ?? ""})",
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedOpstinaId = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return "Odaberite opštinu";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: _dozvoljenoViseGlasova,
                              onChanged: (value) {
                                setState(() {
                                  _dozvoljenoViseGlasova = value ?? false;
                                  if (!_dozvoljenoViseGlasova) {
                                    _maxBrojGlasova = 1;
                                  }
                                });
                              },
                            ),
                            const Text("Dozvoljeno više glasova"),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          enabled: _dozvoljenoViseGlasova,
                          initialValue: _maxBrojGlasova.toString(),
                          decoration: InputDecoration(
                            labelText: "Max broj glasova",
                            prefixIcon: const Icon(Icons.numbers),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF2F6FF),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (_dozvoljenoViseGlasova) {
                              final broj = int.tryParse(value ?? "");
                              if (broj == null || broj < 2) {
                                return "Unesite broj veći od 1";
                              }
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _maxBrojGlasova = int.tryParse(value) ?? 1;
                            });
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
                  label: Text(tipIzbora == null ? "Spremi" : "Sačuvaj izmjene"),
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
                              final provider = Provider.of<TipIzboraProvider>(context, listen: false);
                              final data = {
                                "naziv": _nazivController.text.trim(),
                                "dozvoljenoViseGlasova": _dozvoljenoViseGlasova,
                                "maxBrojGlasova": _dozvoljenoViseGlasova ? _maxBrojGlasova : 1,
                                "opstinaId": _selectedOpstinaId,
                              };
                              if (tipIzbora == null) {
                                await provider.insert(data);
                              } else {
                                await provider.update(tipIzbora.id, data);
                              }
                              Navigator.of(context).pop(true);
                            } catch (e) {
                              setState(() {
                                _error = "Greška pri spremanju tipa izbora.";
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
    setState(() {});
  }

  Future<void> _tryDeleteTipIzbora(TipIzbora tip) async {
    final provider = Provider.of<TipIzboraProvider>(context, listen: false);
    bool canDelete = false;
    String? error;

    try {
      canDelete = await provider.canDelete(tip.id);
    } catch (e) {
      error = "Greška pri provjeri mogućnosti brisanja.";
    }

    if (!canDelete) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Brisanje nije dozvoljeno"),
          content: Text(
            "Tip izbora '${tip.naziv ?? ''}' je povezan sa izborima i ne može biti obrisan.",
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
          "Da li ste sigurni da želite obrisati '${tip.naziv ?? ''}'?",
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
      await provider.delete(tip.id);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Administracija tipova izbora",
      Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Dodaj tip izbora"),
                  onPressed: () => _showTipIzboraDialog(),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<TipIzbora>>(
                future: _fetchTipoviIzbora(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Greška pri učitavanju tipova izbora.",
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                  final tipovi = snapshot.data ?? [];
                  if (tipovi.isEmpty) {
                    return const Center(
                      child: Text(
                        "Nema tipova izbora.",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: tipovi.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final tip = tipovi[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.how_to_vote, color: Colors.blueAccent),
                          title: Text(
                            tip.naziv ?? "Nepoznat tip izbora",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            "Opština: ${tip.opstina?.naziv ?? ''} | Grad: ${tip.opstina?.grad?.naziv ?? ''} | Država: ${tip.opstina?.grad?.drzava?.naziv ?? ''}\n"
                            "Dozvoljeno više glasova: ${tip.dozvoljenoViseGlasova == true ? "Da" : "Ne"}"
                            "${tip.dozvoljenoViseGlasova == true ? "\nMax broj glasova: ${tip.maxBrojGlasova}" : ""}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                tooltip: "Uredi",
                                onPressed: () => _showTipIzboraDialog(tipIzbora: tip),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                tooltip: "Obriši",
                                onPressed: () => _tryDeleteTipIzbora(tip),
                              ),
                            ],
                          ),
                          tileColor: const Color(0xFFF2F6FF),
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