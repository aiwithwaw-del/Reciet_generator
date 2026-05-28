import 'package:hive_flutter/hive_flutter.dart';
import '../models/customer.dart';
import '../models/receipt.dart';

class DatabaseService {
  static late Box<Customer> customersBox;
  static late Box<Receipt> receiptsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CustomerAdapter());
    Hive.registerAdapter(ReceiptItemAdapter());
    Hive.registerAdapter(ReceiptAdapter());
    customersBox = await Hive.openBox<Customer>('customers');
    receiptsBox = await Hive.openBox<Receipt>('receipts');
  }

  // ========== CUSTOMER METHODS ==========
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

  // ========== RECEIPT METHODS ==========
  Future<void> addReceipt(Receipt receipt) async {
    await receiptsBox.put(receipt.id, receipt);
    
    // Update customer balance
    final customer = getCustomer(receipt.customerId);
    if (customer != null) {
      customer.balance += receipt.loanAmount;
      await customer.save();
    }
  }

  Future<void> updateReceipt(Receipt receipt) async {
    final oldReceipt = getReceipt(receipt.id);
    if (oldReceipt != null) {
      // Remove old balance impact
      final oldCustomer = getCustomer(oldReceipt.customerId);
      if (oldCustomer != null) {
        oldCustomer.balance -= oldReceipt.loanAmount;
        await oldCustomer.save();
      }
    }
    
    // Save new receipt
    await receiptsBox.put(receipt.id, receipt);
    
    // Add new balance impact
    final customer = getCustomer(receipt.customerId);
    if (customer != null) {
      customer.balance += receipt.loanAmount;
      await customer.save();
    }
  }

  List<Receipt> getAllReceipts() {
    return receiptsBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<Receipt> getReceiptsByCustomer(String customerId) {
    return receiptsBox.values
        .where((r) => r.customerId == customerId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Receipt? getReceipt(String id) {
    return receiptsBox.get(id);
  }

  Future<void> deleteReceipt(String id) async {
    final receipt = getReceipt(id);
    if (receipt != null) {
      // Remove balance impact
      final customer = getCustomer(receipt.customerId);
      if (customer != null) {
        customer.balance -= receipt.loanAmount;
        await customer.save();
      }
      await receiptsBox.delete(id);
    }
  }

  // ========== STATS ==========
  double getTotalBalance() {
    return getAllCustomers().fold(0.0, (sum, c) => sum + c.balance);
  }

  double getTotalLoans() {
    return getAllCustomers()
        .where((c) => c.balance > 0)
        .fold(0.0, (sum, c) => sum + c.balance);
  }

  double getTotalSales() {
    return getAllReceipts().fold(0.0, (sum, r) => sum + r.totalAmount);
  }
}