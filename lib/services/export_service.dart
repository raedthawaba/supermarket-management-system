import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:supermarket_system_phase1/models/transaction.dart';
import 'package:supermarket_system_phase1/models/product.dart';
import 'package:supermarket_system_phase1/models/financial_transaction.dart';

class ExportService {
  // Export transactions to CSV
  Future<File> exportTransactionsToCSV(List<Transaction> transactions, {String filename = 'transactions'}) async {
    try {
      final List<List<dynamic>> rows = [];
      
      // Header row
      rows.add([
        'ID',
        'التاريخ',
        'المبلغ الإجمالي',
        'طريقة الدفع',
        'البائع',
        'عدد المنتجات',
        'الحالة'
      ]);
      
      // Data rows
      for (var transaction in transactions) {
        rows.add([
          transaction.id,
          _formatDateTime(transaction.timestamp),
          transaction.totalAmount.toStringAsFixed(2),
          transaction.paymentMethod,
          transaction.cashierName,
          transaction.items.length.toString(),
          transaction.status
        ]);
      }
      
      final String csv = const ListToCsvConverter().convert(rows);
      final Directory tempDir = Directory.systemTemp;
      final File file = File('${tempDir.path}/$filename.csv');
      await file.writeAsString(csv);
      
      return file;
    } catch (e) {
      throw Exception('فشل في تصدير المعاملات: $e');
    }
  }

  // Export products to CSV
  Future<File> exportProductsToCSV(List<Product> products, {String filename = 'products'}) async {
    try {
      final List<List<dynamic>> rows = [];
      
      // Header row
      rows.add([
        'الاسم',
        'الفئة',
        'السعر',
        'الكمية',
        'الحد الأدنى',
        'الكود',
        'الوصف',
        'الحالة'
      ]);
      
      // Data rows
      for (var product in products) {
        rows.add([
          product.name,
          product.categoryId,
          product.price.toStringAsFixed(2),
          product.stock.toString(),
          product.minStock.toString(),
          product.barcode ?? '',
          product.description ?? '',
          product.isActive ? 'نشط' : 'غير نشط'
        ]);
      }
      
      final String csv = const ListToCsvConverter().convert(rows);
      final Directory tempDir = Directory.systemTemp;
      final File file = File('${tempDir.path}/$filename.csv');
      await file.writeAsString(csv);
      
      return file;
    } catch (e) {
      throw Exception('فشل في تصدير المنتجات: $e');
    }
  }

  // Export financial transactions to CSV
  Future<File> exportFinancialTransactionsToCSV(List<FinancialTransaction> transactions, {String filename = 'financial_transactions'}) async {
    try {
      final List<List<dynamic>> rows = [];
      
      // Header row
      rows.add([
        'ID',
        'التاريخ',
        'النوع',
        'الفئة',
        'المبلغ',
        'الوصف',
        'الحساب',
        'الحالة'
      ]);
      
      // Data rows
      for (var transaction in transactions) {
        rows.add([
          transaction.id,
          _formatDateTime(transaction.date),
          transaction.typeDisplayName,
          transaction.category,
          transaction.amount.toStringAsFixed(2),
          transaction.description,
          transaction.accountId,
          transaction.status
        ]);
      }
      
      final String csv = const ListToCsvConverter().convert(rows);
      final Directory tempDir = Directory.systemTemp;
      final File file = File('${tempDir.path}/$filename.csv');
      await file.writeAsString(csv);
      
      return file;
    } catch (e) {
      throw Exception('فشل في تصدير الحركات المالية: $e');
    }
  }

