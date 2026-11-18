// lib/screens/addresses_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';

class Address {
  final String id;
  final String title;
  final String fullAddress;
  final String city;
  final String phone;

  Address({
    required this.id,
    required this.title,
    required this.fullAddress,
    required this.city,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'fullAddress': fullAddress,
        'city': city,
        'phone': phone,
      };

  factory Address.fromJson(Map<String, dynamic> j) => Address(
        id: j['id'] as String,
        title: j['title'] as String,
        fullAddress: j['fullAddress'] as String,
        city: j['city'] as String,
        phone: j['phone'] as String,
      );
}

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<Address> _addresses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList('user_saved_addresses') ?? [];
    setState(() {
      _addresses = rawList.map((e) => Address.fromJson(jsonDecode(e))).toList();
      _loading = false;
    });
  }

  Future<void> _saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = _addresses.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList('user_saved_addresses', rawList);
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController(text: 'Home');
    final addrCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Delivery Address'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Label (e.g. Home, Work)'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: addrCtrl,
                  decoration: const InputDecoration(labelText: 'Street Address'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: cityCtrl,
                  decoration: const InputDecoration(labelText: 'City'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final newAddr = Address(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleCtrl.text.trim(),
                fullAddress: addrCtrl.text.trim(),
                city: cityCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
              );
              setState(() => _addresses.add(newAddr));
              await _saveAddresses();
              if (!mounted) return;
              Navigator.pop(context);
              Helpers.showSnack(context, 'Address added successfully');
            },
            child: const Text('Save Address'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAddress(int index) async {
    setState(() => _addresses.removeAt(index));
    await _saveAddresses();
    if (!mounted) return;
    Helpers.showSnack(context, 'Address removed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Addresses')),
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: _showAddDialog,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 14),
                      const Text('No saved addresses yet', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _showAddDialog,
                        child: const Text('Add Your First Address'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: _addresses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final addr = _addresses[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryLight.withOpacity(0.2),
                          child: const Icon(Icons.location_on, color: AppTheme.primary),
                        ),
                        title: Text(addr.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${addr.fullAddress}, ${addr.city}\nPhone: ${addr.phone}'),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                          onPressed: () => _deleteAddress(index),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
