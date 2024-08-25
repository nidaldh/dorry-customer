import 'package:dorry/enums/store_type.dart';
import 'package:dorry/model/response/auth/success_response_model.dart';
import 'package:dorry/screen/splash_screen.dart';
import 'package:dorry/utils/api_serice.dart';
import 'package:dorry/utils/user_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateStoreScreen extends StatefulWidget {
  const CreateStoreScreen({super.key});

  @override
  _CreateStoreScreenState createState() => _CreateStoreScreenState();
}

class _CreateStoreScreenState extends State<CreateStoreScreen> {
  final TextEditingController storeNameController = TextEditingController();

  StoreType? selectedStoreType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء متجر'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: const BorderSide(color: Colors.blueAccent, width: 2),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'أدخل تفاصيل المتجر',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: storeNameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم المتجر',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.store),
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<StoreType>(
                      value: selectedStoreType,
                      decoration: const InputDecoration(
                        labelText: 'نوع المتجر',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: StoreType.values.map((StoreType type) {
                        return DropdownMenuItem<StoreType>(
                          value: type,
                          child: Text(type.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStoreType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        String storeName = storeNameController.text.trim();
                        if (selectedStoreType != null && storeName.isNotEmpty) {
                          await _createStore(storeName, selectedStoreType!);
                        } else {
                          Get.snackbar("خطأ", "يرجى ملء جميع الحقول.");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('إنشاء المتجر'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createStore(String storeName, StoreType storeType) async {
    final response = await ApiService().postRequest('/api/stores', {
      'store_name': storeName,
      'store_type': storeType.id,
    });
    if (response.statusCode == 200) {
      final infoResponse =
          await ApiService().getRequest('/api/auth/user-store-info');
      if (infoResponse.statusCode == 200) {
        final successResponse =
            SuccessResponseModel.fromJson(infoResponse.data);
        await UserManager.saveUser(successResponse.user);
        await UserManager.saveStore(successResponse.store);
        Get.offAll(() => const SplashScreen());
      } else {
        Get.snackbar("خطأ", infoResponse.data['message']);
      }
    } else {
      Get.snackbar("خطأ", response.data['message']);
    }
  }
}
