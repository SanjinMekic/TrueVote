import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:truevote_desktop/layouts/master_screen.dart';

class GrafoviScreen extends StatelessWidget {
  GrafoviScreen({super.key});

  final GlobalKey _reportKey = GlobalKey();

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

      // Get desktop path
      final desktopDir = Directory(
        "${(await getApplicationDocumentsDirectory()).parent.path}\\Desktop",
      );
      final file = File("${desktopDir.path}\\report.pdf");
      await file.writeAsBytes(await doc.save());

      // Show info
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
    return MasterScreen(
      "Pregled grafova",
      SingleChildScrollView(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("Spasi PDF"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blueAccent),
                onPressed: () => _savePdfToDesktop(context),
              ),
            ),
            RepaintBoundary(
              key: _reportKey,
              child: Column(
                children: [
                  const Text(
                    "Bar Chart - Broj glasova po kandidatima",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
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
                                    return const Text('A');
                                  case 1:
                                    return const Text('B');
                                  case 2:
                                    return const Text('C');
                                  case 3:
                                    return const Text('D');
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
                            BarChartRodData(toY: 8, color: Colors.blueAccent, width: 22),
                          ]),
                          BarChartGroupData(x: 1, barRods: [
                            BarChartRodData(toY: 12, color: Colors.green, width: 22),
                          ]),
                          BarChartGroupData(x: 2, barRods: [
                            BarChartRodData(toY: 5, color: Colors.orange, width: 22),
                          ]),
                          BarChartGroupData(x: 3, barRods: [
                            BarChartRodData(toY: 15, color: Colors.redAccent, width: 22),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Pie Chart - Procentualni udio glasova",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: 40,
                            color: Colors.blueAccent,
                            title: 'A (40%)',
                            radius: 60,
                            titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          PieChartSectionData(
                            value: 30,
                            color: Colors.green,
                            title: 'B (30%)',
                            radius: 60,
                            titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          PieChartSectionData(
                            value: 15,
                            color: Colors.orange,
                            title: 'C (15%)',
                            radius: 60,
                            titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          PieChartSectionData(
                            value: 15,
                            color: Colors.redAccent,
                            title: 'D (15%)',
                            radius: 60,
                            titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                        sectionsSpace: 4,
                        centerSpaceRadius: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Line Chart - Aktivnost tokom dana",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              FlSpot(0, 2),
                              FlSpot(1, 4),
                              FlSpot(2, 8),
                              FlSpot(3, 6),
                              FlSpot(4, 10),
                              FlSpot(5, 7),
                              FlSpot(6, 12),
                            ],
                            isCurved: true,
                            color: Colors.blueAccent,
                            barWidth: 4,
                            dotData: FlDotData(show: true),
                          ),
                        ],
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
                                    return const Text('06h');
                                  case 2:
                                    return const Text('08h');
                                  case 4:
                                    return const Text('10h');
                                  case 6:
                                    return const Text('12h');
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
                        gridData: FlGridData(show: true),
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
}