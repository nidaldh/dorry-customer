import 'package:dorry/main.dart';
import 'package:dorry/screen/appointments/appointment_details_screen.dart';
import 'package:dorry/screen/auth/forget_password_screen.dart';
import 'package:dorry/screen/auth/verify_otp_screen.dart';
import 'package:dorry/screen/customer/customer_form_screen.dart';
import 'package:dorry/screen/customer/favorite_stores_screen.dart';
import 'package:dorry/screen/developer/developer_info_screen.dart';
import 'package:dorry/screen/home_screen.dart';
import 'package:dorry/screen/auth/login_screen.dart';
import 'package:dorry/screen/auth/signup_screen.dart';
import 'package:dorry/screen/splash_screen.dart';
import 'package:dorry/screen/store/confirm_booking_screen.dart';
import 'package:dorry/screen/store/partner_selection_screen.dart';
import 'package:dorry/screen/store/store_details_screen.dart';
import 'package:dorry/screen/update_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: splashPath,
      builder: (context, state) {
        appContext = context;
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: signUpPath,
      builder: (context, state) {
        appContext = context;
        return const SignUpScreen();
      },
    ),
    //verify-otp
    GoRoute(
      path: '/verify-otp',
      builder: (context, state) {
        appContext = context;
        return const VerifyOtpScreen();
      },
    ),
    GoRoute(
      path: forgetPasswordPath,
      builder: (context, state) {
        appContext = context;
        return const ForgetPasswordScreen();
      },
    ),
    GoRoute(
      path: loginPath,
      builder: (context, state) {
        appContext = context;
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: homePath,
      builder: (context, state) {
        appContext = context;
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: storePath,
      builder: (context, state) {
        appContext = context;
        final dynamic storeId = state.pathParameters['storeId'];
        return StoreDetailScreen(storeId: storeId);
      },
    ),
    GoRoute(
      path: confirmBookingPath,
      builder: (context, state) {
        appContext = context;
        final extra = state.extra as Map<String, dynamic>;
        final selectedPartner = extra['selectedPartner'];
        final selectedSlot = extra['selectedSlot'];
        final bookingCart = extra['bookingCart'];
        return ConfirmBookingScreen(
          selectedPartner: selectedPartner,
          selectedSlot: selectedSlot,
          bookingCart: bookingCart,
        );
      },
    ),
    GoRoute(
      path: partnerSelectionPath,
      builder: (context, state) {
        appContext = context;
        final extra = state.extra as Map<String, dynamic>;
        final storeId = extra['storeId'];
        final bookingCart = extra['bookingCart'];
        return PartnerSelectionScreen(
          storeId: storeId,
          bookingCart: bookingCart,
        );
      },
    ),
    GoRoute(
      path: appointmentPath,
      builder: (context, state) {
        appContext = context;
        return AppointmentDetailsScreen(
            appointmentId: state.pathParameters['id']);
      },
    ),
    GoRoute(
      path: developerInfoPath,
      builder: (context, state) {
        appContext = context;
        return const DeveloperInfoScreen();
      },
    ),
    //needUpdatePath
    GoRoute(
      path: needUpdatePath,
      builder: (context, state) {
        appContext = context;
        return const UpdateScreen();
      },
    ),
    GoRoute(
      path: customerFormPath,
      builder: (context, state) {
        appContext = context;
        return const CustomerFormScreen();
      },
    ),
    GoRoute(
      path: favoriteStoresPath,
      builder: (context, state) {
        appContext = context;
        return const FavoriteStoresScreen();
      },
    )
  ],
);

void popUntilPath(BuildContext context, String routePath) {
  while (
      router.routerDelegate.currentConfiguration.matches.last.matchedLocation !=
          routePath) {
    if (!context.canPop()) {
      return;
    }
    router.pop();
  }
}

//redirect path variable
String? redirectPath;
Object? redirectExtra;

const String splashPath = '/';
const String signUpPath = '/sign-up';
const String forgetPasswordPath = '/forget-password';
const String loginPath = '/login';
const String homePath = '/home';
const String storePath = '/store/:storeId';
const String confirmBookingPath = '/confirm-booking';
const String partnerSelectionPath = '/partner-selection';
const String appointmentPath = '/appointment/:id';
const String developerInfoPath = '/developer-info';
const String needUpdatePath = '/update';
const String customerFormPath = '/customer-form';
const String favoriteStoresPath = '/favorite-stores';
