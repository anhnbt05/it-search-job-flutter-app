class cProvinces {
  final String id;
  final String name;

  cProvinces({required this.id, required this.name});

  factory cProvinces.fromJson(Map<String, dynamic> json) {
    return cProvinces(
      id: json['ID'],
      name: json['Name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Name': name,
    };
  }
}
