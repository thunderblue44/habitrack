import 'package:flutter/material.dart';

class HabitIcons {
  static const Map<String, IconData> icons = {
    'water_drop': Icons.water_drop,
    'fitness_center': Icons.fitness_center,
    'book': Icons.book,
    'restaurant': Icons.restaurant,
    'smoking_rooms': Icons.smoking_rooms,
    'local_bar': Icons.local_bar,
    'code': Icons.code,
    'language': Icons.language,
    'laptop': Icons.laptop,
    'bedtime': Icons.bedtime,
    'self_improvement': Icons.self_improvement,
    'music_note': Icons.music_note,
    'brush': Icons.brush,
    'palette': Icons.palette,
    'directions_run': Icons.directions_run,
    'directions_bike': Icons.directions_bike,
    'directions_walk': Icons.directions_walk,
    'spa': Icons.spa,
    'star': Icons.star,
    'favorite': Icons.favorite,
    'timer': Icons.timer,
    'alarm': Icons.alarm,
    'nights_stay': Icons.nights_stay,
    'wb_sunny': Icons.wb_sunny,
    'medication': Icons.medication,
    'science': Icons.science,
    'eco': Icons.eco,
    'nature': Icons.nature,
    'money': Icons.attach_money,
    'shopping_cart': Icons.shopping_cart,
    'checkroom': Icons.checkroom,
    'savings': Icons.savings,
    'psychology': Icons.psychology,
    'menu_book': Icons.menu_book,
    'local_phone': Icons.local_phone,
    'message': Icons.message,
    'mail': Icons.mail,
    'person': Icons.person,
    'groups': Icons.groups,
    'home': Icons.home,
    'work': Icons.work,
    'school': Icons.school,
    'check': Icons.check_circle,
  };

  static IconData getIcon(String? iconName) {
    if (iconName == null || !icons.containsKey(iconName)) {
      return Icons.check_circle_outline;
    }
    return icons[iconName]!;
  }
}

class HabitColors {
  static const Map<String, Color> colors = {
    '#0088CC': Color(0xFF0088CC), // Blue
    '#FF5733': Color(0xFFFF5733), // Red/Orange
    '#FFC300': Color(0xFFFFC300), // Yellow
    '#4CAF50': Color(0xFF4CAF50), // Green
    '#9C27B0': Color(0xFF9C27B0), // Purple
    '#FF9800': Color(0xFFFF9800), // Orange
    '#00BCD4': Color(0xFF00BCD4), // Cyan
    '#F44336': Color(0xFFF44336), // Red
    '#607D8B': Color(0xFF607D8B), // Blue Grey
    '#E91E63': Color(0xFFE91E63), // Pink
    '#3F51B5': Color(0xFF3F51B5), // Indigo
    '#8BC34A': Color(0xFF8BC34A), // Light Green
  };

  static Color getColor(String? colorCode) {
    if (colorCode == null || !colors.containsKey(colorCode)) {
      return const Color(0xFF0088CC); // Default color
    }
    return colors[colorCode]!;
  }

  static List<String> getColorCodes() {
    return colors.keys.toList();
  }

  static List<Color> getColorsList() {
    return colors.values.toList();
  }
}
