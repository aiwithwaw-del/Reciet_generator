import 'package:uuid/uuid.dart';

class Customer {
  final String id;
  String name;
  String phone;
  double balance;
  final DateTime createdAt;

  Customer({
    String? id,
    required this.name,
    required this.phone,
    this.balance = 0.0,
  })  : id = id ?? const Uuid().v4(),
        createdAt = DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'balance': balance,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      balance: json['balance'],
    );
  }
}