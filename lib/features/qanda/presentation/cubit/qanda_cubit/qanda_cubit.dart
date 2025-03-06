import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_context.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/utils/app_strings.dart';
import '../../../data/models/qanda_model.dart';

part 'qanda_state.dart';

class QandaCubit extends Cubit<QandaState> {
  QandaCubit({
    required this.sharedPreferences,
  }) : super(UserQandADetailsFetched(
          userAnswers: const [],
        ));

  static QandaCubit get(context) => BlocProvider.of(context);
  final SharedPreferences sharedPreferences;

  init() async {
    emit(UserQandADetailsLoading());
    List<UserQandA> userQAData = [];
    String savedUserQAData =
        sharedPreferences.getString(AppStrings.savedQAData) ?? '';
    if (savedUserQAData.isNotEmpty) {
      List<dynamic> jsonList = jsonDecode(savedUserQAData);
      // Map each JSON item to a QuizQuestion object
      userQAData = jsonList
          .map((json) => UserQandA.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    emit(UserQandADetailsFetched(
      userAnswers: userQAData,
    ));
  }

  resetUserQandA() {
    emit(UserQandADetailsLoading());
    sharedPreferences.setString(AppStrings.savedQAData, '');
    emit(
      UserQandADetailsFetched(
        // ignore: prefer_const_literals_to_create_immutables
        userAnswers: [],
      ),
    );
  }

  setAndUpdateUserQandA(
    UserQandA currentAnsweredQuestion, {
    bool logAnalyticsEvent = true,
  }) {
    BuildContext? appContext = AppContext.getAppContext();
    if (appContext != null) {
      QandaState qandaState = QandaCubit.get(appContext).state;
      if (qandaState is UserQandADetailsFetched) {
        List<UserQandA> prevAnswersToUpdate = qandaState.userAnswers;
        bool isAlreadyAdded = false;
        for (final UserQandA singleAnswer in prevAnswersToUpdate) {
          if (singleAnswer.id == currentAnsweredQuestion.id) {
            isAlreadyAdded = true;
          }
        }
        if (!isAlreadyAdded) {
          prevAnswersToUpdate.add(currentAnsweredQuestion);
          String jsonString =
              jsonEncode(prevAnswersToUpdate.map((q) => q.toJson()).toList());
          sharedPreferences.setString(
            AppStrings.savedQAData,
            jsonString,
          );
        }
        emit(UserQandADetailsLoading());
        emit(
          UserQandADetailsFetched(
            userAnswers: prevAnswersToUpdate,
          ),
        );
      }
    }
  }
}
