class LocationModel {
  final String name;
  final String type; // 'harvesting' or 'market'

  LocationModel({
    required this.name,
    required this.type,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
    };
  }
}
