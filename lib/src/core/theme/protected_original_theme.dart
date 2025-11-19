// DO NOT MODIFY: Protected snapshot of the original theme palette
// This file stores the original theme colors used as the app's "varsayilan" (default)
// theme. Keep this as a read-only reference — do not edit unless you intentionally
// want to change the preserved original theme.

import 'package:flutter/material.dart';

// Original header / app bar purple
const Color protectedHeaderPurple = Color(0xFF8B5CF6); // #8B5CF6

// Original radio card gradient colors
const Color protectedCardPurple = Color(0xFF9333EA);
const Color protectedCardPurpleDark = Color(0xFF7C3AED);
const Color protectedGradientPurple = Color(0xFF764BA2);

const LinearGradient protectedRadioCardGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [protectedCardPurple, protectedCardPurpleDark, protectedGradientPurple],
);

// Other important original colors
const Color protectedWhite = Color(0xFFFFFFFF);
const Color protectedLightBackground = Color(0xFFFFFFFF);
const Color protectedLightText = Color(0xFF000000);

// Marker name for the protected theme
const String protectedOriginalThemeName = 'varsayilan';
