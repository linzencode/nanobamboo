import 'package:flutter/material.dart';

/// Feature model
class FeatureModel {
  FeatureModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
}




