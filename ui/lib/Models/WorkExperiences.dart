class cWorkExperiences {
  final String ID;
  final DateTime? EndDate;
  final String JobType;
  final String Location;
  final String Position;
  final DateTime StartDate;
  final String CompanyName;
  final List<String> Descriptions;
  final String CompanyLogoUrl;

  cWorkExperiences({
    required this.ID,
    this.EndDate,
    required this.JobType,
    required this.Location,
    required this.Position,
    required this.StartDate,
    required this.CompanyName,
    required this.Descriptions,
    required this.CompanyLogoUrl,
  });

  factory cWorkExperiences.fromJson(Map<String, dynamic> json) {
    return cWorkExperiences(
      ID: json['ID'],
      EndDate: json['EndDate'] != null ? DateTime.tryParse(json['EndDate']) : null,
      JobType: json['JobType'],
      Location: json['Location'],
      Position: json['Position'],
      StartDate: DateTime.parse(json['StartDate']),
      CompanyName: json['CompanyName'],
      Descriptions: List<String>.from(json['Descriptions']),
      CompanyLogoUrl: json['CompanyLogoUrl'],
    );
  }
}