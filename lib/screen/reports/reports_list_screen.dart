import 'package:flutter/material.dart';

class ReportListScreen extends StatelessWidget {
  const ReportListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Report List',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
