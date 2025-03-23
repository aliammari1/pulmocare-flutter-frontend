import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'medicament.dart';

class Ordonnance {
  String? id; // Changed from final to allow updating
  final String patientId;
  final String medecinId;
  final String clinique;
  final String specialite;
  final DateTime date;
  final List<Medicament> medicaments;
  final Uint8List? signature;
  final Uint8List? cachet;

  Ordonnance({
    this.id,
    required this.patientId,
    required this.medecinId,
    this.clinique = '', // Default value
    this.specialite = '', // Default value
    required this.date,
    required this.medicaments,
    this.signature,
    this.cachet,
  });

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'medecin_id': medecinId,
      'medicaments': medicaments
          .map((m) => {
                'name': m.name,
                'dosage': m.dosage ?? '',
                'posologie': m.posologie ?? '',
                'laboratoire': m.laboratoire ?? '',
              })
          .toList(),
      'clinique': clinique,
      'specialite': specialite,
      'date': date.toIso8601String(),
    };
  }

  factory Ordonnance.fromJson(Map<String, dynamic> json) {
    return Ordonnance(
      patientId: json['patient_id'],
      medecinId: json['medecin_id'],
      clinique: json['clinique'] ?? '',
      specialite: json['specialite'] ?? '',
      date: DateTime.parse(json['date']),
      medicaments: (json['medicaments'] as List)
          .map((m) => Medicament.fromJson(m))
          .toList(),
    );
  }

  Future<Uint8List> generatePdf() async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Ajout de la signature et du cachet s'ils existent
    final signatureImage =
        signature != null ? pw.MemoryImage(signature!) : null;
    final cachetImage = cachet != null ? pw.MemoryImage(cachet!) : null;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'ORDONNANCE MEDICALE',
                    style: const pw.TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),

                // Info section
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('PATIENT: ${patientId.toUpperCase()}'),
                      pw.Text('MEDECIN: ${medecinId.toUpperCase()}'),
                      pw.Text('CLINIQUE: ${clinique.toUpperCase()}'),
                      pw.Text('SPECIALITE: ${specialite.toUpperCase()}'),
                      pw.Text('DATE: ${dateFormat.format(date).toUpperCase()}'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Medications section
                pw.Text(
                  'MEDICAMENTS PRESCRITS:',
                  style: const pw.TextStyle(fontSize: 18),
                ),
                pw.SizedBox(height: 10),

                // Medications table
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    // Header row
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey300,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('MEDICAMENT'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('DOSAGE'),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('POSOLOGIE'),
                        ),
                      ],
                    ),
                    // Data rows
                    ...medicaments.map(
                      (med) => pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(med.name.toUpperCase()),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text((med.dosage ?? '-').toUpperCase()),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child:
                                pw.Text((med.posologie ?? '-').toUpperCase()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Signatures section
                if (signature != null || cachet != null)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 50),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        if (signature != null)
                          pw.Column(
                            children: [
                              pw.Text('SIGNATURE'),
                              pw.Image(pw.MemoryImage(signature!), height: 70),
                            ],
                          ),
                        if (cachet != null)
                          pw.Column(
                            children: [
                              pw.Text('CACHET'),
                              pw.Image(pw.MemoryImage(cachet!), height: 100),
                            ],
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );

    // Ajout de la signature et du cachet
    if (signatureImage != null || cachetImage != null) {
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              if (signatureImage != null)
                pw.Column(
                  children: [
                    pw.Text('Signature'),
                    pw.Image(signatureImage, height: 70),
                  ],
                ),
              if (cachetImage != null)
                pw.Column(
                  children: [
                    pw.Text('Cachet'),
                    pw.Image(cachetImage, height: 100),
                  ],
                ),
            ],
          ),
        ),
      );
    }

    return pdf.save();
  }
}
