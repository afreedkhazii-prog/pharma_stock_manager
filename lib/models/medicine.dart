class Medicine {
  final String id;
  final String name;
  final String? genericName;
  final String category;
  final int quantity;
  final int minStockAlert;
  final String batchNumber;
  final String expiryDate;
  final double purchasePrice;
  final double mrp;
  final double sellingPrice;
  final double gstRate;
  final String supplier;
  final String rackLocation;
  final String lastUpdated;
  final String? notes;
  final String? billPhotoUrl;

  Medicine({
    required this.id,
    required this.name,
    this.genericName,
    required this.category,
    required this.quantity,
    required this.minStockAlert,
    required this.batchNumber,
    required this.expiryDate,
    required this.purchasePrice,
    required this.mrp,
    required this.sellingPrice,
    required this.gstRate,
    required this.supplier,
    required this.rackLocation,
    required this.lastUpdated,
    this.notes,
    this.billPhotoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'genericName': genericName,
      'category': category,
      'quantity': quantity,
      'minStockAlert': minStockAlert,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate,
      'purchasePrice': purchasePrice,
      'mrp': mrp,
      'sellingPrice': sellingPrice,
      'gstRate': gstRate,
      'supplier': supplier,
      'rackLocation': rackLocation,
      'lastUpdated': lastUpdated,
      'notes': notes,
      'billPhotoUrl': billPhotoUrl,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'],
      name: map['name'],
      genericName: map['genericName'],
      category: map['category'],
      quantity: map['quantity'],
      minStockAlert: map['minStockAlert'],
      batchNumber: map['batchNumber'],
      expiryDate: map['expiryDate'],
      purchasePrice: (map['purchasePrice'] as num).toDouble(),
      mrp: (map['mrp'] as num).toDouble(),
      sellingPrice: (map['sellingPrice'] as num).toDouble(),
      gstRate: (map['gstRate'] as num).toDouble(),
      supplier: map['supplier'],
      rackLocation: map['rackLocation'],
      lastUpdated: map['lastUpdated'],
      notes: map['notes'],
      billPhotoUrl: map['billPhotoUrl'],
    );
  }
}
