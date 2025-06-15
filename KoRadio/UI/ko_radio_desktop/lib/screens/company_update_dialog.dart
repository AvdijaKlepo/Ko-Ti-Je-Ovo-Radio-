import 'package:flutter/material.dart';
import 'package:ko_radio_desktop/models/company.dart';

class CompanyUpdateDialog extends StatefulWidget {
  const CompanyUpdateDialog({super.key, required this.company});
  final Company company;

  @override
  State<CompanyUpdateDialog> createState() => _CompanyUpdateDialogState();
}

class _CompanyUpdateDialogState extends State<CompanyUpdateDialog> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Company'),
      ),
      
    );
  }
}