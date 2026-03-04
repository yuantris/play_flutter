import 'package:flutter/services.dart';

/// 系统UI适配工具类（适配状态栏/导航栏沉浸）
class SystemUiUtil {
  /// 初始化系统UI样式（全局调用一次即可）
  static void initSystemUi() {
    // 1. 配置系统栏样式（透明+文字颜色适配）
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        // 状态栏背景透明
        statusBarColor: Color(0x00000000),
        // 导航栏背景透明
        systemNavigationBarColor: Color(0x00000000),
        // 导航栏图标颜色（dark=黑色/light=白色，根据你的App主题选）
        systemNavigationBarIconBrightness: Brightness.dark,
        // 状态栏文字颜色（dark=黑色/light=白色）
        statusBarIconBrightness: Brightness.dark,
        // 解决iOS状态栏文字重叠问题（Android无影响）
        statusBarBrightness: Brightness.light,
      ),
    );

    // 2. 让Flutter页面延伸到系统栏下方（核心！实现沉浸）
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      // 可选：设置系统栏与内容的内边距（防止内容被遮挡）
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
  }
}