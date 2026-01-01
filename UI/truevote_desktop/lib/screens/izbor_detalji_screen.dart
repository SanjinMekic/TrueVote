import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:truevote_desktop/models/izbor.dart';
import 'package:truevote_desktop/providers/izbor_provider.dart';
import 'package:truevote_desktop/providers/glas_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';

class IzborDetaljiScreen extends StatefulWidget {
  final Izbor izbor;
  const IzborDetaljiScreen({super.key, required this.izbor});

  @override
  State<IzborDetaljiScreen> createState() => _IzborDetaljiScreenState();
}

class _IzborDetaljiScreenState extends State<IzborDetaljiScreen> {
  late Future<List<dynamic>> _kandidatiFuture;
  final GlobalKey _chartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _kandidatiFuture = Provider.of<IzborProvider>(
      context,
      listen: false,
    ).getKandidatiByIzbor(widget.izbor.id);
  }

  Widget _buildIzborInfo(Izbor izbor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          izbor.tipIzbora?.naziv ?? "Nepoznat tip izbora",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on, color: Colors.blueAccent.shade100),
            const SizedBox(width: 8),
            Text(
              "Opština: ${izbor.tipIzbora?.opstina?.naziv ?? '-'} | Grad: ${izbor.tipIzbora?.opstina?.grad?.naziv ?? '-'} | Država: ${izbor.tipIzbora?.opstina?.grad?.drzava?.naziv ?? '-'}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.blueAccent.shade100),
            const SizedBox(width: 8),
            Text(
              "Datum: ${izbor.datumPocetka != null ? DateFormat('dd.MM.yyyy HH:mm').format(izbor.datumPocetka!) : '-'}"
              " - ${izbor.datumKraja != null ? DateFormat('dd.MM.yyyy HH:mm').format(izbor.datumKraja!) : '-'}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blueAccent.shade100),
            const SizedBox(width: 8),
            Text(
              "Status: ${izbor.status ?? '-'}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKandidatCard(dynamic kandidat) {
    final stranka = kandidat['stranka'];
    Widget slikaWidget;
    if (kandidat['slika'] != null && kandidat['slika'].toString().isNotEmpty) {
      try {
        final bytes = base64Decode(kandidat['slika']);
        slikaWidget = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(bytes, width: 70, height: 70, fit: BoxFit.cover),
        );
      } catch (_) {
        slikaWidget = _defaultAvatar();
      }
    } else {
      slikaWidget = _defaultAvatar();
    }

    Widget logoWidget;
    if (stranka != null &&
        stranka['logo'] != null &&
        stranka['logo'].toString().isNotEmpty &&
        stranka['logo'] != "System.Byte[]") {
      try {
        final bytes = base64Decode(stranka['logo']);
        logoWidget = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(bytes, width: 40, height: 40, fit: BoxFit.cover),
        );
      } catch (_) {
        logoWidget = _defaultLogo();
      }
    } else {
      logoWidget = _defaultLogo();
    }

    return FutureBuilder<int>(
      future: Provider.of<GlasProvider>(
        context,
        listen: false,
      ).getBrojGlasovaZaKandidata(kandidat['id']),
      builder: (context, snapshot) {
        final brojGlasova = snapshot.hasData ? snapshot.data : null;
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                slikaWidget,
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "${kandidat['ime'] ?? ''} ${kandidat['prezime'] ?? ''}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                          if (brojGlasova != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.how_to_vote,
                                    size: 18,
                                    color: Colors.blueAccent,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Broj glasova: $brojGlasova",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (stranka != null)
                        Row(
                          children: [
                            logoWidget,
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                stranka['naziv'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (stranka != null &&
                          stranka['opis'] != null &&
                          stranka['opis'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            stranka['opis'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (stranka != null)
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            if (stranka['datumOsnivanja'] != null)
                              Chip(
                                avatar: const Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: Colors.blueAccent,
                                ),
                                label: Text(
                                  DateFormat('dd.MM.yyyy.').format(
                                    DateTime.parse(stranka['datumOsnivanja']),
                                  ),
                                  style: const TextStyle(fontSize: 13),
                                ),
                                backgroundColor: Colors.blueAccent.withOpacity(
                                  0.08,
                                ),
                              ),
                            if (stranka['brojClanova'] != null)
                              Chip(
                                avatar: const Icon(
                                  Icons.people,
                                  size: 18,
                                  color: Colors.blueAccent,
                                ),
                                label: Text(
                                  "${stranka['brojClanova']} članova",
                                  style: const TextStyle(fontSize: 13),
                                ),
                                backgroundColor: Colors.blueAccent.withOpacity(
                                  0.08,
                                ),
                              ),
                            if (stranka['sjediste'] != null &&
                                stranka['sjediste'].toString().isNotEmpty)
                              Chip(
                                avatar: const Icon(
                                  Icons.location_on,
                                  size: 18,
                                  color: Colors.blueAccent,
                                ),
                                label: Text(
                                  stranka['sjediste'],
                                  style: const TextStyle(fontSize: 13),
                                ),
                                backgroundColor: Colors.blueAccent.withOpacity(
                                  0.08,
                                ),
                              ),
                            if (stranka['webUrl'] != null &&
                                stranka['webUrl'].toString().isNotEmpty)
                              ActionChip(
                                avatar: const Icon(
                                  Icons.link,
                                  size: 18,
                                  color: Colors.blueAccent,
                                ),
                                label: SizedBox(
                                  width: 100,
                                  child: Text(
                                    stranka['webUrl'],
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.blueAccent,
                                      decoration: TextDecoration.underline,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                onPressed: () async {
                                  final url = Uri.parse(stranka['webUrl']);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                },
                                backgroundColor: Colors.blueAccent.withOpacity(
                                  0.08,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _defaultAvatar() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.person, color: Colors.blueAccent, size: 40),
    );
  }

  Widget _defaultLogo() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.how_to_vote, color: Colors.blueAccent, size: 24),
    );
  }

  Color _generateColor(int idx, int total) {
    final hue = (idx * 360 / total) % 360;
    return HSVColor.fromAHSV(1, hue, 0.7, 0.85).toColor();
  }

  Widget _buildBarChart(
    List<dynamic> kandidati,
    Map<int, int> glasovi,
    double width,
  ) {
    if (kandidati.isEmpty) {
      return const SizedBox();
    }

    final maxGlasova = glasovi.values.isNotEmpty
        ? glasovi.values.reduce((a, b) => a > b ? a : b)
        : 1;

    return RepaintBoundary(
      key: _chartKey,
      child: Card(
        elevation: 6,
        margin: const EdgeInsets.only(top: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informacije o izboru iznad grafa
              _buildIzborInfo(widget.izbor),
              const SizedBox(height: 18),
              const Text(
                "Poređenje kandidata po broju glasova",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 16),
              // Legenda iznad grafa
              Wrap(
                spacing: 18,
                runSpacing: 8,
                children: List.generate(kandidati.length, (idx) {
                  final kandidat = kandidati[idx];
                  final ime = (kandidat['ime'] ?? '').toString();
                  final prezime = (kandidat['prezime'] ?? '').toString();
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: _generateColor(idx, kandidati.length),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "$ime $prezime",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: width,
                height: 360,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (maxGlasova + 2).toDouble(),
                    minY: 0,
                    barTouchData: BarTouchData(enabled: true),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) =>
                          FlLine(color: Colors.grey.shade300, strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            // Prikazuj samo cijele brojeve
                            if (value % 1 != 0) return const SizedBox();
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 13),
                            );
                          },
                          interval: 1,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= kandidati.length)
                              return const SizedBox();
                            final kandidat = kandidati[idx];
                            final prezime = (kandidat['prezime'] ?? '')
                                .toString();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                prezime,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(kandidati.length, (idx) {
                      final kandidat = kandidati[idx];
                      final broj = glasovi[kandidat['id']] ?? 0;
                      return BarChartGroupData(
                        x: idx,
                        barRods: [
                          BarChartRodData(
                            toY: broj.toDouble(),
                            color: _generateColor(idx, kandidati.length),
                            width: 28,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<int, int>> _fetchGlasoviZaKandidate(
    List<dynamic> kandidati,
  ) async {
    final glasProvider = Provider.of<GlasProvider>(context, listen: false);
    Map<int, int> glasovi = {};
    for (final kandidat in kandidati) {
      final id = kandidat['id'];
      try {
        final broj = await glasProvider.getBrojGlasovaZaKandidata(id);
        glasovi[id] = broj;
      } catch (_) {
        glasovi[id] = 0;
      }
    }
    return glasovi;
  }

  Future<Uint8List> _captureChart() async {
    final boundary = _chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _saveChartToDesktop(BuildContext context) async {
    try {
      final imageBytes = await _captureChart();
      final doc = pw.Document();
      final image = pw.MemoryImage(imageBytes);

      doc.addPage(
        pw.Page(
          build: (context) => pw.Center(child: pw.Image(image)),
        ),
      );

      final desktopDir = Directory(
        "${(await getApplicationDocumentsDirectory()).parent.path}\\Desktop",
      );
      final file = File("${desktopDir.path}\\izbor_graf.pdf");
      await file.writeAsBytes(await doc.save());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF je sačuvan na Desktopu kao izbor_graf.pdf')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška pri spremanju PDF-a: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detalji izbora",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 8,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            tooltip: "Spasi graf kao PDF",
            onPressed: () => _saveChartToDesktop(context),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF2F6FF),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Kandidati",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<dynamic>>(
                future: _kandidatiFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blueAccent,
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Greška pri učitavanju kandidata.",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  final kandidati = snapshot.data ?? [];
                  if (kandidati.isEmpty) {
                    return const Center(
                      child: Text(
                        "Nema kandidata za ovaj izbor.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      // Ako ima puno kandidata, neka svaki ima min 70px širine
                      final minWidth = kandidati.length * 70.0;
                      final width = constraints.maxWidth > minWidth
                          ? constraints.maxWidth
                          : minWidth;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: kandidati.length,
                            itemBuilder: (context, index) =>
                                _buildKandidatCard(kandidati[index]),
                          ),
                          FutureBuilder<Map<int, int>>(
                            future: _fetchGlasoviZaKandidate(kandidati),
                            builder: (context, glasSnapshot) {
                              if (glasSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Padding(
                                  padding: EdgeInsets.only(top: 32.0),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                );
                              }
                              if (glasSnapshot.hasError) {
                                return const Padding(
                                  padding: EdgeInsets.only(top: 32.0),
                                  child: Center(
                                    child: Text(
                                      "Greška pri učitavanju glasova.",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: _buildBarChart(
                                  kandidati,
                                  glasSnapshot.data ?? {},
                                  width,
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}