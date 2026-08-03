import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/medicine.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _genericController = TextEditingController();
  final _qtyController = TextEditingController(text: '50');
  final _batchController = TextEditingController();
  final _expiryController = TextEditingController(text: '2027-12-31');
  final _priceController = TextEditingController();
  final _mrpController = TextEditingController();
  final _supplierController = TextEditingController();
  final _rackController = TextEditingController(text: 'Rack A-1');

  String _category = 'Tablets';

  Future<void> _saveMedicine() async {
    if (!_formKey.currentState!.validate()) return;

    final med = Medicine(
      id: 'med_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      genericName: _genericController.text,
      category: _category,
      quantity: int.parse(_qtyController.text),
      minStockAlert: 20,
      batchNumber: _batchController.text,
      expiryDate: _expiryController.text,
      purchasePrice: double.parse(_priceController.text),
      mrp: double.tryParse(_mrpController.text) ?? 0.0,
      sellingPrice: (double.tryParse(_priceController.text) ?? 0.0) * 1.2,
      gstRate: 12.0,
      supplier: _supplierController.text.isNotEmpty ? _supplierController.text : 'Direct Purchase',
      rackLocation: _rackController.text,
      lastUpdated: DateTime.now().toIso8601String(),
    );

    await DatabaseHelper.instance.insertMedicine(med);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicine added successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Medicine Manually')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Medicine Name *'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _genericController,
                decoration: const InputDecoration(labelText: 'Generic Name / Formula'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['Tablets', 'Syrup', 'Injection', 'Ointment', 'Capsules', 'Drops']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantity *'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _batchController,
                      decoration: const InputDecoration(labelText: 'Batch Number *'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: const InputDecoration(labelText: 'Expiry (YYYY-MM-DD)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Purchase Price (₹) *'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _supplierController,
                decoration: const InputDecoration(labelText: 'Supplier Name'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _saveMedicine,
                  child: const Text('Save Medicine to SQLite',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
