import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:new_test_app/features/settings/pages/settings_page.dart';
import 'home_page.dart';
import 'owner_bookings_page.dart';

class HomeOwnerWrapper extends StatefulWidget {
  const HomeOwnerWrapper({super.key});

  @override
  State<HomeOwnerWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeOwnerWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const OwnerBookingsPage(),
    SettingsPage(),
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
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'.tr),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'bookings'.tr,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'settings'.tr,
          ),
        ],
      ),
    );
  }
}
