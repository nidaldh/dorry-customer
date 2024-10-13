import 'package:get/get.dart';
import 'package:dorry/const/api_uri.dart';
import 'package:dorry/model/customer/appointment_model.dart';
import 'package:dorry/model/response/customer/appointment_list_response_model.dart';
import 'package:dorry/utils/api_service.dart';

class CommonController extends GetxController {
  List<Appointment> futureAppointments = [];

  @override
  void onInit() {
    super.onInit();
    fetchAppointments();
  }

  fetchAppointments() async {
    final response = await ApiService(isAuth: true).getRequest(ApiUri.customerAppointment);

    if (response.statusCode == 200) {
      futureAppointments =
          AppointmentListResponseModel.fromJson(response.data).appointments;
      update(['appointment_list']);
    } else {
      throw Exception('Failed to load appointments');
    }
  }
}
