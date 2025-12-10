import 'package:flutter/material.dart';
import 'package:hidaya_app/Utils/colors.dart';
import 'CustomIcons.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  CustomBottomNavigation({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home_filled, 'label': 'Home'},
    {'icon': CustomICons.quran__1_, 'label': 'Quran'},
    {'icon': Icons.chat, 'label': 'Chat'},
    {'icon': Icons.settings, 'label': 'Settings'}, // Changed duplicate 'Profile' to 'Book'
  ];

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 70,
      padding: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_navItems.length, (index) {
          bool isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onItemTapped(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _navItems[index]['icon'],
                  color: isSelected ? AppColors.main : AppColors.unselected,
                  size: 25,
                ),
                SizedBox(height: 5,),
                Text(
                  _navItems[index]['label'],
                  style: TextStyle(
                    color: isSelected ? AppColors.main : AppColors.unselected,
                    fontSize: 10,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}