
class FormModel {
  final String title;
  final List<QuestionModel> questionList;

  FormModel(this.title, this.questionList);

  FormModel.fromJson(Map<String, dynamic> json)
      : title = json['tittle'],
        questionList = json['questions'];


  Map toJson() {

    List<Map> questions = this.questionList != null ? this.questionList.map((i) => i.toJson()).toList() : null;

    return {
      'title': title,
      'tags': questions
    };
  }
}

class QuestionModel {
  final String question;
  final List<OptionModel> optionList;

  QuestionModel(this.question, this.optionList);

  Map toJson() {
    List<Map> options = this.optionList != null ? this.optionList.map((i) => i.toJson()).toList() : null;

    return {
      'question': question,
      'tags': options
    };
  }
}

class OptionModel{
  final String option;

  OptionModel(this.option);

  Map<String, dynamic> toJson() =>
      {
        'option': option,
      };

}