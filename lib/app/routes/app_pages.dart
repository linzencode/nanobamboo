import 'package:get/get.dart';
import 'package:nanobamboo/app/routes/app_routes.dart';
import 'package:nanobamboo/modules/home/controllers/home_controller.dart';
import 'package:nanobamboo/modules/home/views/home_view.dart';

/// 应用页面配置
class AppPages {
  AppPages._();

  /// 所有页面路由
  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),
  ];
}

