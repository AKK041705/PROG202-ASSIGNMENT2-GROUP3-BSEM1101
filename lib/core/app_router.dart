import 'package:flutter/material.dart';

import '../models/models.dart';
import '../screens/admin/admin_passengers_screen.dart';
import '../screens/admin/admin_requests_screen.dart';
import '../screens/admin/admin_shell.dart';
import '../screens/admin/fare_edit_screen.dart';
import '../screens/admin/review_report_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/social_login_screen.dart';
import '../screens/common/about_screen.dart';
import '../screens/common/fares_screen.dart';
import '../screens/common/notifications_view.dart';
import '../screens/common/place_picker_screen.dart';
import '../screens/common/profile_view.dart';
import '../screens/common/settings_screen.dart';
import '../screens/common/driver_profile_screen.dart';
import '../screens/common/payment_screen.dart';
import '../screens/common/receipt_screen.dart';
import '../screens/common/request_details_screen.dart';
import '../screens/common/trip_map_screen.dart';
import '../screens/driver/driver_shell.dart';
import '../screens/passenger/drivers_screen.dart';
import '../screens/passenger/my_reports_screen.dart';
import '../screens/passenger/review_screen.dart';
import '../screens/passenger/passenger_shell.dart';
import '../screens/passenger/report_fare_screen.dart';
import '../screens/passenger/request_transport_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/welcome_screen.dart';
import '../state/app_state.dart';
import 'app_routes.dart';

/// Turns a route name (and any data passed with it) into a screen.
class AppRouter {
  AppRouter._();

  /// Screens that need a logged-in user. Anyone else is sent to the welcome screen.
  static const Set<String> _protected = {
    AppRoutes.passenger,
    AppRoutes.driver,
    AppRoutes.admin,
    AppRoutes.requestTransport,
    AppRoutes.requestDetails,
    AppRoutes.reportFare,
    AppRoutes.myReports,
    AppRoutes.notifications,
    AppRoutes.profile,
    AppRoutes.fareEdit,
    AppRoutes.reviewReport,
    AppRoutes.adminPassengers,
    AppRoutes.adminRequests,
    AppRoutes.tripMap,
    AppRoutes.payment,
    AppRoutes.receipt,
    AppRoutes.drivers,
    AppRoutes.driverProfile,
    AppRoutes.review,
  };

  static Route<dynamic> generate(RouteSettings settings) {
    final name = settings.name;
    if (_protected.contains(name) && AppState.instance.currentUser == null) {
      return _page(const WelcomeScreen(), settings);
    }

    switch (name) {
      case AppRoutes.splash:
        return _page(const SplashScreen(), settings);
      case AppRoutes.welcome:
        return _page(const WelcomeScreen(), settings);
      case AppRoutes.login:
        return _page(const LoginScreen(), settings);
      case AppRoutes.register:
        return _page(const RegisterScreen(), settings);
      case AppRoutes.guestFares:
        return _page(const FaresScreen(title: 'Browse fares'), settings);
      case AppRoutes.socialLogin:
        final provider = settings.arguments is String
            ? settings.arguments! as String
            : 'Google';
        return _page(SocialLoginScreen(provider: provider), settings);
      case AppRoutes.placePicker:
        final args = settings.arguments;
        final title = args is String
            ? args
            : args is Map && args['title'] is String
                ? args['title'] as String
                : 'Choose a place';
        final allowCustom = args is Map && args['allowCustom'] == true;
        return _page(PlacePickerScreen(title: title, allowCustom: allowCustom),
            settings);

      case AppRoutes.passenger:
        return _page(const PassengerShell(), settings);
      case AppRoutes.driver:
        return _page(const DriverShell(), settings);
      case AppRoutes.admin:
        return _page(const AdminShell(), settings);

      case AppRoutes.fares:
        return _page(FaresScreen(initialRoute: _routeArgs(settings)), settings);
      case AppRoutes.compare:
        return _page(
          FaresScreen(
            title: 'Compare transportation',
            startOnCompare: true,
            initialRoute: _routeArgs(settings),
          ),
          settings,
        );
      case AppRoutes.drivers:
        return _page(const DriversScreen(), settings);
      case AppRoutes.driverProfile:
        final driverName =
            settings.arguments is String ? settings.arguments! as String : '';
        return _page(DriverProfileScreen(username: driverName), settings);
      case AppRoutes.review:
        final reviewId =
            settings.arguments is String ? settings.arguments! as String : '';
        return _page(ReviewScreen(requestId: reviewId), settings);
      case AppRoutes.settings:
        return _page(const SettingsScreen(), settings);
      case AppRoutes.requestTransport:
        final mode =
            settings.arguments is String ? settings.arguments! as String : null;
        return _page(RequestTransportScreen(initialMode: mode), settings);
      case AppRoutes.tripMap:
        final tripId =
            settings.arguments is String ? settings.arguments! as String : '';
        return _page(TripMapScreen(requestId: tripId), settings);
      case AppRoutes.payment:
        final payId =
            settings.arguments is String ? settings.arguments! as String : '';
        return _page(PaymentScreen(requestId: payId), settings);
      case AppRoutes.receipt:
        final receiptId =
            settings.arguments is String ? settings.arguments! as String : '';
        return _page(ReceiptScreen(requestId: receiptId), settings);
      case AppRoutes.requestDetails:
        final id =
            settings.arguments is String ? settings.arguments! as String : '';
        return _page(RequestDetailsScreen(requestId: id), settings);
      case AppRoutes.reportFare:
        return _page(const ReportFareScreen(), settings);
      case AppRoutes.myReports:
        return _page(const MyReportsScreen(), settings);
      case AppRoutes.notifications:
        return _page(const NotificationsScreen(), settings);
      case AppRoutes.profile:
        return _page(const ProfileScreen(), settings);
      case AppRoutes.about:
        return _page(const AboutScreen(), settings);

      case AppRoutes.fareEdit:
        final tariff =
            settings.arguments is Tariff ? settings.arguments! as Tariff : null;
        return _page(FareEditScreen(tariff: tariff), settings);
      case AppRoutes.adminPassengers:
        return _page(const AdminPassengersScreen(), settings);
      case AppRoutes.adminRequests:
        final filter =
            settings.arguments is String ? settings.arguments! as String : null;
        return _page(AdminRequestsScreen(initialFilter: filter), settings);
      case AppRoutes.reviewReport:
        final id =
            settings.arguments is String ? settings.arguments! as String : '';
        return _page(ReviewReportScreen(reportId: id), settings);
    }
    return _page(const WelcomeScreen(), settings);
  }

  /// Reads an optional [pickup, destination] pair passed with the route.
  static List<String>? _routeArgs(RouteSettings settings) {
    final args = settings.arguments;
    if (args is List<String> && args.length == 2) return args;
    return null;
  }

  static MaterialPageRoute<dynamic> _page(
      Widget screen, RouteSettings settings) {
    return MaterialPageRoute<dynamic>(
        builder: (context) => screen, settings: settings);
  }
}
