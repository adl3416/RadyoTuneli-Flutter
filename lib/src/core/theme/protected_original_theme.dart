// DO NOT MODIFY: Protected snapshot of the original theme palette
// This file stores the original theme colors used as the app's "varsayilan" (default)
// theme. Keep this as a read-only reference — do not edit unless you intentionally
// want to change the preserved original theme.

import 'package:flutter/material.dart';

// Original header / app bar blue
const Color protectedHeaderPurple = Color(0xFF1D4ED8); // #1D4ED8 - Elektrik mavi

// Original radio card gradient colors
const Color protectedCardPurple = Color(0xFF1E40AF);
const Color protectedCardPurpleDark = Color(0xFF1E3A8A);
const Color protectedGradientPurple = Color(0xFF0D2644);

const LinearGradient protectedRadioCardGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [protectedCardPurple, protectedCardPurpleDark, protectedGradientPurple],
);

// Other important original colors
const Color protectedWhite = Color(0xFFFFFFFF);
const Color protectedLightBackground = Color(0xFFF0F4FF);
const Color protectedLightText = Color(0xFF0F1F3D);

// Marker name for the protected theme
const String protectedOriginalThemeName = 'varsayilan';
