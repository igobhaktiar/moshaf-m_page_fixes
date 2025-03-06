part of 'reciter_image_cubit.dart';

abstract class ReciterImageState extends Equatable {
  final bool showReciterImages;

  const ReciterImageState({
    required this.showReciterImages,
  });

  @override
  List<Object> get props => [
        showReciterImages,
      ];
}

class ReciterImageControlState extends ReciterImageState {
  @override
  // ignore: overridden_fields
  final bool showReciterImages;
  const ReciterImageControlState({
    required this.showReciterImages,
  }) : super(
          showReciterImages: showReciterImages,
        );
}
