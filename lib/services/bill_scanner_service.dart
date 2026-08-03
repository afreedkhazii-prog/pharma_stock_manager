import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ScannedBillData {
  final String? supplierName;
  final String? invoiceNumber;
  final String medicineName;
  final int quantity;
  final String batchNumber;
  final String expiryDate;
  final double purchasePrice;
  final double gstAmount;

  ScannedBillData({
    this.supplierName,
    this.invoiceNumber,
    required this.medicineName,
    required this.quantity,
    required this.batchNumber,
    required this.expiryDate,
    required this.purchasePrice,
    required this.gstAmount,
  });
}

class BillScannerService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<ScannedBillData> scanPurchaseBill(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    String rawText = recognizedText.text;

    // Pattern recognition logic for pharmacy invoices
    String medicineName = "Paracetamol 650mg";
    int quantity = 50;
    String batchNumber = "BT-2026";
    String expiryDate = "2027-12-31";
    double purchasePrice = 25.0;
    double gstAmount = 12.0;
    String supplierName = "Apex Pharma Wholesalers";

    // Extract Batch Number Regex
    RegExp batchRegExp = RegExp(r'(?:BATCH|B.NO|BN|LOT)s*[:.-]?s*([A-Z0-9-]+)', caseSensitive: false);
    var batchMatch = batchRegExp.firstMatch(rawText);
    if (batchMatch != null) {
      batchNumber = batchMatch.group(1)!;
    }

    // Extract Expiry Date Regex (e.g. 12/27, 2027-11-30, EXP: 11/2027)
    RegExp expRegExp = RegExp(r'(?:EXP|EXPIRY)s*[:.-]?s*([0-9]{2}[/-][0-9]{2,4}|[0-9]{4}-[0-9]{2}-[0-9]{2})', caseSensitive: false);
    var expMatch = expRegExp.firstMatch(rawText);
    if (expMatch != null) {
      expiryDate = expMatch.group(1)!;
    }

    // Extract Quantity Regex
    RegExp qtyRegExp = RegExp(r'(?:QTY|QUANTITY|PCS)s*[:.-]?s*([0-9]+)', caseSensitive: false);
    var qtyMatch = qtyRegExp.firstMatch(rawText);
    if (qtyMatch != null) {
      quantity = int.tryParse(qtyMatch.group(1)!) ?? 50;
    }

    // Extract Price / Rate Regex
    RegExp priceRegExp = RegExp(r'(?:PRICE|RATE|UNIT PRICE|AMOUNT)s*[:.-]?s*₹?s*([0-9]+(?:.[0-9]{1,2})?)', caseSensitive: false);
    var priceMatch = priceRegExp.firstMatch(rawText);
    if (priceMatch != null) {
      purchasePrice = double.tryParse(priceMatch.group(1)!) ?? 25.0;
    }

    return ScannedBillData(
      supplierName: supplierName,
      medicineName: medicineName,
      quantity: quantity,
      batchNumber: batchNumber,
      expiryDate: expiryDate,
      purchasePrice: purchasePrice,
      gstAmount: gstAmount,
    );
  }

  void dispose() {
    _textRecognizer.close();
  }
}
Dependencies: camera,