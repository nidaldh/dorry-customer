import 'package:dio/dio.dart';
import 'package:dorry/model/response/response_model.dart';
import 'package:dorry/router.dart';
import 'package:dorry/utils/api_service.dart';
import 'package:dorry/utils/app_snack_bar.dart';
import 'package:dorry/utils/formatter.dart';
import 'package:dorry/utils/user_manager.dart';
import 'package:dorry/widget/base_scaffold_widget.dart';
import 'package:flutter/material.dart';

class CustomerFormScreen extends StatefulWidget {
  const CustomerFormScreen({Key? key}) : super(key: key);

  @override
  _CustomerFormScreenState createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic> errors = {};

  @override
  void initState() {
    super.initState();
    _nameController.text = CustomerManager.user!.name;
    _birthdateController.text = CustomerManager.user!.birthDate != null
        ? requestDateFormatter.format(CustomerManager.user!.birthDate!)
        : '';
  }

  Future<void> _updateCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService().postRequest(
        '/api/customer/update',
        {
          'name': _nameController.text,
          'birthdate': _birthdateController.text,
        },
      );
      if (response.statusCode == 200) {
        CustomerManager.customerInfo();
        successSnackBar('تم تحديث البيانات بنجاح');
        router.pop();
      }
    } catch (e) {
      if (e is DioException) {
        final responseModel = BaseResponseModel.fromJson(e.response!.data);
        if (responseModel.errors != null) {
          setState(() {
            errors = responseModel.errors!;
          });
        }
        errorSnackBar(responseModel.message ?? 'حدث خطأ أثناء تحديث البيانات');
        return;
      }
      errorSnackBar('حدث خطأ أثناء تحديث البيانات');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffoldWidget(
      title: 'تحديث البيانات الشخصية',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: AbsorbPointer(
          absorbing: _isLoading,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'الاسم الكامل',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الاسم الكامل';
                    }
                    return null;
                  },
                  errorText: errors['name'] as String?,
                ),
                SizedBox(height: 16),
                _buildDateField(
                  controller: _birthdateController,
                  label: 'تاريخ الميلاد',
                  icon: Icons.calendar_today,
                  errorText: errors['birthdate'] as String?,
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      locale: const Locale('ar', ''),
                    );

                    if (picked != null) {
                      setState(() {
                        _birthdateController.text =
                            requestDateFormatter.format(picked);
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء اختيار تاريخ الميلاد';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32),
                _isLoading
                    ? CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateCustomer,
                          child: Text(
                            'تحديث البيانات',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    FormFieldValidator<String>? validator,
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        errorText: errorText,
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: validator,
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    VoidCallback? onTap,
    FormFieldValidator<String>? validator,
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        errorText: errorText,
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      onTap: onTap,
      validator: validator,
    );
  }
}
