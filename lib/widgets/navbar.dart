import 'package:flutter/material.dart';
import 'package:ltb_app/screens/add_event_screen.dart';
import 'package:ltb_app/screens/chat_screen.dart';
import 'package:ltb_app/screens/home_screen.dart';
import 'package:ltb_app/screens/notice_screen.dart';
import 'package:ltb_app/screens/profile_screen.dart';
import 'package:ltb_app/widgets/appbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // List of screens for each tab
  final List<Widget> _screens = [
    const HomeScreen(),
    const ChatScreen(),
    const AddEventScreen(),
    const NoticeScreen(),
    const ProfileScreen(),
  ];

  // Handle tab selection
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: _screens[_currentIndex], // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Highlight the selected tab
        onTap: _onTabTapped, // Handle tab selection
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_rounded),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline_rounded),
            label: 'Add Event',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notice',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        backgroundColor: const Color(0xff181818),
        selectedItemColor: Colors.white, // Color for selected tab
        unselectedItemColor: Colors.grey[600], // Color for unselected tabs
        type:
            BottomNavigationBarType.fixed, // Fixes layout if more than 3 items
      ),
    );
  }
}
