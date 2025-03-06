import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/features/qanda/data/models/qanda_model.dart';
import 'package:qeraat_moshaf_kwait/features/qanda/presentation/cubit/qanda_service.dart';
import 'package:qeraat_moshaf_kwait/features/qanda/presentation/widgets/bloc_wrapped_state_widgets/option_tiles_bloc_wrapped_display.dart';

import 'question_number_bloc_wrapped_display.dart';

class QuestionAndChoiceBlocWrappedDisplay extends StatelessWidget {
  const QuestionAndChoiceBlocWrappedDisplay({
    super.key,
    required this.totalQuizQuestions,
  });
  final List<QuizQuestion> totalQuizQuestions;

  @override
  Widget build(BuildContext context) {
    QuizQuestion currentQuestion =
        totalQuizQuestions[QandaService.getCompletedQuizCount()];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          QuestionNumberBlocWrappedDisplay(
            currentQuestion: currentQuestion,
            totalAnswers: totalQuizQuestions.length,
          ),
          Text(
            currentQuestion.question,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          // Options
          OptionTilesBlocWrappedDisplay(
            quizQuestionDetails: currentQuestion,
          ),
        ],
      ),
    );
  }
}
