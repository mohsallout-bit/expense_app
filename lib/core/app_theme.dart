import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Colors.deepPurple;
  static const Color secondary = Colors.amber;
  static const Color background = Color(0xFFF5F5F5);
  static const Color text = Color(0xFF1C1B1F);
  static const Color surface = Colors.white;
  static const Color error = Colors.red;
}

class AppSizes {
  // أحجام الخطوط
  static const double displayLarge = 32; // عناوين رئيسية كبيرة
  static const double displayMedium = 28; // عناوين رئيسية متوسطة
  static const double displaySmall = 24; // عناوين رئيسية صغيرة
  static const double headingLarge = 22; // عناوين ثانوية كبيرة
  static const double headingMedium = 20; // عناوين ثانوية متوسطة
  static const double bodyLarge = 17; // نص أساسي كبير
  static const double bodyMedium = 15; // نص أساسي متوسط
  static const double bodySmall = 13; // نص أساسي صغير

  // التباعد والهوامش
  static const double spacing = 8; // تباعد قياسي
  static const double spacingSmall = 4; // تباعد صغير
  static const double spacingMedium = 12; // تباعد متوسط
  static const double spacingLarge = 16; // تباعد كبير
  static const double spacingXLarge = 24; // تباعد كبير جداً

  // نصف قطر الحواف
  static const double radiusSmall = 8; // حواف دائرية صغيرة
  static const double radiusMedium = 12; // حواف دائرية متوسطة
  static const double radiusLarge = 16; // حواف دائرية كبيرة
  static const double radiusXLarge = 24; // حواف دائرية كبيرة جداً
}

class AppTheme {
  static const Color primaryColor = AppColors.primary;
  static const Color secondaryColor = AppColors.secondary;

  static TextStyle get displayStyle => const TextStyle(
    fontSize: AppSizes.displayMedium,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
    height: 1.3,
  );

  static TextStyle get headingStyle => const TextStyle(
    fontSize: AppSizes.headingLarge,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    height: 1.3,
  );

  static TextStyle get bodyStyle => const TextStyle(
    fontSize: AppSizes.bodyLarge,
    color: AppColors.text,
    height: 1.5,
  );

  static TextStyle get labelStyle => const TextStyle(
    fontSize: AppSizes.bodyMedium,
    color: AppColors.primary,
    height: 1.4,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.deepPurple,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.primary,
        toolbarHeight: 60,
        titleTextStyle: headingStyle.copyWith(
          color: Colors.white,
          fontSize: AppSizes.headingMedium,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        elevation: 4,
        extendedPadding: const EdgeInsets.all(AppSizes.spacingLarge),
        largeSizeConstraints: const BoxConstraints.tightFor(
          width: 64,
          height: 64,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingLarge,
          vertical: AppSizes.spacing,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingLarge,
          vertical: AppSizes.spacingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 8,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: AppSizes.bodySmall),
        unselectedLabelStyle: TextStyle(fontSize: AppSizes.bodySmall),
      ),
      textTheme: TextTheme(
        displayLarge: displayStyle,
        headlineLarge: headingStyle,
        bodyLarge: bodyStyle,
        labelLarge: labelStyle,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: labelStyle,
        contentPadding: const EdgeInsets.all(AppSizes.spacingLarge),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacingXLarge,
            vertical: AppSizes.spacingLarge,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          textStyle: bodyStyle.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
