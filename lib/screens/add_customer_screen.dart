import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/database.dart';

class AddCustomerScreen extends StatefulWidget {
  final Customer? customer;
  const AddCustomerScreen({super.key, this.customer});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.customer?.name ?? '');
    _phoneCtrl = TextEditingController(text: widget.customer?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      final db = DatabaseService();
      if (widget.customer == null) {
        await db.addCustomer(Customer(name: _nameCtrl.text.trim(), phone: _phoneCtrl.text.trim()));
      } else {
        widget.customer!.name = _nameCtrl.text.trim();
        widget.customer!.phone = _phoneCtrl.text.trim();
        await db.updateCustomer(widget.customer!);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.customer == null ? 'Add Customer' : 'Edit Customer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Customer Name', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()), validator: (v) => v!.trim().isEmpty ? 'Name required' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder()), keyboardType: TextInputType.phone, validator: (v) => v!.trim().isEmpty ? 'Phone required' : null),
              const SizedBox(height: 24),
              ElevatedButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: Text(widget.customer == null ? 'Add Customer' : 'Update'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16))),
            ],
          ),
        ),
      ),
    );
  }
}