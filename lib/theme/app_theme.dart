import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Custom page transition that's playful, fast, and tablet-optimized
class PlayfulPageTransitionsBuilder extends PageTransitionsBuilder {
  const PlayfulPageTransitionsBuilder();

  @override
  Widget buildTransitions<T extends Object?>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final bool isTablet = mediaQuery.size.shortestSide >= 600;

    // Use different animations for tablets vs phones for optimal UX
    if (isTablet) {
      return _buildTabletTransition(animation, secondaryAnimation, child);
    } else {
      return _buildMobileTransition(animation, secondaryAnimation, child);
    }
  }

  Widget _buildTabletTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // For tablets: Smooth scale and fade with subtle rotation for playfulness
    final scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart));

    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.1, 1.0, curve: Curves.easeOut),
      ),
    );

    final rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart));

    // Secondary animation for the outgoing page (subtle zoom out)
    final secondaryScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOutQuart),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          children: [
            // Outgoing page with subtle scale down
            if (secondaryAnimation.value > 0)
              Transform.scale(
                scale: secondaryScaleAnimation.value,
                child: child,
              ),
            // Incoming page with playful entrance
            Transform.rotate(
              angle: rotationAnimation.value,
              child: Transform.scale(
                scale: scaleAnimation.value,
                child: Opacity(opacity: fadeAnimation.value, child: child),
              ),
            ),
          ],
        );
      },
      child: child,
    );
  }

  Widget _buildMobileTransition(
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // For mobile: Fast slide with bounce and scale for playfulness
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart));

    final scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.elasticOut));

    final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    // Secondary animation for outgoing page
    final secondarySlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.2, 0.0),
    ).animate(
      CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOutQuart),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          children: [
            // Outgoing page slides left
            if (secondaryAnimation.value > 0)
              SlideTransition(position: secondarySlideAnimation, child: child),
            // Incoming page with playful entrance
            SlideTransition(
              position: slideAnimation,
              child: Transform.scale(
                scale: scaleAnimation.value,
                child: Opacity(opacity: fadeAnimation.value, child: child),
              ),
            ),
          ],
        );
      },
      child: child,
    );
  }
}

class AppTheme {
  // Colors
  static const Color appBlue = Color(0xFF0066CC);
  static const Color appRed = Color(0xFFE60012);
  static const Color appOrange = Color(0xFFFF6600);
  static const Color appGreen = Color(0xFF00AA44);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.fredoka().fontFamily,
      textTheme: GoogleFonts.fredokaTextTheme(),
      colorScheme: ColorScheme.fromSeed(
        seedColor: appBlue,
        brightness: Brightness.light,
        primary: appBlue,
        secondary: appOrange,
        tertiary: appGreen,
        error: appRed,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 4,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PlayfulPageTransitionsBuilder(),
          TargetPlatform.iOS: PlayfulPageTransitionsBuilder(),
          TargetPlatform.fuchsia: PlayfulPageTransitionsBuilder(),
          TargetPlatform.linux: PlayfulPageTransitionsBuilder(),
          TargetPlatform.macOS: PlayfulPageTransitionsBuilder(),
          TargetPlatform.windows: PlayfulPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.fredoka().fontFamily,
      textTheme: GoogleFonts.fredokaTextTheme(ThemeData.dark().textTheme),
      colorScheme: ColorScheme.fromSeed(
        seedColor: appBlue,
        brightness: Brightness.dark,
        primary: appBlue,
        secondary: appOrange,
        tertiary: appGreen,
        error: appRed,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 4,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PlayfulPageTransitionsBuilder(),
          TargetPlatform.iOS: PlayfulPageTransitionsBuilder(),
          TargetPlatform.fuchsia: PlayfulPageTransitionsBuilder(),
          TargetPlatform.linux: PlayfulPageTransitionsBuilder(),
          TargetPlatform.macOS: PlayfulPageTransitionsBuilder(),
          TargetPlatform.windows: PlayfulPageTransitionsBuilder(),
        },
      ),
    );
  }
}