  // Generate PDF Report
  Future<File> generatePDFReport({
    required String title,
    required Map<String, dynamic> data,
    List<Transaction>? transactions,
    List<Product>? products,
    List<FinancialTransaction>? financialTransactions,
    String filename = 'report',
  }) async {
    try {
      final pdf = pw.Document();
      
      // Load Arabic font
      final fontData = await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf');
      final font = pw.Font.ttf(fontData);
      
      // Add title page
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.SizedBox(height: 50),
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 24,
                  font: font,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'تاريخ الإنشاء: ${_formatDateTime(DateTime.now())}',
                style: pw.TextStyle(
                  fontSize: 12,
                  font: font,
                ),
              ),
              pw.SizedBox(height: 40),
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'محتوى التقرير:',
                      style: pw.TextStyle(
                        fontSize: 16,
                        font: font,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    ...data.entries.map((entry) => pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            '${entry.key}:',
                            style: pw.TextStyle(font: font),
                          ),
                          pw.Text(
                            entry.value.toString(),
                            style: pw.TextStyle(
                              font: font,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      
      // Add transactions table if provided
      if (transactions != null && transactions.isNotEmpty) {
        pdf.addPage(
          pw.Page(
            build: (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'تفاصيل المعاملات',
                  style: pw.TextStyle(
                    fontSize: 18,
                    font: font,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('التاريخ', style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('المبلغ', style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('طريقة الدفع', style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('البائع', style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    ...transactions.take(50).map((transaction) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(_formatDateTime(transaction.timestamp), style: pw.TextStyle(font: font)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${transaction.totalAmount.toStringAsFixed(2)} ريال', style: pw.TextStyle(font: font)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(transaction.paymentMethod, style: pw.TextStyle(font: font)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(transaction.cashierName, style: pw.TextStyle(font: font)),
                        ),
                      ],
                    )),
                  ],
                ),
                if (transactions.length > 50)
                  pw.SizedBox(height: 10),
                if (transactions.length > 50)
                  pw.Text(
                    '... و ${transactions.length - 50} معاملة أخرى',
                    style: pw.TextStyle(font: font, fontStyle: pw.FontStyle.italic),
                  ),
              ],
            ),
          ),
        );
      }
      
      // Add products table if provided
      if (products != null && products.isNotEmpty) {
        pdf.addPage(
          pw.Page(
            build: (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'تفاصيل المنتجات',
                  style: pw.TextStyle(
                    fontSize: 18,
                    font: font,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('الاسم', style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('السعر', style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('الكمية', style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('الحد الأدنى', style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    ...products.take(50).map((product) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(product.name, style: pw.TextStyle(font: font)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${product.price.toStringAsFixed(2)} ريال', style: pw.TextStyle(font: font)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(product.stock.toString(), style: pw.TextStyle(font: font)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(product.minStock.toString(), style: pw.TextStyle(font: font)),
                        ),
                      ],
                    )),
                  ],
                ),
                if (products.length > 50)
                  pw.SizedBox(height: 10),
                if (products.length > 50)
                  pw.Text(
                    '... و ${products.length - 50} منتج آخر',
                    style: pw.TextStyle(font: font, fontStyle: pw.FontStyle.italic),
                  ),
              ],
            ),
          ),
        );
      }
      
      // Add financial transactions table if provided
      if (financialTransactions != null && financialTransactions.isNotEmpty) {
        pdf.addPage(
          pw.Page(
            build: (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'الحركات المالية',
                  style: pw.TextStyle(
                    fontSize: 18,
                    font: font,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('التاريخ', style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('النوع', style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('الفئة', style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('المبلغ', style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    ...financialTransactions.take(50).map((transaction) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(_formatDateTime(transaction.date), style: pw.TextStyle(font: font)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(transaction.typeDisplayName, style: pw.TextStyle(font: font)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(transaction.category, style: pw.TextStyle(font: font)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${transaction.amount.toStringAsFixed(2)} ريال', style: pw.TextStyle(font: font)),
                        ),
                      ],
                    )),
                  ],
                ),
                if (financialTransactions.length > 50)
                  pw.SizedBox(height: 10),
                if (financialTransactions.length > 50)
                  pw.Text(
                    '... و ${financialTransactions.length - 50} حركة أخرى',
                    style: pw.TextStyle(font: font, fontStyle: pw.FontStyle.italic),
                  ),
              ],
            ),
          ),
        );
      }
      
      // Save PDF
      final Directory tempDir = Directory.systemTemp;
      final File file = File('${tempDir.path}/$filename.pdf');
      final bytes = await pdf.save();
      await file.writeAsBytes(bytes);
      
      return file;
    } catch (e) {
      throw Exception('فشل في إنشاء ملف PDF: $e');
    }
  }

  // Print PDF
  Future<void> printPDF(File pdfFile, String documentName) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfFile.readAsBytes(),
        name: documentName,
        format: PdfPageFormat.a4,
      );
    } catch (e) {
      throw Exception('فشل في طباعة الملف: $e');
    }
  }

  // Format date and time
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}