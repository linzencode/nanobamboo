import 'package:get/get.dart';
import 'package:nanobamboo/app/routes/app_routes.dart';
import 'package:nanobamboo/modules/auth/controllers/auth_controller.dart';
import 'package:nanobamboo/modules/auth/views/auth_view.dart';
import 'package:nanobamboo/modules/home/controllers/home_controller.dart';
import 'package:nanobamboo/modules/home/views/home_view.dart';

/// 应用页面配置
class AppPages {
  AppPages._();

  /// 所有页面路由
  static final List<GetPage<dynamic>> routes = [
    GetPage<dynamic>(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: BindingsBuilder<dynamic>(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),
    GetPage<dynamic>(
      name: AppRoutes.auth,
      page: () => const AuthView(),
      binding: BindingsBuilder<dynamic>(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
  ];
}
