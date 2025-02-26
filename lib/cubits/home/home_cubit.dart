import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/home/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState(tab: 2));

  void changeTab(int tab) {
    emit(state.copyWith(tab: tab));
  }
}
