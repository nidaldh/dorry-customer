class ApiUri {
  // static const baseUrl = 'http://mahali.khidmatna.com';
  static const baseUrl = 'http://192.168.50.169:8000';
  // static const baseUrl = 'http://192.168.1.18:8000';

  static const register = '/api/customer/register';
  static const login = '/api/customer/login';
  static const validateOtp = '/api/customer/validate-otp';
  static const logout = '/api/customer/logout';
  static const customerAppointment= '/api/customer/appointments';
  static const customerAppointmentReport= '/api/customer/appointments/report';
  static const store = '/api/store';
  static const availableTimeSlots = '/api/time-slots/available';
  static const bookTimeSlot = '/api/time-slots/book';
}
