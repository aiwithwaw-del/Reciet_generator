import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/customer.dart';
import '../models/receipt.dart';

class DatabaseService {
  static SharedPreferences? _prefs;
  static const String _customersKey = 'customers';
  static const String _receiptsKey = 'receipts';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ========== CUSTOMER METHODS ==========
  List<Customer> _getCustomers() {
    final data = _prefs?.getStringList(_customersKey) ?? [];
    return data.map((json) => Customer.fromJson(jsonDecode(json))).toList();
  }

  Future<void> _saveCustomers(List<Customer> customers) async {
    final data = customers.map((c) => jsonEncode(c.toJson())).toList();
    await _prefs?.setStringList(_customersKey, data);
  }

  Future<void> addCustomer(Customer customer) async {
    final customers = _getCustomers();
    customers.add(customer);
    await _saveCustomers(customers);
  }

  Future<void> updateCustomer(Customer customer) async {
    final customers = _getCustomers();
    final index = customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      customers[index] = customer;
      await _saveCustomers(customers);
    }
  }

  List<Customer> getAllCustomers() {
    return _getCustomers()..sort((a, b) => a.name.compareTo(b.name));
  }

  Customer? getCustomer(String id) {
    return _getCustomers().firstWhere((c) => c.id == id, orElse: () => Customer(name: '', phone: ''));
  }

  // ========== RECEIPT METHODS ==========
  List<Receipt> _getReceipts() {
    final data = _prefs?.getStringList(_receiptsKey) ?? [];
    return data.map((json) => Receipt.fromJson(jsonDecode(json))).toList();
  }

  Future<void> _saveReceipts(List<Receipt> receipts) async {
    final data = receipts.map((r) => jsonEncode(r.toJson())).toList();
    await _prefs?.setStringList(_receiptsKey, data);
  }

  Future<void> addReceipt(Receipt receipt) async {
    final receipts = _getReceipts();
    receipts.add(receipt);
    await _saveReceipts(receipts);
    
    // Update customer balance
    final customer = getCustomer(receipt.customerId);
    if (customer != null) {
      customer.balance += receipt.loanAmount;
      await updateCustomer(customer);
    }
  }

  List<Receipt> getAllReceipts() {
    return _getReceipts()..sort((a, b) => b.date.compareTo(a.date));
  }

  List<Receipt> getReceiptsByCustomer(String customerId) {
    return _getReceipts()
        .where((r) => r.customerId == customerId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double getTotalBalance() {
    return getAllCustomers().fold(0.0, (sum, c) => sum + c.balance);
  }

  double getTotalSales() {
    return getAllReceipts().fold(0.0, (sum, r) => sum + r.totalAmount);
  }
}