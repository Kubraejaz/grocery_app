// lib/screens/addresses_screen.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Addresses')),
      backgroundColor: AppTheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: const [
                  Card(
                    child: ListTile(
                      title: Text('Home'),
                      subtitle: Text('123 Main Street, City'),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Add Address'),
                  content: const Text('Address form not implemented.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                  ],
                ),
              ),
              child: const Text('Add New Address'),
            ),
          ],
        ),
      ),
    );
  }
}
