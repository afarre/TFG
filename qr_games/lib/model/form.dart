
class FormModel {
  String title;
  List<QuestionModel> questionList;

  FormModel(this.title, this.questionList);

  FormModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    if (json['questions'] != null) {
      questionList = new List<QuestionModel>();
      json['questions'].forEach((v) {
        questionList.add(new QuestionModel.fromJson(v));
      });
    }
  }


  Map<String, dynamic> toJson() {
    List<Map> questions = this.questionList != null ? this.questionList.map((i) => i.toJson()).toList() : null;
    return {
      'title': title,
      'questions': questions
    };
  }
}

class QuestionModel {
  String question;
  List<OptionModel> optionList;
  int index;

  QuestionModel(this.question, this.optionList, this.index);

  QuestionModel.fromJson(Map<String, dynamic> json) {
    question = json['question'];
    if (json['options'] != null) {
      optionList = new List<OptionModel>();
      json['options'].forEach((v) {
        optionList.add(new OptionModel.fromJson(v));
      });
    }
    index = json['index'];
  }

  Map toJson() {
    List<Map> options = this.optionList != null ? this.optionList.map((i) => i.toJson()).toList() : null;

    return {
      'question': question,
      'options': options,
      'index' : index
    };
  }
}

class OptionModel{
  String option;
  int index;
  bool selected = false;

  OptionModel(this.option, this.index, this.selected);

  OptionModel.fromJson(Map<String, dynamic> json) {
    option = json['option'];
    index = json['index'];
    selected = json['selected'];
  }

  Map<String, dynamic> toJson() =>
      {
        'option': option,
        'index': index,
        'selected': selected
      };

}