import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:truevote_desktop/layouts/master_screen.dart';
import 'package:truevote_desktop/models/izbor.dart';
import 'package:truevote_desktop/providers/izbor_provider.dart';

class PocetnaScreen extends StatefulWidget {
  const PocetnaScreen({super.key});

  @override
  State<PocetnaScreen> createState() => _PocetnaScreenState();
}

class _PocetnaScreenState extends State<PocetnaScreen> {
  String _status = "U toku";
  bool _isLoading = true;
  List<Izbor> _izbori = [];

  @override
  void initState() {
    super.initState();
    _loadIzbori();
  }

  Future<void> _loadIzbori() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<IzborProvider>(context, listen: false);
    final result = await provider.get();
    setState(() {
      _izbori = result.result;
      _isLoading = false;
    });
  }

  List<Izbor> get _filteredIzbori {
    return _izbori.where((i) => i.status == _status).toList();
  }

  Widget _buildStatusButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _statusButton("U toku", Icons.play_arrow),
        const SizedBox(width: 16),
        _statusButton("Planiran", Icons.schedule),
        const SizedBox(width: 16),
        _statusButton("Završen", Icons.check_circle),
      ],
    );
  }

  Widget _statusButton(String status, IconData icon) {
    final isSelected = _status == status;
    return ElevatedButton.icon(
      icon: Icon(icon, color: isSelected ? Colors.white : Colors.blueAccent),
      label: Text(
        status,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : Colors.blueAccent,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blueAccent : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.blueAccent,
        side: BorderSide(color: Colors.blueAccent, width: 2),
        elevation: isSelected ? 6 : 2,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        if (_status != status) {
          setState(() {
            _status = status;
          });
        }
      },
    );
  }

  Widget _buildIzborCard(Izbor izbor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFF2F6FF),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      "Početna",
      Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildStatusButtons(),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                  : _filteredIzbori.isEmpty
                      ? const Center(child: Text("Nema izbora za prikaz.", style: TextStyle(fontSize: 18, color: Colors.grey)))
                      : ListView.separated(
                          itemCount: _filteredIzbori.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) => _buildIzborCard(_filteredIzbori[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}