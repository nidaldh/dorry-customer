import 'package:dorry/screen/appointments/appointment_list_screen.dart';
import 'package:dorry/screen/customer/customer_info_screen.dart';
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
    const AppointmentsListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_currentIndex], // Display the selected page
      ),
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
            label: 'المعلومات الشخصية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'قائمة المتاجر',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'قائمة المواعيد',
          ),
        ],
        selectedItemColor: Colors.blue, // Highlight color for selected item
        unselectedItemColor: Colors.grey, // Color for unselected items
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold), // Style for selected label
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal), // Style for unselected label
        type: BottomNavigationBarType.fixed, // Type to allow text to be displayed
        backgroundColor: Colors.white, // Background color
        elevation: 10, // Elevation for shadow effect
      ),
    );
  }
}