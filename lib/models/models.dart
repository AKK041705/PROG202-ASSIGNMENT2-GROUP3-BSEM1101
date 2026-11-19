// Plain data classes used across the app (the "entities" from Assignment 1).

enum UserRole { passenger, driver, administrator }

extension UserRoleText on UserRole {
  String get label {
    switch (this) {
      case UserRole.passenger:
        return 'Passenger';
      case UserRole.driver:
        return 'Driver';
      case UserRole.administrator:
        return 'Administrator';
    }
  }
}

enum RequestStatus {
  pending,
  awaitingPassenger,
  confirmed,
  completed,
  cancelled
}

extension RequestStatusText on RequestStatus {
  String get label {
    switch (this) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.awaitingPassenger:
        return 'Awaiting Passenger';
      case RequestStatus.confirmed:
        return 'Confirmed';
      case RequestStatus.completed:
        return 'Completed';
      case RequestStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isActive =>
      this == RequestStatus.pending ||
      this == RequestStatus.awaitingPassenger ||
      this == RequestStatus.confirmed;
}

enum ReportStatus { pendingReview, underReview, closed }

extension ReportStatusText on ReportStatus {
  String get label {
    switch (this) {
      case ReportStatus.pendingReview:
        return 'Pending Review';
      case ReportStatus.underReview:
        return 'Under Review';
      case ReportStatus.closed:
        return 'Closed';
    }
  }
}

class AppUser {
  AppUser({
    required this.username,
    required this.password,
    required this.role,
    required this.name,
    required this.phone,
    this.driverType,
    this.vehicle,
    this.plate,
    this.verified = true,
    String currency = 'NLe',
    this.country = 'Sierra Leone',
    this.darkMode = false,
    this.accentName = 'green',
    this.suspended = false,
    this.suspendReason = '',
  })  : currency = currency,
        homeCurrency = currency;

  final String username;
  final String password;
  final UserRole role;
  final String name;
  final String phone;
  final String? driverType;
  final String? vehicle;
  final String? plate;
  bool verified;

  /// The administrator can suspend an account (for example after a serious report).
  bool suspended;
  String suspendReason;

  /// Currency shown beside prices ('NLe' means leones only).
  String currency;

  /// The currency this user started with (used by Restore defaults).
  final String homeCurrency;

  /// This user's own look: dark mode and accent colour (an AccentOption name).
  bool darkMode;
  String accentName;

  /// Country found from the phone number.
  final String country;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

/// One fare record. from == '*' means a flat "pole to pole" fare.
class Tariff {
  Tariff({
    required this.mode,
    required this.from,
    required this.to,
    this.fare,
    this.type = 'Per passenger',
    this.source = 'Official price list',
  });

  final String mode;
  final String from;
  final String to;
  double? fare;
  String type;
  String source;

  bool get isFlat => from == '*';

  bool matches(String a, String b) {
    if (isFlat) return false;
    return (from == a && to == b) || (from == b && to == a);
  }
}

/// The result of asking "what is the fare for this mode on this route?".
class FareQuote {
  const FareQuote({
    this.amount,
    required this.type,
    required this.source,
    this.flat = false,
    this.unavailableReason,
  });

  const FareQuote.unavailable(String reason)
      : amount = null,
        type = '',
        source = '',
        flat = false,
        unavailableReason = reason;

  final double? amount;
  final String type;
  final String source;
  final bool flat;
  final String? unavailableReason;

  bool get isAvailable => unavailableReason == null;
  bool get isNegotiated => isAvailable && amount == null;
  bool get isSimulated => source == 'Simulated estimate';
}

class TransportRequest {
  TransportRequest({
    required this.id,
    required this.passenger,
    required this.pickup,
    required this.destination,
    required this.mode,
    required this.people,
    required this.freeSeats,
    required this.fareText,
    this.note = '',
    this.payCurrency = 'NLe',
    this.payAmount,
    this.payRate,
    this.scheduledAt,
  });

  final String id;
  final String passenger;
  final String pickup;
  final String destination;
  final String mode;
  final int people;
  final int freeSeats;
  final String fareText;
  final String note;

  /// Currency the passenger chose to pay in, the amount in that currency, and the
  /// indicative NLe-per-unit rate used. Foreign payments are recorded as they are
  /// and are not converted to leones.
  final String payCurrency;
  final double? payAmount;
  final double? payRate;

  /// null means "now"; otherwise the time the passenger wants to travel.
  final DateTime? scheduledAt;

  DateTime? completedAt;

  bool get isScheduled => scheduledAt != null;

  /// Demo payment: no real money is taken in this prototype.
  bool paid = false;
  String? payMethod;
  DateTime? paidAt;
  RequestStatus status = RequestStatus.pending;
  String? driver;
  final List<String> declinedDrivers = [];
}

class FareReport {
  FareReport({
    required this.id,
    required this.passenger,
    required this.route,
    required this.mode,
    required this.reported,
    required this.note,
    required this.systemFare,
  });

  final String id;
  final String passenger;
  final String route;
  final String mode;
  final double reported;
  final String note;
  final String systemFare;
  ReportStatus status = ReportStatus.pendingReview;
  String response = '';
}

class AppNotification {
  AppNotification({required this.to, required this.text, this.requestId})
      : time = DateTime.now();

  final String to;
  final String text;

  /// When set, tapping the notification opens that request.
  final String? requestId;
  final DateTime time;
  bool read = false;
}

/// A passenger's rating and comment about a driver after a completed trip.
class Review {
  Review({
    required this.requestId,
    required this.driver,
    required this.passenger,
    required this.rating,
    required this.comment,
  }) : time = DateTime.now();

  final String requestId;
  final String driver;
  final String passenger;
  final int rating; // 1 to 5
  final String comment;
  final DateTime time;
}

/// A report about a driver or a passenger, sent to the administrator.
class UserReport {
  UserReport({
    required this.id,
    required this.reporter,
    required this.subject,
    required this.requestId,
    required this.text,
  }) : time = DateTime.now();

  final String id;
  final String reporter; // username of the person reporting
  final String subject; // username of the person reported
  final String requestId;
  final String text;
  final DateTime time;
  bool reviewed = false;
  String response = '';
}
