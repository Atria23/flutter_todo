// --- START OF FILE lib/theme/app_theme.dart ---
import 'package:flutter/material.dart';

// --- Colors ---
const Color primaryBlue = Color(0xFF3B82F6); // Brand blue
const Color darkGrey = Color(0xFF1F2937);   // Main text, active elements
const Color mediumGrey = Color(0xFF6B7280); // Secondary text, inactive elements
const Color lightGrey = Color(0xFFF3F4F6);  // Backgrounds, input fields
const Color accentRed = Color(0xFFEF4444); // For delete actions
const Color borderGrey = Color(0xFFD1D5DB); // Light border color

// --- Text Styles ---
const TextStyle headline1Style = TextStyle(
  color: darkGrey,
  fontWeight: FontWeight.w800,
  fontSize: 28,
  height: 1.2,
);

const TextStyle subtitle1Style = TextStyle(
  color: darkGrey,
  fontWeight: FontWeight.w700,
  fontSize: 16,
  height: 1.3,
);

const TextStyle body1Style = TextStyle(
  fontSize: 18,
  height: 1.4,
  fontWeight: FontWeight.w700,
  color: darkGrey,
);

const TextStyle body2Style = TextStyle(
  fontSize: 14,
  height: 1.4,
  color: mediumGrey,
);

const TextStyle metaStyle = TextStyle(
  fontSize: 12,
  height: 1.33,
  color: mediumGrey,
  fontWeight: FontWeight.w600,
);

const TextStyle chipTextStyle = TextStyle(
  fontWeight: FontWeight.w700,
  fontSize: 14,
);

// --- END OF FILE lib/theme/app_theme.dart ---