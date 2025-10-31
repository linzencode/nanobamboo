import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nanobamboo/app/constants/app_constants.dart';
import 'package:nanobamboo/app/routes/app_pages.dart';
import 'package:nanobamboo/app/routes/app_routes.dart';
import 'package:nanobamboo/app/theme/app_theme.dart';
import 'package:nanobamboo/app/theme/theme_controller.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // 全局注册 ThemeController
      Get.put(ThemeController());

      runApp(const MyApp());
    },
    (error, stack) {
      debugPrint('全局错误捕获: $error');
      debugPrint('堆栈信息: $stack');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() => GetMaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,

          // 主题配置
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,

          // 路由配置
          initialRoute: AppRoutes.initial,
          getPages: AppPages.routes,

          // 默认过渡动画
          defaultTransition: Transition.fade,
          transitionDuration: AppConstants.mediumAnimationDuration,

          // 本地化配置（可选）
          locale: const Locale('zh', 'CN'),
          fallbackLocale: const Locale('en', 'US')
        ));
  }
}

