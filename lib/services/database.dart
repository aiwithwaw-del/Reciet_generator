import 'package:hive_flutter/hive_flutter.dart';
import '../models/customer.dart';

class DatabaseService {
  static late Box<Customer> customersBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CustomerAdapter());
    customersBox = await Hive.openBox<Customer>('customers');
  }

  // Customer CRUD
  Future<void> addCustomer(Customer customer) async {
    await customersBox.put(customer.id, customer);
  }

  Future<void> updateCustomer(Customer customer) async {
    await customersBox.put(customer.id, customer);
  }

  Future<void> deleteCustomer(String id) async {
    await customersBox.delete(id);
  }

  List<Customer> getAllCustomers() {
    return customersBox.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Customer? getCustomer(String id) {
    return customersBox.get(id);
  }

  // Balance tracking
  Future<void> updateBalance(String customerId, double amount) async {
    final customer = getCustomer(customerId);
    if (customer != null) {
      customer.balance += amount;
      await customer.save();
    }
  }

  double getTotalBalance() {
    return getAllCustomers().fold(0.0, (sum, c) => sum + c.balance);
  }

  double getTotalLoans() {
    return getAllCustomers()
        .where((c) => c.balance > 0)
        .fold(0.0, (sum, c) => sum + c.balance);
  }
}