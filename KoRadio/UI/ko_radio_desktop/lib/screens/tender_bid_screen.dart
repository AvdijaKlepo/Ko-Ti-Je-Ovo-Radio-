import 'package:flutter/material.dart';
import 'package:ko_radio_desktop/models/job.dart';

class TenderBidScreen extends StatefulWidget {
  const TenderBidScreen({required this.tender,super.key});
  final Job tender;

  @override
  State<TenderBidScreen> createState() => _TenderBidScreenState();
}

class _TenderBidScreenState extends State<TenderBidScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}