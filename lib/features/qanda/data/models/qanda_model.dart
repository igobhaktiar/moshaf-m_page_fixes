import 'dart:convert';

class QuizQuestion {
  final int id;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final int correctAnswer;
  final String extras;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.correctAnswer,
    required this.extras,
  });

  // A factory constructor to create a QuizQuestion from a list of strings
  factory QuizQuestion.fromCsv(int id, List<dynamic> row) {
    return QuizQuestion(
      id: id, // Assuming the first column is an ID
      question: row[0].toString(),
      optionA: row[1].toString(),
      optionB: row[2].toString(),
      optionC: row[3].toString(),
      correctAnswer: row[4],
      extras: row[5].toString(),
    );
  }

  @override
  String toString() {
    return 'QuizQuestion(id: $id, question: $question, optionA: $optionA, optionB: $optionB, optionC: $optionC,  correctAnswer: $correctAnswer, extras: $extras)';
  }
}

class UserQandA {
  final int id;
  final int answerNumber;
  final int points;

  UserQandA({
    required this.id,
    required this.answerNumber,
    required this.points,
  });

  factory UserQandA.fromRawJson(String str) =>
      UserQandA.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserQandA.fromJson(Map<String, dynamic> json) => UserQandA(
        id: json["id"],
        answerNumber: json["answerNumber"],
        points: json["points"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "answerNumber": answerNumber,
        "points": points,
      };
}
