import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'models.dart';

class PayslipService {
  static final money = NumberFormat('#,##0.00');

  static String amountWords(double amount) {
    const ones = [
      '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight',
      'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen',
      'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'
    ];
    const tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty',
      'Seventy', 'Eighty', 'Ninety'];
    String under1000(int n) {
      var s = '';
      if (n >= 100) {
        s += '${ones[n ~/ 100]} Hundred ';
        n %= 100;
      }
      if (n >= 20) {
        s += '${tens[n ~/ 10]} ';
        n %= 10;
      }
      if (n > 0) s += '${ones[n]} ';
      return s.trim();
    }
    if (amount.round() == 0) return 'Zero Only';
    var n = amount.round();
    final parts = <String>[];
    const scales = [
      (10000000, 'Crore'),
      (100000, 'Lakh'),
      (1000, 'Thousand'),
    ];
    for (final scale in scales) {
      if (n >= scale.$1) {
        parts.add('${under1000(n ~/ scale.$1)} ${scale.$2}');
        n %= scale.$1;
      }
    }
    if (n > 0) parts.add(under1000(n));
    return '${parts.join(' ')} Only';
  }

  static Future<List<int>> build(Employee e, Payroll p) async {
    final pdf = pw.Document(
      title: 'Salary Slip ${e.employeeId} ${p.month}',
      author: 'KAPCO Payroll',
    );
    const gray = PdfColor.fromInt(0xffc8c8c8);
    const green = PdfColor.fromInt(0xff138447);
    final monthDate = DateTime.parse('${p.month}-01');
    final monthName = DateFormat('MMMM-yyyy').format(monthDate);
    pw.Widget labelValue(String label, String value,
            {bool shade = false, bool bold = false}) =>
        pw.Container(
          height: 23,
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(width: .55)),
          ),
          child: pw.Row(children: [
            pw.Container(
              width: 94,
              padding: const pw.EdgeInsets.all(4),
              color: gray,
              child: pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
            ),
            pw.Expanded(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(value,
                    style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight:
                            bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
              ),
            )
          ]),
        );

    pw.Widget amountRow(String name, double value) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
          child: pw.Row(children: [
            pw.Expanded(child: pw.Text(name, style: const pw.TextStyle(fontSize: 8))),
            pw.Text(money.format(value),
                style: const pw.TextStyle(fontSize: 8),
                textAlign: pw.TextAlign.right),
          ]),
        );

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build: (_) => pw.Column(children: [
        pw.Container(
          decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.2)),
          child: pw.Column(children: [
            pw.Container(
              width: double.infinity,
              color: gray,
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: pw.Text('Kot Addu Power Company Limited',
                  style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                      fontStyle: pw.FontStyle.italic)),
            ),
            pw.Container(
              height: 67,
              padding: const pw.EdgeInsets.all(8),
              child: pw.Row(children: [
                pw.Container(
                  width: 135,
                  alignment: pw.Alignment.center,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: green, width: 2),
                  ),
                  child: pw.Text('KAPCO',
                      style: pw.TextStyle(
                          color: green,
                          fontSize: 27,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 2)),
                ),
                pw.Expanded(
                    child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text('CONFIDENTIAL',
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 7),
                    pw.Text('Salary Slip for the month of $monthName',
                        style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            fontStyle: pw.FontStyle.italic)),
                  ],
                ))
              ]),
            ),
            pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Expanded(
                  child: pw.Column(children: [
                labelValue('Employee ID :', e.employeeId, bold: true),
                labelValue('Employee Name :', e.name, bold: true),
                labelValue('Grade :', e.grade),
                labelValue('Department :', e.department),
                labelValue('Designation :', e.designation),
                labelValue('Employee Type :', e.employeeType),
                labelValue('Work Location :', e.workLocation),
                labelValue('Joining Date :',
                    _displayDate(e.joiningDate)),
              ])),
              pw.Expanded(
                  child: pw.Column(children: [
                labelValue('Payable Days', '${p.payableDays}'),
                labelValue('Leave With Pay', '${p.leaveWithPay}'),
                labelValue('Leave WO Pay', '${p.leaveWithoutPay}'),
                labelValue('Absent', '${p.absent}'),
                labelValue('Arrears Days', '${p.arrearsDays}'),
                labelValue('OT Hours', money.format(p.otHours)),
                labelValue('OT Arrears Hours', money.format(p.otArrearsHours)),
                labelValue('CNIC :', e.cnic),
              ])),
            ]),
          ]),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          height: 235,
          decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.2)),
          child: pw.Column(children: [
            pw.Container(
              color: gray,
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: pw.Row(children: [
                pw.Expanded(
                    child: pw.Text('PAYMENT & ALLOWANCES',
                        style: pw.TextStyle(
                            fontSize: 9,
                            fontStyle: pw.FontStyle.italic,
                            fontWeight: pw.FontWeight.bold))),
                pw.Text('AMOUNT',
                    style: pw.TextStyle(
                        fontSize: 9,
                        fontStyle: pw.FontStyle.italic,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(width: 14),
                pw.Expanded(
                    child: pw.Text('DEDUCTIONS',
                        style: pw.TextStyle(
                            fontSize: 9,
                            fontStyle: pw.FontStyle.italic,
                            fontWeight: pw.FontWeight.bold))),
                pw.Text('AMOUNT',
                    style: pw.TextStyle(
                        fontSize: 9,
                        fontStyle: pw.FontStyle.italic,
                        fontWeight: pw.FontWeight.bold)),
              ]),
            ),
            pw.Expanded(
                child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                  pw.Expanded(
                      child: pw.Column(
                          children: p.earnings.entries
                              .map((x) => amountRow(x.key, x.value))
                              .toList())),
                  pw.Container(width: .8, color: PdfColors.black),
                  pw.Expanded(
                      child: pw.Column(
                          children: p.deductions.entries
                              .map((x) => amountRow(x.key, x.value))
                              .toList())),
                ])),
            pw.Container(height: .8, color: PdfColors.black),
            pw.Padding(
                padding: const pw.EdgeInsets.all(7),
                child: pw.Row(children: [
                  pw.Text('GROSS PAY:',
                      style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          fontStyle: pw.FontStyle.italic)),
                  pw.Spacer(),
                  pw.Text(money.format(p.gross),
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(width: 105),
                  pw.Text('TOTAL DEDUCTIONS:',
                      style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          fontStyle: pw.FontStyle.italic)),
                  pw.Spacer(),
                  pw.Text(money.format(p.totalDeductions),
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold)),
                ])),
            pw.Container(height: .8, color: PdfColors.black),
            pw.Padding(
                padding: const pw.EdgeInsets.all(7),
                child: pw.Row(children: [
                  pw.Text('AMOUNT IN:',
                      style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          fontStyle: pw.FontStyle.italic)),
                  pw.SizedBox(width: 16),
                  pw.Expanded(
                      child: pw.Text(amountWords(p.net),
                          style: const pw.TextStyle(fontSize: 8))),
                  pw.Text('NET PAY (PKR):',
                      style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          fontStyle: pw.FontStyle.italic)),
                  pw.SizedBox(width: 30),
                  pw.Text(money.format(p.net),
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold)),
                ])),
          ]),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          width: double.infinity,
          decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.2)),
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                    width: double.infinity,
                    color: gray,
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text('DEPOSITED TO BANK ACCOUNT :',
                        style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            fontStyle: pw.FontStyle.italic))),
                pw.Padding(
                    padding: const pw.EdgeInsets.fromLTRB(75, 10, 10, 10),
                    child: pw.Table(columnWidths: const {
                      0: pw.FixedColumnWidth(70),
                      1: pw.FixedColumnWidth(12),
                      2: pw.FlexColumnWidth(),
                    }, children: [
                      _bankRow('Account #', e.accountNumber),
                      _bankRow('IBAN', e.iban),
                      _bankRow('Bank', e.bank),
                      _bankRow('Address', e.bankAddress),
                    ]))
              ]),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
            'This is a computer generated statement and does not require a stamp or signature',
            style: const pw.TextStyle(fontSize: 8)),
        pw.Text(
            'This is a confidential document and is not to be shared or disclosed to anyone',
            style: const pw.TextStyle(fontSize: 8)),
      ]),
    ));
    return pdf.save();
  }

  static pw.TableRow _bankRow(String label, String value) => pw.TableRow(children: [
        pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 2),
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 8))),
        pw.Text(':', style: const pw.TextStyle(fontSize: 8)),
        pw.Text(value, style: const pw.TextStyle(fontSize: 8)),
      ]);

  static String _displayDate(String input) {
    try {
      return DateFormat('dd-MMMM-yyyy').format(DateTime.parse(input));
    } catch (_) {
      return input;
    }
  }

  static Future<File> save(Employee e, Payroll p) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/Salary_Slip_${e.employeeId}_${p.month}.pdf');
    await file.writeAsBytes(await build(e, p), flush: true);
    return file;
  }

  static Future<void> printSlip(Employee e, Payroll p) async =>
      Printing.layoutPdf(onLayout: (_) => build(e, p));

  static Future<void> share(Employee e, Payroll p) async {
    final file = await save(e, p);
    await Share.shareXFiles([XFile(file.path)],
        text: 'KAPCO salary slip for ${p.month}');
  }
}
