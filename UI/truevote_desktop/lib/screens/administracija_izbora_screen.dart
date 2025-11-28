import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:truevote_desktop/layouts/master_screen.dart';
import 'package:truevote_desktop/providers/izbor_provider.dart';
import 'package:truevote_desktop/providers/tip_izbora_provider.dart';
import 'package:truevote_desktop/models/izbor.dart';
import 'package:truevote_desktop/models/tip_izbora.dart';

class AdministracijaIzboraScreen extends StatefulWidget {
  const AdministracijaIzboraScreen({super.key});

  @override
  State<AdministracijaIzboraScreen> createState() => _AdministracijaIzboraScreenState();
}

class _AdministracijaIzboraScreenState extends State<AdministracijaIzboraScreen> {
  String? _statusFilter;
  DateTime? _datumPocetkaFilter;
  DateTime? _datumKrajaFilter;

  Future<List<Izbor>> _fetchIzbori() async {
    final provider = Provider.of<IzborProvider>(context, listen: false);
    final result = await provider.get(
      filter: {
        if (_statusFilter != null && _statusFilter!.isNotEmpty) "status": _statusFilter,
        if (_datumPocetkaFilter != null) "datumPocetka": DateFormat('yyyy-MM-dd').format(_datumPocetkaFilter!),
        if (_datumKrajaFilter != null) "datumKraja": DateFormat('yyyy-MM-dd').format(_datumKrajaFilter!),
      },
    );
    return result.result;
  }

  Future<List<TipIzbora>> _fetchTipoviIzbora() async {
    final provider = Provider.of<TipIzboraProvider>(context, listen: false);
    final result = await provider.get();
    return result.result;
  }

