/// 位置模型
class LocationModel {
  final double latitude;
  final double longitude;
  final String cityName;
  final String? country;
  final String? admin1;

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    this.country,
    this.admin1,
  });

  factory LocationModel.fromGeocodingJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      cityName: json['name'] as String? ?? '',
      country: json['country'] as String?,
      admin1: json['admin1'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'cityName': cityName,
      'country': country,
      'admin1': admin1,
    };
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      cityName: json['cityName'] as String? ?? '',
      country: json['country'] as String?,
      admin1: json['admin1'] as String?,
    );
  }

  String get displayName {
    if (admin1 != null && admin1!.isNotEmpty) {
      return '$cityName, $admin1';
    }
    return cityName;
  }

  @override
  String toString() {
    return 'LocationModel(latitude: $latitude, longitude: $longitude, cityName: $cityName)';
  }
}
