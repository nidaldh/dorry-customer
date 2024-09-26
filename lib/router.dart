import 'package:dorry/main.dart';
import 'package:dorry/screen/appointments/appointment_details_screen.dart';
import 'package:dorry/screen/auth/forget_password_screen.dart';
import 'package:dorry/screen/home_screen.dart';
import 'package:dorry/screen/auth/login_screen.dart';
import 'package:dorry/screen/auth/signup_screen.dart';
import 'package:dorry/screen/splash_screen.dart';
import 'package:dorry/screen/store/confirm_booking_screen.dart';
import 'package:dorry/screen/store/partner_selection_screen.dart';
import 'package:dorry/screen/store/store_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        appContext = context;
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/sign-up',
      builder: (context, state) {
        appContext = context;
        return const SignUpScreen();
      },
    ),
    GoRoute(
      path: '/forget-password',
      builder: (context, state) {
        appContext = context;
        return const ForgetPasswordScreen();
      },
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) {
        appContext = context;
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        appContext = context;
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/store/:storeId',
      builder: (context, state) {
        appContext = context;
        final dynamic storeId = state.pathParameters['storeId'];
        return SalonDetailScreen(storeId: storeId);
      },
    ),
    GoRoute(
      path: '/confirm-booking',
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
      path: '/partner-selection',
      builder: (context, state) {
        appContext = context;
        final extra = state.extra as Map<String, dynamic>;
        final partners = extra['partners'];
        final bookingCart = extra['bookingCart'];
        return PartnerSelectionScreen(
          partners: partners,
          bookingCart: bookingCart,
        );
      },
    ),
    GoRoute(
      path: '/appointment/:id',
      builder: (context, state) {
        appContext = context;
        return AppointmentDetailsScreen(
            appointmentId: state.pathParameters['id']);
      },
    ),
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