  Future<void> _showIzborDialog({Izbor? izbor}) async {
    final _formKey = GlobalKey<FormState>();
    TipIzbora? _selectedTipIzbora = izbor?.tipIzbora;
    int? _selectedTipIzboraId = izbor?.tipIzboraId;
    DateTime? _datumPocetka = izbor?.datumPocetka;
    DateTime? _datumKraja = izbor?.datumKraja;
    String _status = izbor?.status ?? "";
    bool _isLoading = false;
    String? _error;

    List<TipIzbora> _tipoviIzbora = await _fetchTipoviIzbora();

    DateTime today = DateTime.now();
    DateTime todayDate = DateTime(today.year, today.month, today.day);
    DateTime minPocetniDatum = todayDate.add(const Duration(days: 2)); // 2 dana poslije danas

    String _calculateStatus(DateTime? datumPocetka) {
      if (datumPocetka == null) return "";
      DateTime pocetakDate = DateTime(datumPocetka.year, datumPocetka.month, datumPocetka.day);
      if (pocetakDate.isAtSameMomentAs(todayDate)) {
        return "U toku";
      } else if (pocetakDate.isAfter(todayDate)) {
        return "Planiran";
      } else {
        return "Završen";
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            _status = _calculateStatus(_datumPocetka);

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
                      izbor == null ? "Dodaj izbor" : "Uredi izbor",
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
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: _selectedTipIzboraId,
                                decoration: InputDecoration(
                                  labelText: "Tip izbora",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF2F6FF),
                                ),
                                items: _tipoviIzbora
                                    .map((tip) => DropdownMenuItem<int>(
                                          value: tip.id,
                                          child: Text(
                                            "${tip.naziv ?? ""} (${tip.opstina?.naziv ?? ""}, ${tip.opstina?.grad?.naziv ?? ""})",
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedTipIzboraId = value;
                                    _selectedTipIzbora = _tipoviIzbora.firstWhere((t) => t.id == value);
                                    _error = null;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return "Odaberite tip izbora";
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
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: _datumPocetka ?? minPocetniDatum,
                                    firstDate: minPocetniDatum,
                                    lastDate: DateTime(2100),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      _datumPocetka = picked;
                                      _error = null;
                                      if (_datumKraja != null && _datumKraja!.isBefore(picked)) {
                                        _datumKraja = null;
                                      }
                                    });
                                  }
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: "Datum početka",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF2F6FF),
                                  ),
                                  child: Text(
                                    _datumPocetka != null
                                        ? DateFormat('dd.MM.yyyy').format(_datumPocetka!)
                                        : "Odaberite datum",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AbsorbPointer(
                                absorbing: _datumPocetka == null,
                                child: Opacity(
                                  opacity: _datumPocetka == null ? 0.5 : 1.0,
                                  child: InkWell(
                                    onTap: _datumPocetka == null
                                        ? null
                                        : () async {
                                            final picked = await showDatePicker(
                                              context: context,
                                              initialDate: _datumKraja ?? _datumPocetka!,
                                              firstDate: _datumPocetka!,
                                              lastDate: DateTime(2100),
                                            );
                                            if (picked != null) {
                                              setState(() {
                                                _datumKraja = picked;
                                                _error = null;
                                              });
                                            }
                                          },
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: "Datum kraja",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFFF2F6FF),
                                      ),
                                      child: Text(
                                        _datumKraja != null
                                            ? DateFormat('dd.MM.yyyy').format(_datumKraja!)
                                            : "Odaberite datum",
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.blueAccent),
                            const SizedBox(width: 8),
                            Text(
                              "Status: $_status",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
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
                  label: Text(izbor == null ? "Spremi" : "Sačuvaj izmjene"),
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
                            if (_datumPocetka == null || _datumKraja == null) {
                              setState(() {
                                _error = "Morate odabrati oba datuma.";
                              });
                              return;
                            }
                            if (_datumPocetka!.isBefore(minPocetniDatum)) {
                              setState(() {
                                _error = "Datum početka mora biti najmanje 2 dana nakon današnjeg datuma.";
                              });
                              return;
                            }
                            if (_datumKraja!.isBefore(_datumPocetka!)) {
                              setState(() {
                                _error = "Datum kraja ne može biti prije datuma početka.";
                              });
                              return;
                            }
                            setState(() {
                              _isLoading = true;
                              _error = null;
                            });
                            try {
                              final provider = Provider.of<IzborProvider>(context, listen: false);
                              final data = {
                                "tipIzboraId": _selectedTipIzboraId,
                                "datumPocetka": _datumPocetka?.toIso8601String(),
                                "datumKraja": _datumKraja?.toIso8601String(),
                                "status": _calculateStatus(_datumPocetka),
                              };
                              if (izbor == null) {
                                await provider.insert(data);
                              } else {
                                await provider.update(izbor.id, data);
                              }
                              Navigator.of(context).pop(true);
                            } catch (e) {
                              setState(() {
                                _error = "U bazi postoji izbor ovog tipa u istom vremenskom periodu.";
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
    setState(() {}); // Refresh FutureBuilder
  }

  Future<void> _showFilterDialog() async {
    String? status = _statusFilter;
    DateTime? datumPocetka = _datumPocetkaFilter;
    DateTime? datumKraja = _datumKrajaFilter;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Filtriraj izbore"),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: status,
                      decoration: const InputDecoration(
                        labelText: "Status",
                        prefixIcon: Icon(Icons.info_outline),
                      ),
                      onChanged: (value) {
                        status = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: datumPocetka ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() {
                                  datumPocetka = picked;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: "Datum početka",
                                filled: true,
                              ),
                              child: Text(
                                datumPocetka != null
                                    ? DateFormat('dd.MM.yyyy').format(datumPocetka!)
                                    : "Odaberite datum",
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: datumKraja ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() {
                                  datumKraja = picked;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: "Datum kraja",
                                filled: true,
                              ),
                              child: Text(
                                datumKraja != null
                                    ? DateFormat('dd.MM.yyyy').format(datumKraja!)
                                    : "Odaberite datum",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Otkaži"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _statusFilter = status;
                      _datumPocetkaFilter = datumPocetka;
                      _datumKrajaFilter = datumKraja;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text("Primijeni"),
                ),
              ],
            );
          },
        );
      },
    );
    setState(() {});
  }

  void _clearFilters() {
    setState(() {
      _statusFilter = null;
      _datumPocetkaFilter = null;
      _datumKrajaFilter = null;
    });
  }

  Future<void> _tryDeleteIzbor(Izbor izbor) async {
    final provider = Provider.of<IzborProvider>(context, listen: false);
    bool canDelete = false;
    String? error;

    try {
      canDelete = await provider.canDelete(izbor.id);
    } catch (e) {
      error = "Greška pri provjeri mogućnosti brisanja.";
    }

    if (!canDelete) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Brisanje nije dozvoljeno"),
          content: Text(
            "Izbor je povezan sa kandidatima ili ima glasove i ne može biti obrisan.",
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
          "Da li ste sigurni da želite obrisati izbor za '${izbor.tipIzbora?.naziv ?? ''}'?",
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
      await provider.delete(izbor.id);
      setState(() {}); // Refresh FutureBuilder
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Administracija izbora",
      Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.filter_alt),
                  label: const Text("Filtriraj"),
                  onPressed: _showFilterDialog,
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.clear),
                  label: const Text("Očisti filter"),
                  onPressed: _clearFilters,
                ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Dodaj izbor"),
                  onPressed: () => _showIzborDialog(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Izbor>>(
                future: _fetchIzbori(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Greška pri učitavanju izbora.",
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                  final izbori = snapshot.data ?? [];
                  if (izbori.isEmpty) {
                    return const Center(
                      child: Text(
                        "Nema izbora.",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: izbori.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final izbor = izbori[index];
                      final isPlaniran = izbor.status == "Planiran";
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.how_to_vote, color: Colors.blueAccent),
                          title: Text(
                            izbor.tipIzbora?.naziv ?? "Nepoznat tip izbora",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            "Opština: ${izbor.tipIzbora?.opstina?.naziv ?? ''} | Grad: ${izbor.tipIzbora?.opstina?.grad?.naziv ?? ''} | Država: ${izbor.tipIzbora?.opstina?.grad?.drzava?.naziv ?? ''}\n"
                            "Datum: ${izbor.datumPocetka != null ? DateFormat('dd.MM.yyyy HH:mm').format(izbor.datumPocetka!) : '-'}"
                            " - ${izbor.datumKraja != null ? DateFormat('dd.MM.yyyy HH:mm').format(izbor.datumKraja!) : '-'}\n"
                            "Status: ${izbor.status ?? '-'}",
                          ),
                          trailing: isPlaniran
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                      tooltip: "Uredi",
                                      onPressed: () => _showIzborDialog(izbor: izbor),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                                      tooltip: "Obriši",
                                      onPressed: () => _tryDeleteIzbor(izbor),
                                    ),
                                  ],
                                )
                              : null,
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