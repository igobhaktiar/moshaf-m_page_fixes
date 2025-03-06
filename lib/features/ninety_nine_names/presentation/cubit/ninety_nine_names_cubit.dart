import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'ninety_nine_names_state.dart';

class NinetyNineNamesCubit extends Cubit<NinetyNineNamesState> {
  NinetyNineNamesCubit() : super(NinetyNineNamesInitial());
}
