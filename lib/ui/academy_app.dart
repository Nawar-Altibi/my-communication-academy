import 'dart:async';
import 'package:flutter/material.dart';
import '../data/course_repository.dart';
import '../data/local_store.dart';
import '../l10n/app_localizations.dart';
import '../state/catalog_controller.dart';
import 'catalog_page.dart';
export 'detail_body.dart';
export 'course_widgets.dart';

class AcademyApp extends StatefulWidget {
  const AcademyApp({super.key, required this.repository, this.store});
  final CourseRepository repository;
  final LocalStore? store;
  @override
  State<AcademyApp> createState() => _AcademyAppState();
}

class _AcademyAppState extends State<AcademyApp> {
  late final controller = CatalogController(
    widget.repository,
    store: widget.store,
  );
  @override
  void initState() {
    super.initState();
    unawaited(controller.initialize());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final arabic = controller.language == 'ar';
      final family = arabic ? 'NotoSansArabic' : 'Manrope';
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'My Communication Academy',
        locale: Locale(controller.language),
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: family,
          fontFamilyFallback: const ['NotoSansArabic'],
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
          scaffoldBackgroundColor: const Color(0xFFF6F8FA),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            centerTitle: false,
            titleSpacing: 16,
            shape: Border(bottom: BorderSide(color: Color(0xFFE4E9EE))),
          ),
          chipTheme: const ChipThemeData(
            showCheckmark: false,
            side: BorderSide(color: Color(0xFFDDE3E8)),
            shape: StadiumBorder(),
          ),
          textTheme: ThemeData.light().textTheme.apply(
            fontFamily: family,
            fontFamilyFallback: const ['NotoSansArabic'],
            bodyColor: const Color(0xFF172B4D),
            displayColor: const Color(0xFF172B4D),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE4E9EE)),
            ),
          ),
        ),
        home: CatalogPage(controller: controller),
      );
    },
  );
}
