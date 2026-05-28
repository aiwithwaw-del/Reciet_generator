import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'receipt.g.dart';

@HiveType(typeId: 1)
class Receipt extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String customerId;

  @HiveField(2)
  String customerName;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  List<ReceiptItem> items;

  @HiveField(5)
  double totalAmount;

  @HiveField(6)
  double paidAmount;

  @HiveField(7)
  double loanAmount;

  @HiveField(8)
  String status;

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

  double get balance => loanAmount;
}

@HiveType(typeId: 2)
class ReceiptItem extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  double unitPrice;

  @HiveField(3)
  double subtotal;

  ReceiptItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  }) : subtotal = quantity * unitPrice;
}