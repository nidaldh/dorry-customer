class Validators {
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال رقم الهاتف';
    }

    if (!RegExp(r'^5\d{8}$').hasMatch(value)) {
      return 'يرجى إدخال رقم هاتف صحيح';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'يجب أن تكون كلمة المرور مكونة من 6 أحرف على الأقل';
    }
    return null;
  }

  static String? confirmPassword(String? value, newPassword) {
    if (value == null || value.isEmpty) {
      return 'الرجاء تأكيد كلمة المرور';
    }
    if (value != newPassword) {
      return 'كلمات المرور غير متطابقة';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال الاسم';
    }
    if (value.length <= 3) {
      return 'الاسم يجب ان يكون اكثر من 3 احرف';
    }
    return null;
  }
}
