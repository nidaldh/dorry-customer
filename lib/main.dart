import 'package:dorry/app_theme.dart';
import 'package:dorry/constants.dart';
import 'package:dorry/controller/auth_controller.dart';
import 'package:dorry/screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

void main() {
  Get.put(AuthController());
  runApp(const MyApp());
}

BuildContext? appContext;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: Constants.appTitle,
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [
        Locale('ar', 'SA'),
        Locale('en', 'US'),
      ],
      defaultTransition: Transition.cupertino,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      // Set locale to Arabic
      theme: appTheme,
      home: const SplashScreen(),
    );
  }
}
