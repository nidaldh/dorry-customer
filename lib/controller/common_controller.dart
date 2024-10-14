import 'package:dorry/utils/user_manager.dart';
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
    if (CustomerManager.token == null) {
      futureAppointments = [];
      update(['appointment_list']);
      return;
    }
    final response = await ApiService().getRequest(ApiUri.customerAppointment);

    if (response.statusCode == 200) {
      futureAppointments =
          AppointmentListResponseModel.fromJson(response.data).appointments;
      update(['appointment_list']);
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  void successLoginLogic() {
    fetchAppointments();
    update(['customer_info']);
  }
}
