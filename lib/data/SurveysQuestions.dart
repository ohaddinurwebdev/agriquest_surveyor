class SurveysQuestion {
  String project;
  String group;
  int id;
  String surveyName;
  String dataType;
  String measurementUnit;
  String type;
  String options;

  SurveysQuestion(
      {this.project,
      this.group,
      this.id,
      this.surveyName,
      this.dataType,
      this.measurementUnit,
      this.type,
      this.options});

  factory SurveysQuestion.fromMap(Map<String, dynamic> map) {
    return SurveysQuestion(
      project: map['Project'],
      group: map['Group'],
      id: map['ID'],
      surveyName: map['Survey_name'],
      dataType: map['Data_type'],
      measurementUnit: map['Measurement_unit'],
      type: map['Type'],
      options: map['Options'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Project': project,
      'Group': group,
      'ID': id,
      'Survey_name': surveyName,
      'Data_type': dataType,
      'Measurement_unit': measurementUnit,
      'Type': type,
      'Options': options,
    };
  }
}
