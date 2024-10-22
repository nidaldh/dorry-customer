class ApiUri {
  static const baseUrl = 'https://dorry.khidmatna.com';
  // static const baseUrl = 'http://192.168.1.12:8000';
  // static const baseUrl = 'http://192.168.50.206:8000';

  static const register = '/api/customer/register';
  static const login = '/api/customer/login';
  static const info = '/api/customer/info';
  static const checkForUpdate = '/api/check-for-update';
  static const validateOtp = '/api/customer/validate-otp';
  static const fcmToken = '/api/customer/fcm-token';
  static const profileImage = '/api/customer/profile-image';
  static const logout = '/api/customer/logout';
  static const validateResetPasswordOtp = '/api/customer/password/validate-otp';
  static const customerAppointment = '/api/customer/appointments';
  static const customerAppointmentReport = '/api/customer/appointments/report';
  static const store = '/api/store';
  static const availableTimeSlots = '/api/time-slots/available';
  static const bookTimeSlot = '/api/time-slots/book';
  static const areas = '/api/address/areas-for-filter';
}
