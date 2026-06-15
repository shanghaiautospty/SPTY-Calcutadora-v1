import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:spty_calculadora/models/vehicle.dart';
import 'package:spty_calculadora/services/calculator_service.dart';

class PdfService {
  static Future<void> generateAndSharePdf({
    required ComparisonResult result,
    required FuelType fuelType,
    required bool isEnglish,
  }) async {
    final pdf = pw.Document();
    
    final String fuelLabel = fuelType == FuelType.gasoline 
        ? (isEnglish ? 'GASOLINE' : 'GASOLINA')
        : (isEnglish ? 'DIESEL' : 'DIÉSEL');

    final payback = result.paybackMonths != null
        ? CalculatorService.monthsToYearsAndMonths(result.paybackMonths!)
        : null;

    // Cargar el logo
    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/logo.png')).buffer.asUint8List(),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header con Logo
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(logoImage, height: 60),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        isEnglish ? 'EXECUTIVE SAVINGS REPORT' : 'REPORTE EJECUTIVO DE AHORRO',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                      ),
                      pw.Text(
                        'Shanghai Autos PTY',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 30),

              // Resumen Principal
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.black,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      isEnglish ? 'ESTIMATED ANNUAL SAVINGS' : 'AHORRO ANUAL ESTIMADO',
                      style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      '\$${result.annualSavings.toStringAsFixed(2)}',
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 32, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // Sección: Costos Operativos
              pw.Text(
                isEnglish ? 'OPERATIONAL COST PROJECTION' : 'PROYECCIÓN DE COSTOS OPERATIVOS',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  _buildPdfTableRow(
                    isEnglish ? 'METRIC' : 'MÉTRICA', 
                    isEnglish ? 'ELECTRIC' : 'ELÉCTRICO', 
                    fuelLabel, 
                    isHeader: true
                  ),
                  _buildPdfTableRow(
                    isEnglish ? 'Monthly Cost' : 'Costo Mensual', 
                    '\$${result.evMonthlyCost.toStringAsFixed(2)}', 
                    '\$${result.fossilMonthlyCost.toStringAsFixed(2)}'
                  ),
                  _buildPdfTableRow(
                    isEnglish ? 'Annual Cost' : 'Costo Anual', 
                    '\$${result.evAnnualCost.toStringAsFixed(2)}', 
                    '\$${result.fossilAnnualCost.toStringAsFixed(2)}'
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Sección: Retorno de Inversión
              pw.Text(
                isEnglish ? 'RETURN ON INVESTMENT' : 'RETORNO DE INVERSIÓN',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      isEnglish ? 'Break-even point:' : 'Punto de equilibrio:',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                    ),
                    pw.SizedBox(height: 5),
                    if (payback != null)
                      pw.Text(
                        isEnglish 
                          ? '${payback.years} years and ${payback.months} months'
                          : '${payback.years} años y ${payback.months} meses',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                      )
                    else
                      pw.Text(
                        isEnglish ? 'N/A' : 'No aplica',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                      ),
                  ],
                ),
              ),
              
              pw.Spacer(),
              
              // Footer
              pw.Divider(thickness: 0.5, color: PdfColors.grey300),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'EV CALCULADORA - Shanghai Autos PTY',
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                  ),
                  pw.Text(
                    '© 2024 All rights reserved',
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Compartir o Guardar
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: isEnglish ? 'ShanghaiAutos_Report.pdf' : 'Reporte_ShanghaiAutos.pdf',
    );
  }

  static pw.TableRow _buildPdfTableRow(String c1, String c2, String c3, {bool isHeader = false}) {
    final style = pw.TextStyle(
      fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
      fontSize: 10,
    );
    return pw.TableRow(
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(c1, style: style)),
        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(c2, style: style, textAlign: pw.TextAlign.right)),
        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(c3, style: style, textAlign: pw.TextAlign.right)),
      ],
    );
  }
}
