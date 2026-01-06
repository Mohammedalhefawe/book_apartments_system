import 'package:flutter/material.dart';
import 'package:new_test_app/features/home_admin/pages/manage_apartment_page.dart';
import 'package:new_test_app/features/home_admin/pages/manage_requests_page.dart';

class HomeWrapperAdmin extends StatefulWidget {
  const HomeWrapperAdmin({super.key});

  @override
  State<HomeWrapperAdmin> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapperAdmin> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminPendingUsersPage(),
    const AdminPendingApartmentsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'طلبات التسجيل',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_outlined),
            label: 'الشقق المعلقة',
          ),
        ],
      ),
    );
  }
}
