import 'package:dorry/screen/customer/customer_info_screen.dart';
import 'package:dorry/screen/reports/reports_list_screen.dart';
import 'package:dorry/screen/store/store_list_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // List of pages corresponding to each tab
  final List<Widget> _pages = [
    const CustomerInfoScreen(),
    const StoreListScreen(),
    const ReportListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Customer Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Store List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Report List',
          ),
        ],
      ),
    );
  }
}
