import 'package:flutter/foundation.dart';

abstract class Apis {
  static const String _mobileBaseUrl = 'http://10.0.2.2:8000';
  static const String _webBaseUrl = 'http://localhost:8000';

  static String get baseUrl {
    if (kIsWeb) {
      return _webBaseUrl;
    } else {
      return _mobileBaseUrl;
    }
  }

  static String register = '$baseUrl/api/register';
  static String login = '$baseUrl/api/login';
  static String adminPendingUsers = '$baseUrl/api/admin/users/pending';
  static String adminApproveUser(int id) =>
      '$baseUrl/api/admin/users/$id/approve';
  static String adminRejectUser(int id) =>
      '$baseUrl/api/admin/users/$id/reject';

  static String get adminPendingApartments =>
      '$baseUrl/api/admin/apartments/pending';
  static String adminApproveApartment(int id) =>
      '$baseUrl/api/admin/apartments/$id/approve';
  static String adminRejectApartment(int id) =>
      '$baseUrl/api/admin/apartments/$id/reject';
  // static String get approvedApartments => '$baseUrl/api/iapartments';
  static String get approvedApartments => '$baseUrl/api/iapartments';
  static String get addApartment => '$baseUrl/api/sapartments';
  static String get myBookings => '$baseUrl/api/my-bookings';
  static String get ownerPendingBookings =>
      '$baseUrl/api/owner/pending-bookings';
  static String get ownerBookings => '$baseUrl/api/owner/bookings';
  static String get notifications => '$baseUrl/api/notifications';
  static String ownerApproveBooking(int id) =>
      '$baseUrl/api/owner/bookings/$id/approve';
  static String ownerRejectBooking(int id) =>
      '$baseUrl/api/owner/bookings/$id/reject';
  static String bookApartment(int id) => '$baseUrl/api/apartments/$id/book';
  static String get favorites => '$baseUrl/api/favorites';
  static String addFavorite(int id) => '$baseUrl/api/favorites/add/$id';
  static String removeFavorite(int id) => '$baseUrl/api/favorites/remove/$id';
}
