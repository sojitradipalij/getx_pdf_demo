import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

class PdfGenerator {
  static Future<Uint8List> generate(
      PdfPageFormat format, var tableHeaders, var dataTable) async {
    final pdf = Document();

    final pageTheme = await _myPageTheme(format);

    const baseColor = PdfColors.cyan;

    // Top bar chart
    final chart1 = Chart(
      left: Container(
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.only(right: 5, top: 10),
        child: Transform.rotateBox(
          angle: pi / 2,
          child: Text('Amount'),
        ),
      ),
      // overlay: ChartLegend(
      //   position: const Alignment(-.7, 1),
      //   decoration: BoxDecoration(
      //     color: PdfColors.white,
      //     border: Border.all(
      //       color: PdfColors.black,
      //       width: .5,
      //     ),
      //   ),
      // ),
      grid: CartesianGrid(
        xAxis: FixedAxis.fromStrings(
          List<String>.generate(
              dataTable.length, (index) => dataTable[index][0] as String),
          marginStart: 30,
          marginEnd: 30,
          ticks: true,
        ),
        yAxis: FixedAxis(
          [0, 100, 200, 300, 400, 500, 600, 700],
          format: (v) => '\$$v',
          divisions: true,
        ),
      ),
      datasets: [
        BarDataSet(
          color: PdfColors.blue100,
          legend: tableHeaders[2],
          width: 15,
          offset: -10,
          borderColor: baseColor,
          data: List<LineChartValue>.generate(
            dataTable.length,
            (i) {
              final v = dataTable[i][2] as num;
              return LineChartValue(i.toDouble(), v.toDouble());
            },
          ),
        ),
        BarDataSet(
          color: PdfColors.amber100,
          legend: tableHeaders[1],
          width: 15,
          offset: 10,
          borderColor: PdfColors.amber,
          data: List<LineChartValue>.generate(
            dataTable.length,
            (i) {
              final v = dataTable[i][1] as num;
              return LineChartValue(i.toDouble(), v.toDouble());
            },
          ),
        ),
      ],
    );

    // Left curved line chart
    final chart2 = Chart(
      // right: ChartLegend(),
      grid: CartesianGrid(
        xAxis: FixedAxis([0, 1, 2, 3, 4, 5, 6]),
        yAxis: FixedAxis(
          [0, 200, 400, 600],
          divisions: true,
        ),
      ),
      datasets: [
        LineDataSet(
          legend: 'Expense',
          drawSurface: true,
          isCurved: true,
          drawPoints: false,
          color: baseColor,
          data: List<LineChartValue>.generate(
            dataTable.length,
            (i) {
              final v = dataTable[i][2] as num;
              return LineChartValue(i.toDouble(), v.toDouble());
            },
          ),
        ),
      ],
    );

    // Data table
    final table = Table.fromTextArray(
      headers: tableHeaders,
      data: List<List<dynamic>>.generate(
        dataTable.length,
        (index) => <dynamic>[
          dataTable[index][0],
          dataTable[index][1],
          dataTable[index][2],
          (dataTable[index][1] as num) - (dataTable[index][2] as num),
        ],
      ),
      headerStyle: TextStyle(
        color: PdfColors.white,
        fontWeight: FontWeight.bold,
      ),
      headerDecoration: const BoxDecoration(
        color: baseColor,
      ),
      rowDecoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: baseColor,
            width: .5,
          ),
        ),
      ),
      cellAlignment: Alignment.center,
      cellAlignments: {0: Alignment.centerLeft},
    );

    pdf.addPage(MultiPage(
      pageTheme: pageTheme,
      build: (context) => <Widget>[
        Divider(thickness: 4),
        Text('Report',
            style: const TextStyle(
              color: baseColor,
              fontSize: 40,
            )),
        Divider(thickness: 4),
        SizedBox(height: 20),
        Container(height: 270, child: chart1),
        Divider(height: 50),
        Container(height: 260, child: chart2),
        SizedBox(height: 20),
        Container(height: 300, child: table),
      ],
      footer: (context) {
        final text = 'Page ${context.pageNumber} of ${context.pagesCount}';

        return Container(
          alignment: Alignment.centerRight,
          margin: const EdgeInsets.only(top: 1 * PdfPageFormat.cm),
          child: Text(
            text,
            style: const TextStyle(color: PdfColors.black),
          ),
        );
      },
    ));
    return pdf.save();
    // return saveDocument(name: 'my_pdf.pdf', pdf: pdf);
  }

  static Future<File> saveDocument({
    required String name,
    required Document pdf,
  }) async {
    final bytes = await pdf.save();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');

    await file.writeAsBytes(bytes);
    OpenFile.open(file.path);
    return file;
  }
}

Future<PageTheme> _myPageTheme(PdfPageFormat format) async {
  final bgShape = await rootBundle.loadString('assets/resume.svg');

  format = format.applyMargin(
      left: 2.0 * PdfPageFormat.cm,
      top: 4.0 * PdfPageFormat.cm,
      right: 2.0 * PdfPageFormat.cm,
      bottom: 2.0 * PdfPageFormat.cm);
  return PageTheme(
    pageFormat: format,
    margin: const EdgeInsets.only(left: 50, right: 50, bottom: 20, top: 40),
    theme: ThemeData.withFont(
      base: await PdfGoogleFonts.openSansRegular(),
      bold: await PdfGoogleFonts.openSansBold(),
      icons: await PdfGoogleFonts.materialIcons(),
    ),
    buildBackground: (Context context) {
      return FullPage(
        ignoreMargins: true,
        child: Stack(
          children: [
            Positioned(
              child: SvgImage(svg: bgShape),
              left: 0,
              top: 0,
            ),
          ],
        ),
      );
    },
  );
}
