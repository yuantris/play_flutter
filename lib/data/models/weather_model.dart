/// 当前天气数据模型
class CurrentWeather {
  final double temperature;
  final double apparentTemperature;
  final int relativeHumidity;
  final double windSpeed;
  final int weatherCode;
  final DateTime time;

  CurrentWeather({
    required this.temperature,
    required this.apparentTemperature,
    required this.relativeHumidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.time,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] as num).toDouble(),
      apparentTemperature: (json['apparent_temperature'] as num).toDouble(),
      relativeHumidity: json['relative_humidity_2m'] as int,
      windSpeed: (json['wind_speed_10m'] as num).toDouble(),
      weatherCode: json['weather_code'] as int,
      time: DateTime.parse(json['time'] as String),
    );
  }
}

/// 每日天气预报数据模型
class DailyWeather {
  final DateTime date;
  final double tempMax;
  final double tempMin;
  final int weatherCode;
  final double precipitationSum;
  final double windSpeedMax;

  DailyWeather({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.weatherCode,
    this.precipitationSum = 0.0,
    this.windSpeedMax = 0.0,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json, int index) {
    return DailyWeather(
      date: DateTime.parse((json['time'] as List)[index] as String),
      tempMax: (json['temperature_2m_max'] as List)[index].toDouble(),
      tempMin: (json['temperature_2m_min'] as List)[index].toDouble(),
      weatherCode: (json['weather_code'] as List)[index] as int,
      precipitationSum:
          ((json['precipitation_sum'] as List?)?[index] as num?)?.toDouble() ??
              0.0,
      windSpeedMax:
          ((json['wind_speed_10m_max'] as List?)?[index] as num?)?.toDouble() ??
              0.0,
    );
  }
}

/// 小时天气预报数据模型
class HourlyWeather {
  final DateTime time;
  final double temperature;
  final int weatherCode;
  final int relativeHumidity;
  final double windSpeed;

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.relativeHumidity,
    required this.windSpeed,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json, int index) {
    return HourlyWeather(
      time: DateTime.parse((json['time'] as List)[index] as String),
      temperature: (json['temperature_2m'] as List)[index].toDouble(),
      weatherCode: (json['weather_code'] as List)[index] as int,
      relativeHumidity: (json['relative_humidity_2m'] as List)[index] as int,
      windSpeed: (json['wind_speed_10m'] as List)[index].toDouble(),
    );
  }
}

/// 天气数据聚合模型
class WeatherModel {
  final CurrentWeather? current;
  final List<DailyWeather> daily;
  final List<HourlyWeather> hourly;
  final DateTime updatedAt;

  WeatherModel({
    this.current,
    required this.daily,
    required this.hourly,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final currentJson = json['current'] as Map<String, dynamic>?;
    final dailyJson = json['daily'] as Map<String, dynamic>?;
    final hourlyJson = json['hourly'] as Map<String, dynamic>?;

    final dailyList = <DailyWeather>[];
    if (dailyJson != null) {
      final timeList = dailyJson['time'] as List;
      for (int i = 0; i < timeList.length; i++) {
        dailyList.add(DailyWeather.fromJson(dailyJson, i));
      }
    }

    final hourlyList = <HourlyWeather>[];
    if (hourlyJson != null) {
      final timeList = hourlyJson['time'] as List;
      for (int i = 0; i < timeList.length; i++) {
        hourlyList.add(HourlyWeather.fromJson(hourlyJson, i));
      }
    }

    return WeatherModel(
      current:
          currentJson != null ? CurrentWeather.fromJson(currentJson) : null,
      daily: dailyList,
      hourly: hourlyList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current': current != null
          ? {
              'temperature_2m': current!.temperature,
              'apparent_temperature': current!.apparentTemperature,
              'relative_humidity_2m': current!.relativeHumidity,
              'wind_speed_10m': current!.windSpeed,
              'weather_code': current!.weatherCode,
              'time': current!.time.toIso8601String(),
            }
          : null,
      'daily': {
        'time': daily.map((d) => d.date.toIso8601String()).toList(),
        'temperature_2m_max': daily.map((d) => d.tempMax).toList(),
        'temperature_2m_min': daily.map((d) => d.tempMin).toList(),
        'weather_code': daily.map((d) => d.weatherCode).toList(),
      },
      'hourly': {
        'time': hourly.map((h) => h.time.toIso8601String()).toList(),
        'temperature_2m': hourly.map((h) => h.temperature).toList(),
        'weather_code': hourly.map((h) => h.weatherCode).toList(),
      },
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
