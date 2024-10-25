import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Users',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.swap_horiz),
          label: 'Conversions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.attach_money),
          label: 'Currencies',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.miscellaneous_services),
          label: 'Services',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: Colors.tealAccent,
      unselectedItemColor: Colors.white54,
      backgroundColor: const Color(0xFF1E1E1E),
      showUnselectedLabels: true,
      elevation: 10,
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
    );
  }
}
