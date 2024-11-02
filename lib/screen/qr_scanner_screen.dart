import 'dart:convert';

import 'package:dorry/router.dart';
import 'package:dorry/utils/api_service.dart';
import 'package:dorry/utils/app_snack_bar.dart';
import 'package:dorry/widget/base_scaffold_widget.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController controller = MobileScannerController();
  bool isLoading = false;
  bool hasPermission = false;
  bool showScanner = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() {
        hasPermission = true;
        showScanner = true;
      });
    } else if (status.isDenied) {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        setState(() {
          hasPermission = true;
          showScanner = true;
        });
      } else if (result.isPermanentlyDenied) {
        _showPermissionDialog();
      } else {
        errorSnackBar('يتطلب إذن الكاميرا لمسح رموز QR');
      }
    } else if (status.isPermanentlyDenied) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('إذن الكاميرا مطلوب'),
          content: Text(
              'تم رفض إذن الكاميرا بشكل دائم. يرجى السماح بإذن الكاميرا من إعدادات التطبيق لمتابعة استخدام الماسح الضوئي.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: Text('فتح الإعدادات'),
            ),
          ],
        );
      },
    );
  }

  void _fetchStoreDetails(String qrCode) async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = jsonDecode(qrCode);

      final response = await ApiService()
          .getRequest('/api/store/qr-code/${data['qr_code']}');
      final storeId = response.data['store']['id'];
      router.push('/store/$storeId');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في جلب تفاصيل المتجر: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
        showScanner = false;
      });

      controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffoldWidget(
      title: 'مسح رمز المتجر',
      showBackButton: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (showScanner) ...[
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  MobileScanner(
                    controller: controller,
                    onDetect: (BarcodeCapture capture) {
                      controller.stop();
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        if (barcode.rawValue != null) {
                          _fetchStoreDetails(barcode.rawValue!);
                          return;
                        }
                      }
                    },
                  ),
                  if (isLoading)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ),
                  if (!hasPermission)
                    Center(
                      child: Text(
                        'تحتاج إلى إذن الكاميرا لمسح رموز QR.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  // Close Button
                  Positioned(
                    top: 16,
                    left: 16,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          showScanner = false;
                        });
                      },
                      icon: Icon(Icons.close),
                      label: Text('إغلاق'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.black54,
              padding: EdgeInsets.all(16),
              child: Text(
                'وجّه الكاميرا نحو رمز QR لمسحه.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ] else ...[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 100,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      'الوصول السريع عن طريق مسح ال QR ',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _checkCameraPermission();
                      if (hasPermission) {
                        setState(() {
                          showScanner = true;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('لم يتم منح إذن الكاميرا.'),
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.camera_alt),
                    label: Text('فتح الماسح'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
