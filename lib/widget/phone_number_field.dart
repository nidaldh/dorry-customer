import 'package:dorry/controller/auth_controller.dart';
import 'package:flutter/material.dart';

class CustomPhoneNumberField extends StatefulWidget {
  final AuthController authController;
  final String? errorText;
  final Function(String) changeCountryCode;

  const CustomPhoneNumberField({
    super.key,
    required this.authController,
    required this.changeCountryCode,
    this.errorText,
  });

  @override
  _CustomPhoneNumberFieldState createState() => _CustomPhoneNumberFieldState();
}

class _CustomPhoneNumberFieldState extends State<CustomPhoneNumberField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
              border: Border.all(
                color: widget.errorText != null ? Colors.red : Colors.grey,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Color(0xFF44ACAC).withOpacity(0.1)),
          child: Row(
            children: [
              const Icon(Icons.phone),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: widget.authController.phoneNumberController,
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    if (value.startsWith('0')) {
                      value = value.replaceFirst('0', '');
                    }
                    widget.authController.phoneNumberController.text = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رقم الهاتف';
                    }
                    if (value.length < 9 || value.length > 10) {
                      return 'رقم الهاتف غير صحيح';
                    }
                    return null;
                  },
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    fillColor: Colors.transparent,
                    hintText: 'رقم الهاتف',
                    border: InputBorder.none,
                  ),
                ),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: widget.authController.countryCode,
                  items: <String>['970', '972'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    widget.changeCountryCode(newValue!);
                    widget.authController.countryCode = newValue;
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              widget.errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 15),
            ),
          ),
      ],
    );
  }
}
