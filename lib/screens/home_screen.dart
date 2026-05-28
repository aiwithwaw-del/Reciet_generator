import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../services/database.dart';
import 'add_customer_screen.dart';
import 'create_receipt_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _db = DatabaseService();
  List<Customer> _customers = [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    try {
      final list = _db.getAllCustomers();
      list.sort((a, b) => a.name.compareTo(b.name));
      setState(() {
        _customers = list;
      });
    } catch (e) {
      debugPrint('Load error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalBalance = _customers.fold(0.0, (sum, c) => sum + c.balance);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt & Balance Tracker'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                Expanded(child: _buildCard('Customers', _customers.length.toString(), Icons.people, Colors.blue)),
                const SizedBox(width: 8),
                Expanded(child: _buildCard('Total Balance', 'UGX ${NumberFormat("#,##0").format(totalBalance)}', Icons.account_balance_wallet, Colors.green)),
              ],
            ),
          ),
          Expanded(child: _customers.isEmpty ? _buildEmpty() : _buildList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCustomerScreen()));
          _loadCustomers();
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Customer'),
      ),
    );
  }

  Widget _buildCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ]),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No customers yet', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Tap "Add Customer" to get started', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _customers.length,
      itemBuilder: (context, index) {
        final c = _customers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: c.balance > 0 ? Colors.orange : Colors.green,
              child: Text(c.name[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
            ),
            title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(c.phone),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('UGX ${NumberFormat("#,##0").format(c.balance)}', style: TextStyle(fontWeight: FontWeight.bold, color: c.balance > 0 ? Colors.red : Colors.green)),
                Text(c.balance > 0 ? 'Owes' : 'Credit', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.receipt_long, color: Colors.blue),
                        title: const Text('Create Receipt'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => CreateReceiptScreen(customer: c)));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.edit, color: Colors.orange),
                        title: const Text('Edit Customer'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => AddCustomerScreen(customer: c)));
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}