import 'package:get/get.dart';
import 'package:getx_pdf_demo/ui/HomeScreen/home_state.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeState>(() => HomeState());
  }
}
