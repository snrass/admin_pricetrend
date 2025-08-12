class SpeciesMasterData {
  final Map<String, List<Species>> data;

  SpeciesMasterData({required this.data});

  factory SpeciesMasterData.fromJson(Map<String, dynamic> json) {
    Map<String, List<Species>> speciesMap = {};

    json.forEach((key, value) {
      if (value is List) {
        speciesMap[key] = value.map((item) => Species.fromJson(item)).toList();
      }
    });

    return SpeciesMasterData(data: speciesMap);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {};
    data.forEach((key, value) {
      result[key] = value.map((species) => species.toJson()).toList();
    });
    return result;
  }
}

class Species {
  final String? commonName;
  final String? scientificName;
  final List<SizeGrade>? sizeGrades;
  final String? availability;

  Species({
    this.commonName,
    this.scientificName,
    this.sizeGrades,
    this.availability,
  });

  factory Species.fromJson(Map<String, dynamic> json) {
    return Species(
      commonName: json['Common Name'],
      scientificName: json['Scientific Name'],
      sizeGrades: json['Size/Gradec'] != null
          ? (json['Size/Gradec'] as List)
              .map((grade) => SizeGrade.fromJson(grade))
              .toList()
          : null,
      availability: json['Availability'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Common Name': commonName,
      'Scientific Name': scientificName,
      'Size/Gradec': sizeGrades?.map((grade) => grade.toJson()).toList(),
      'Availability': availability,
    };
  }
}

class SizeGrade {
  final String? size;
  final double? price;

  SizeGrade({
    this.size,
    this.price,
  });

  factory SizeGrade.fromJson(Map<String, dynamic> json) {
    return SizeGrade(
      size: json['size'],
      price: json['price']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'price': price,
    };
  }
}
