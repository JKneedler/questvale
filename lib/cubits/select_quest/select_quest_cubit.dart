import 'package:flutter_bloc/flutter_bloc.dart';

class SelectQuestCubit extends Cubit<int?> {
  SelectQuestCubit() : super(null);

  void toggle(int index) {
    print('toggle $index');
    emit(state == index ? null : index);
  }
}
