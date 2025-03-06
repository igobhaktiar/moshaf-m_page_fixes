import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/features/qanda/data/models/qanda_model.dart';
import 'package:qeraat_moshaf_kwait/features/qanda/presentation/cubit/qanda_cubit/qanda_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/qanda/presentation/cubit/qanda_service.dart';

class ProgressIndicatorsBlocWrappedWidget extends StatelessWidget {
  const ProgressIndicatorsBlocWrappedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QandaCubit, QandaState>(
      builder: (context, qandaState) {
        if (qandaState is UserQandADetailsFetched) {
          int correctAnswers = 0;
          int incorrectAnswers = 0;
          for (final UserQandA singleAnswers in qandaState.userAnswers) {
            if (singleAnswers.points == 0) {
              incorrectAnswers = incorrectAnswers + 1;
            } else {
              correctAnswers = correctAnswers + 1;
            }
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ProgressIndicatorWidget(
                progress: correctAnswers,
                total: QandaService.getTotalQuizesCount(),
                isCorrect: true,
              ),
              ProgressIndicatorWidget(
                progress: incorrectAnswers,
                total: QandaService.getTotalQuizesCount(),
              ),
            ],
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}

class ProgressIndicatorWidget extends StatelessWidget {
  final int progress;
  final int total;
  final bool isCorrect;

  const ProgressIndicatorWidget({
    super.key,
    required this.progress,
    required this.total,
    this.isCorrect = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isCorrect) ...[
          Text(
            progress.toString(),
            style: TextStyle(
              color: context.isDarkMode ? Colors.white : Colors.green,
              fontSize: 18,
            ),
          ),
          const SizedBox(
            width: 5,
          ),
        ],
        Container(
          width: 70,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(5),
          ),
          child: Align(
            alignment: isCorrect
                ? AlignmentDirectional.centerStart
                : AlignmentDirectional.centerEnd,
            child: Container(
              width: (progress / total) * 70,
              decoration: BoxDecoration(
                color: isCorrect ? Colors.green : Colors.brown,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
        if (!isCorrect) ...[
          const SizedBox(
            width: 5,
          ),
          Text(
            progress.toString(),
            style: TextStyle(
              fontSize: 18,
              color: context.isDarkMode ? Colors.white : Colors.brown,
            ),
          ),
        ],
      ],
    );
  }
}
