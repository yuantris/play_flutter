import 'package:intl/intl.dart';

/// 日期工具类
class DateUtil {
  DateUtil._();

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  /// 中文星期几映射
  static const List<String> _weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  /// 格式化日期为 yyyy-MM-dd
  static String formatDate(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  /// 格式化时间为 HH:mm
  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  /// 获取星期几 (中文)
  static String getWeekDay(DateTime dateTime) {
    return _weekDays[dateTime.weekday - 1];
  }

  /// 获取短星期几 (中文)
  static String getShortWeekDay(DateTime dateTime) {
    return _weekDays[dateTime.weekday - 1];
  }

  /// 获取今天的日期字符串
  static String getTodayString() {
    return '今天';
  }

  /// 获取明天的日期字符串
  static String getTomorrowString() {
    return '明天';
  }

  /// 获取相对日期描述
  static String getRelativeDateString(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final difference = targetDate.difference(today).inDays;

    if (difference == 0) {
      return '今天';
    } else if (difference == 1) {
      return '明天';
    } else if (difference == 2) {
      return '后天';
    } else if (difference == -1) {
      return '昨天';
    } else {
      return getShortWeekDay(date);
    }
  }

  /// 解析 API 返回的时间字符串
  static DateTime parseApiTime(String timeString) {
    return DateTime.parse(timeString);
  }

  /// 从时间字符串获取小时
  static int getHourFromTimeString(String timeString) {
    return DateTime.parse(timeString).hour;
  }
}
