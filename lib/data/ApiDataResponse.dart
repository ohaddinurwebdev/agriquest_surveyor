class ApiDataResponse {
  List<dynamic> farmers;
  List<dynamic> surveysQuestions;
  List<dynamic> surveys;
  List<dynamic> notifications;
  List<dynamic> translations;
  String error;

  ApiDataResponse(
      {this.farmers, this.surveysQuestions, this.surveys, this.notifications, this.translations, this.error});
}
