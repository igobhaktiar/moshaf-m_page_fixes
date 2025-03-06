import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/features/qanda/presentation/cubit/fetched_questions_cubit/fetched_questions_cubit.dart';

import '../../../data/models/qanda_model.dart';
import '../../cubit/qanda_service.dart';

class TimerCircleDisplay extends StatefulWidget {
  const TimerCircleDisplay({super.key});

  @override
  State<TimerCircleDisplay> createState() => _TimerCircleDisplayState();
}

class _TimerCircleDisplayState extends State<TimerCircleDisplay> {
  int totalTime = 20;
  late Timer _timer;
  int _remainingTime = 0;
  double _progress = 1.0;

  @override
  void initState() {
    super.initState();
    _startCountdown(true);
  }

  void _startCountdown(bool isInitialTimer) {
    if (isInitialTimer || _timer.isActive == false) {
      _remainingTime = totalTime;
      _progress = 1.0;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingTime > 0) {
            _remainingTime--;
            _progress = _remainingTime / totalTime;
          } else {
            QuizQuestion? currentQuizQuestion =
                QandaService.getCurrentQuestion();
            if (currentQuizQuestion != null) {
              UserQandA currentAnswer = UserQandA(
                id: currentQuizQuestion.id,
                answerNumber: 0,
                points: 0,
              );
              QandaService.giveUserAnswer(currentAnswer);
            }
            _timer.cancel();
          }
        });
      });
    }
  }

  @override
  void dispose() {
    try {
      if (_timer.isActive) _timer.cancel();
    } catch (e) {
      debugPrint(e.toString());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FetchedQuestionsCubit, FetchedQuestionsState>(
      listener: (context, fetchedQuestionsState) {
        _startCountdown(false);
      },
      child: CircleAvatar(
        radius: 35,
        backgroundColor: context.isDarkMode ? Colors.black : Colors.white,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                value: _progress,
                strokeWidth: 4,
                color: Colors.purple,
                backgroundColor:
                    context.isDarkMode ? Colors.black : Colors.white,
              ),
            ),
            Center(
              child: CircleAvatar(
                radius: 26,
                backgroundColor:
                    context.isDarkMode ? Colors.black : Colors.white,
                child: Text(
                  _remainingTime.toString(),
                  style: TextStyle(
                    color: context.isDarkMode ? Colors.white : Colors.purple,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
