class Survey {
  String project;
  String group;
  int farmerId;
  String surveyType;
  String date;

  Survey({this.project, this.group, this.farmerId, this.surveyType, this.date});

  factory Survey.fromMap(Map<String, dynamic> map) {
    return Survey(
      project: map['Project'],
      group: map['Group'],
      farmerId: map['Farmer_ID'],
      surveyType: map['Survey_type'],
      date: map['Date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Project': project,
      'Group': group,
      'Farmer_ID': farmerId,
      'Survey_type': surveyType,
      'Date': date,
    };
  }
}
