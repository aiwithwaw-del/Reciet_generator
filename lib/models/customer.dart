import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'customer.g.dart';

@HiveType(typeId: 0)
class Customer extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phone;

  @HiveField(3)
  double balance; // Positive = owes money, Negative = credit

  @HiveField(4)
  DateTime createdAt;

  Customer({
    String? id,
    required this.name,
    required this.phone,
    this.balance = 0.0,
  })  : id = id ?? const Uuid().v4(),
        createdAt = DateTime.now();

  @override
  String toString() => 'Customer($name, Balance: $balance)';
}