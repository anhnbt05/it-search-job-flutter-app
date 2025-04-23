class cCompanies {
  final String ID;
  final String Name;
  final String LogoUrl;
  final DateTime CreatedAt;
  final DateTime UpdatedAt;
  final String WebsiteUrl;
  final String Description;

  cCompanies({
    required this.ID,
    required this.Name,
    required this.LogoUrl,
    required this.CreatedAt,
    required this.UpdatedAt,
    required this.WebsiteUrl,
    required this.Description,
  });

  factory cCompanies.fromJson(Map<String, dynamic> json) {
    return cCompanies(
      ID: json['ID'],
      Name: json['Name'],
      LogoUrl: json['LogoUrl'],
      CreatedAt: DateTime.parse(json['CreatedAt']),
      UpdatedAt: DateTime.parse(json['UpdatedAt']),
      WebsiteUrl: json['WebsiteUrl'],
      Description: json['Description'],
    );
  }
}