import 'dart:ui';

import 'package:dorry/app_theme.dart';
import 'package:dorry/constants.dart';
import 'package:dorry/controller/auth_controller.dart';
import 'package:dorry/router.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'firebase_options.dart';

///todo remove form here
BuildContext? appContext;
late PackageInfo packageInfo;
bool showDeleteButton = false;

void main() async {
  //only portrait mode
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await fetchBuildNumber();
  if (kReleaseMode) {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  Get.put(AuthController());
  runApp(const MyApp());
}

Future<void> fetchBuildNumber() async {
  packageInfo = await PackageInfo.fromPlatform();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilSingleton(
      options: const ScreenUtilOptions(
        enable: true,
        designSize: Size(360, 690),
        // fontFactorByWidth: 2.0,
        // fontFactorByHeight: 1.0,
        flipSizeWhenLandscape: true,
      ),
      child: MaterialApp.router(
        title: Constants.appTitle,
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar', 'SA'),
        supportedLocales: const [
          Locale('ar', 'SA'),
          Locale('en', 'US'),
        ],
        routerDelegate: router.routerDelegate,
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
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
        theme: appTheme,
      ),
    );
  }
}
