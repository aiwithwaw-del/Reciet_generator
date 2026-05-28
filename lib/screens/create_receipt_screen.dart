import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../models/receipt.dart';
import '../services/database.dart';

class CreateReceiptScreen extends StatefulWidget {
  final Customer customer;
  const CreateReceiptScreen({super.key, required this.customer});

  @override
  State<CreateReceiptScreen> createState() => _CreateReceiptScreenState();
}

class _CreateReceiptScreenState extends State<CreateReceiptScreen> {
  final List<ReceiptItem> _items = [];
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _paidCtrl = TextEditingController();

  void _addItem() {
    if (_nameCtrl.text.isEmpty || _qtyCtrl.text.isEmpty || _priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill all item fields'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _items.add(ReceiptItem(
        name: _nameCtrl.text,
        quantity: int.parse(_qtyCtrl.text),
        unitPrice: double.parse(_priceCtrl.text),
      ));
      _nameCtrl.clear();
      _qtyCtrl.clear();
      _priceCtrl.clear();
    });
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  Future<void> _saveReceipt() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one item'), backgroundColor: Colors.red),
      );
      return;
    }

    final paid = double.tryParse(_paidCtrl.text) ?? 0.0;
    final total = _items.fold(0.0, (sum, item) => sum + item.subtotal);

    if (paid > total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paid cannot exceed total'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final receipt = Receipt(
        customerId: widget.customer.id,
        customerName: widget.customer.name,
        items: _items,
        paidAmount: paid,
      );

      await DatabaseService().addReceipt(receipt);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Receipt saved! Balance: UGX ${NumberFormat("#,##0").format(receipt.loanAmount)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _items.fold(0.0, (sum, item) => sum + item.subtotal);
    final paid = double.tryParse(_paidCtrl.text) ?? 0.0;
    final balance = total - paid;

    return Scaffold(
      appBar: AppBar(title: Text('Receipt - ${widget.customer.name}')),
      body: Column(
        children: [
          Expanded(
            child: _items.isEmpty
                ? const Center(child: Text('No items added', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text('${item.quantity} x UGX ${NumberFormat("#,##0").format(item.unitPrice)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('UGX ${NumberFormat("#,##0").format(item.subtotal)}', 
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeItem(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[100], border: Border(top: BorderSide(color: Colors.grey[300]!))),
            child: Column(
              children: [
                TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Item Name', border: OutlineInputBorder(), filled: true)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TextField(controller: _qtyCtrl, decoration: const InputDecoration(labelText: 'Qty', border: OutlineInputBorder(), filled: true), keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: _priceCtrl, decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder(), filled: true), keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(onPressed: _addItem, icon: const Icon(Icons.add), label: const Text('Add Item')),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, -2))]),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Total:', style: TextStyle(fontSize: 16)),
                  Text('UGX ${NumberFormat("#,##0").format(total)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 8),
                TextField(controller: _paidCtrl, decoration: const InputDecoration(labelText: 'Amount Paid', border: OutlineInputBorder(), prefixText: 'UGX '), keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Balance:', style: TextStyle(fontSize: 16, color: balance > 0 ? Colors.red : Colors.green)),
                  Text('UGX ${NumberFormat("#,##0").format(balance)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: balance > 0 ? Colors.red : Colors.green)),
                ]),
                const SizedBox(height: 12),
                ElevatedButton.icon(onPressed: _saveReceipt, icon: const Icon(Icons.save), label: const Text('Save Receipt'), style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}