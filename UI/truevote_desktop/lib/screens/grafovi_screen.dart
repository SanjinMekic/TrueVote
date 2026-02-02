import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:truevote_desktop/layouts/master_screen.dart';
import 'package:truevote_desktop/providers/report_provider.dart';
import 'package:truevote_desktop/models/report.dart';

class GrafoviScreen extends StatefulWidget {
  GrafoviScreen({super.key});

  @override
  State<GrafoviScreen> createState() => _GrafoviScreenState();
}

class _GrafoviScreenState extends State<GrafoviScreen> {
  final GlobalKey _reportKey = GlobalKey();
  Report? _report;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<ReportProvider>(context, listen: false);
      final report = await provider.getSummary();
      setState(() {
        _report = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška pri dohvaćanju podataka: $e')),
        );
      });
    }
  }

  Future<Uint8List> _captureReport() async {
    final boundary = _reportKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _savePdfToDesktop(BuildContext context) async {
    try {
      final imageBytes = await _captureReport();
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
      final file = File("${desktopDir.path}\\report.pdf");
      await file.writeAsBytes(await doc.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF je sačuvan na Desktopu kao report.pdf')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška pri spremanju PDF-a: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = _report;
    return MasterScreen(
      "Pregled izvještaja",
      _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text("Spasi PDF"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blueAccent,
                      ),
                      onPressed: () => _savePdfToDesktop(context),
                    ),
                  ),
                  RepaintBoundary(
                    key: _reportKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        _SectionTitle("Struktura korisnika"),
                        SizedBox(
                          height: 220,
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: (report?.brojBiraca ?? 0).toDouble(),
                                  color: Colors.blueAccent,
                                  title: 'Birači\n${report?.brojBiraca ?? 0}',
                                  radius: 60,
                                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                PieChartSectionData(
                                  value: (report?.brojAdmina ?? 0).toDouble(),
                                  color: Colors.green,
                                  title: 'Admini\n${report?.brojAdmina ?? 0}',
                                  radius: 60,
                                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                PieChartSectionData(
                                  value: ((report?.brojKorisnika ?? 0) - (report?.brojBiraca ?? 0) - (report?.brojAdmina ?? 0)).toDouble(),
                                  color: Colors.orange,
                                  title: 'Ostali\n${((report?.brojKorisnika ?? 0) - (report?.brojBiraca ?? 0) - (report?.brojAdmina ?? 0))}',
                                  radius: 60,
                                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                              sectionsSpace: 4,
                              centerSpaceRadius: 30,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _SectionTitle("Poređenje broja admina i korisnika"),
                        SizedBox(
                          height: 180,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              barTouchData: BarTouchData(enabled: true),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      switch (value.toInt()) {
                                        case 0:
                                          return const Text('Admini');
                                        case 1:
                                          return const Text('Korisnici');
                                        default:
                                          return const Text('');
                                      }
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
                              barGroups: [
                                BarChartGroupData(x: 0, barRods: [
                                  BarChartRodData(
                                    toY: (report?.brojAdmina ?? 0).toDouble(),
                                    color: Colors.green,
                                    width: 28,
                                  ),
                                ]),
                                BarChartGroupData(x: 1, barRods: [
                                  BarChartRodData(
                                    toY: (report?.brojKorisnika ?? 0).toDouble(),
                                    color: Colors.blueAccent,
                                    width: 28,
                                  ),
                                ]),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _SectionTitle("Poređenje broja gradova i opština"),
                        SizedBox(
                          height: 180,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              barTouchData: BarTouchData(enabled: true),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      switch (value.toInt()) {
                                        case 0:
                                          return const Text('Gradovi');
                                        case 1:
                                          return const Text('Opštine');
                                        default:
                                          return const Text('');
                                      }
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
                              barGroups: [
                                BarChartGroupData(x: 0, barRods: [
                                  BarChartRodData(
                                    toY: (report?.brojGradova ?? 0).toDouble(),
                                    color: Colors.indigo,
                                    width: 28,
                                  ),
                                ]),
                                BarChartGroupData(x: 1, barRods: [
                                  BarChartRodData(
                                    toY: (report?.brojOpstina ?? 0).toDouble(),
                                    color: Colors.orange,
                                    width: 28,
                                  ),
                                ]),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _SectionTitle("Poređenje broja stranaka i kandidata"),
                        SizedBox(
                          height: 180,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              barTouchData: BarTouchData(enabled: true),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      switch (value.toInt()) {
                                        case 0:
                                          return const Text('Stranke');
                                        case 1:
                                          return const Text('Kandidati');
                                        default:
                                          return const Text('');
                                      }
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
                              barGroups: [
                                BarChartGroupData(x: 0, barRods: [
                                  BarChartRodData(
                                    toY: (report?.brojStranaka ?? 0).toDouble(),
                                    color: Colors.purple,
                                    width: 28,
                                  ),
                                ]),
                                BarChartGroupData(x: 1, barRods: [
                                  BarChartRodData(
                                    toY: (report?.brojKandidata ?? 0).toDouble(),
                                    color: Colors.redAccent,
                                    width: 28,
                                  ),
                                ]),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _SectionTitle("FAQ pitanja"),
                        SizedBox(
                          height: 220,
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: (report?.brojFaqPitanja ?? 0).toDouble(),
                                  color: Colors.deepPurple,
                                  title: 'FAQ pitanja\n${report?.brojFaqPitanja ?? 0}',
                                  radius: 80,
                                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                              sectionsSpace: 0,
                              centerSpaceRadius: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _SectionTitle("Pregled svih entiteta"),
                        SizedBox(
                          height: 300,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              barTouchData: BarTouchData(enabled: true),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      switch (value.toInt()) {
                                        case 0:
                                          return const Text('Države', style: TextStyle(fontSize: 12));
                                        case 1:
                                          return const Text('Gradovi', style: TextStyle(fontSize: 12));
                                        case 2:
                                          return const Text('Opštine', style: TextStyle(fontSize: 12));
                                        case 3:
                                          return const Text('Stranke', style: TextStyle(fontSize: 12));
                                        case 4:
                                          return const Text('Korisnici', style: TextStyle(fontSize: 12));
                                        case 5:
                                          return const Text('Kandidati', style: TextStyle(fontSize: 12));
                                        case 6:
                                          return const Text('Izbori', style: TextStyle(fontSize: 12));
                                        case 7:
                                          return const Text('FAQ', style: TextStyle(fontSize: 12));
                                        default:
                                          return const Text('');
                                      }
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
                              barGroups: [
                                BarChartGroupData(x: 0, barRods: [
                                  BarChartRodData(
                                    toY: (report?.brojDrzava ?? 0).toDouble(),
                                    color: Colors.blueAccent,
                                    width: 18,
                                  ),
                                ]),
                                BarChartGroupData(x: 1, barRods: [
                                  BarChartRodData(
                                    toY: (report?.brojGradova ?? 0).toDouble(),
                                    color: Colors.green,
                                    width: 18,
                                  ),
                                ]),
                                BarChartGroupData(x: 2, barRods: [
                                  BarChartRodData(
                                    toY: (report?.brojOpstina ?? 0).toDouble(),
                                    color: Colors.orange,
                                    width: 18,
                                  ),
                                ]),
                                BarChartGroupData(x: 3, barRods: [
                                  BarChartRodData(
                                    toY: (report?.brojStranaka ?? 0).toDouble(),
                                    color: Colors.purple,
                                    width: 18,
                                  ),
                                ]),
                                BarChartGroupData(x: 4, barRods: [
                                  BarChartRodData(
                                    toY: (report?.brojKorisnika ?? 0).toDouble(),
                                    color: Colors.teal,
                                    width: 18,
                                  ),
                                ]),
                                BarChartGroupData(x: 5, barRods: [
                                  BarChartRodData(
                                    toY: (report?.brojKandidata ?? 0).toDouble(),
                                    color: Colors.redAccent,
                                    width: 18,
                                  ),
                                ]),
                                BarChartGroupData(x: 6, barRods: [
                                  BarChartRodData(
                                    toY: (report?.brojIzbora ?? 0).toDouble(),
                                    color: Colors.indigo,
                                    width: 18,
                                  ),
                                ]),
                                BarChartGroupData(x: 7, barRods: [
                                  BarChartRodData(
                                    toY: (report?.brojFaqPitanja ?? 0).toDouble(),
                                    color: Colors.brown,
                                    width: 18,
                                  ),
                                ]),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _SectionTitle("Detaljna statistika"),
                        Card(
                          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Table(
                              columnWidths: const {
                                0: FlexColumnWidth(2),
                                1: FlexColumnWidth(1),
                              },
                              children: [
                                _buildTableRow("Broj država", report?.brojDrzava),
                                _buildTableRow("Broj gradova", report?.brojGradova),
                                _buildTableRow("Broj opština", report?.brojOpstina),
                                _buildTableRow("Broj stranaka", report?.brojStranaka),
                                _buildTableRow("Broj korisnika", report?.brojKorisnika),
                                _buildTableRow("Broj birača", report?.brojBiraca),
                                _buildTableRow("Broj admina", report?.brojAdmina),
                                _buildTableRow("Broj kandidata", report?.brojKandidata),
                                _buildTableRow("Broj izbora", report?.brojIzbora),
                                _buildTableRow("Broj FAQ pitanja", report?.brojFaqPitanja),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  TableRow _buildTableRow(String label, int? value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(value?.toString() ?? "-", textAlign: TextAlign.right),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
        textAlign: TextAlign.center,
      ),
    );
  }
}