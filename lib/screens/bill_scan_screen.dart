import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../services/bill_scanner_service.dart';
import '../services/database_helper.dart';
import '../models/medicine.dart';

class BillScanScreen extends StatefulWidget {
  const BillScanScreen({super.key});

  @override
  State<BillScanScreen> createState() => _BillScanScreenState();
}

class _BillScanScreenState extends State<BillScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final BillScannerService _scannerService = BillScannerService();

  File? _scannedImage;
  bool _isProcessing = false;

  // Form Controllers
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _batchController = TextEditingController();
  final _expiryController = TextEditingController();
  final _priceController = TextEditingController();
  final _gstController = TextEditingController();

  Future<void> _captureOrPickBill(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;

    setState(() {
      _scannedImage = File(pickedFile.path);
      _isProcessing = true;
    });

    try {
      final data = await _scannerService.scanPurchaseBill(pickedFile.path);

      setState(() {
        _nameController.text = data.medicineName;
        _qtyController.text = data.quantity.toString();
        _batchController.text = data.batchNumber;
        _expiryController.text = data.expiryDate;
        _priceController.text = data.purchasePrice.toStringAsFixed(2);
        _gstController.text = data.gstAmount.toStringAsFixed(2);
        _isProcessing = false;
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OCR Failed: $e')),
        );
      }
    }
  }

  Future<void> _saveScannedMedicine() async {
    if (_scannedImage == null || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please scan a bill and complete the details.')),
      );
      return;
    }

    // Save image to local device storage
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'bill_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedImage = await _scannedImage!.copy(p.join(appDir.path, fileName));

    final newMed = Medicine(
      id: 'med_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      category: 'Tablets',
      quantity: int.tryParse(_qtyController.text) ?? 10,
      minStockAlert: 20,
      batchNumber: _batchController.text,
      expiryDate: _expiryController.text,
      purchasePrice: double.tryParse(_priceController.text) ?? 0.0,
      mrp: (double.tryParse(_priceController.text) ?? 0.0) * 1.3,
      sellingPrice: (double.tryParse(_priceController.text) ?? 0.0) * 1.2,
      gstRate: 12.0,
      supplier: 'Scanned Purchase Bill',
      rackLocation: 'Rack A-1',
      lastUpdated: DateTime.now().toIso8601String(),
      billPhotoUrl: savedImage.path,
    );

    await DatabaseHelper.instance.insertMedicine(newMed);

    // Save stock history
    await DatabaseHelper.instance.insertStockHistory({
      'id': 'hist_${DateTime.now().millisecondsSinceEpoch}',
      'medicineId': newMed.id,
      'medicineName': newMed.name,
      'type': 'BILL_SCAN',
      'quantityChange': newMed.quantity,
      'previousQuantity': 0,
      'newQuantity': newMed.quantity,
      'batchNumber': newMed.batchNumber,
      'expiryDate': newMed.expiryDate,
      'purchasePrice': newMed.purchasePrice,
      'billPhotoUrl': savedImage.path,
      'timestamp': DateTime.now().toIso8601String(),
      'user': 'Pharmacist',
      'notes': 'Scanned Bill & Auto-filled Stock',
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock updated & bill photo saved!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Camera Bill Scanner')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Bill Capture Area
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.teal.shade300, style: BorderStyle.solid),
              ),
              child: _scannedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(_scannedImage!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.center_focus_strong, size: 48, color: Color(0xFF0F766E)),
                        const SizedBox(height: 10),
                        const Text('Take photo of purchase invoice bill',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F766E),
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Camera'),
                              onPressed: () => _captureOrPickBill(ImageSource.camera),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Gallery'),
                              onPressed: () => _captureOrPickBill(ImageSource.gallery),
                            ),
                          ],
                        )
                      ],
                    ),
            ),

            const SizedBox(height: 20),

            if (_isProcessing) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 10),
              const Text('OCR Reading Text & Extracting Medicine Details...'),
            ] else ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Auto-Filled Stock Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Medicine Name'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _batchController,
                      decoration: const InputDecoration(labelText: 'Batch No'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiryController,
                      decoration: const InputDecoration(labelText: 'Expiry Date (YYYY-MM-DD)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Purchase Price (₹)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Confirm & Save Stock Entry',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: _saveScannedMedicine,
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
