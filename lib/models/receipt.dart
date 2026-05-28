import 'package:uuid/uuid.dart';

class Receipt {
  final String id;
  final String customerId;
  final String customerName;
  final DateTime date;
  final List<ReceiptItem> items;
  final double totalAmount;
  final double paidAmount;
  final double loanAmount;
  final String status;

  Receipt({
    String? id,
    required this.customerId,
    required this.customerName,
    required this.items,
    this.paidAmount = 0.0,
  })  : id = id ?? const Uuid().v4(),
        date = DateTime.now(),
        totalAmount = items.fold(0.0, (sum, item) => sum + item.subtotal),
        loanAmount = (items.fold(0.0, (sum, item) => sum + item.subtotal)) - paidAmount,
        status = paidAmount >= items.fold(0.0, (sum, item) => sum + item.subtotal)
            ? 'Paid'
            : paidAmount > 0
                ? 'Partial'
                : 'Credit';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'date': date.toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'loanAmount': loanAmount,
      'status': status,
    };
  }

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      items: (json['items'] as List).map((i) => ReceiptItem.fromJson(i)).toList(),
      paidAmount: json['paidAmount'],
    );
  }
}

class ReceiptItem {
  final String name;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  ReceiptItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  }) : subtotal = quantity * unitPrice;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'subtotal': subtotal,
    };
  }

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      name: json['name'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'],
    );
  }
}