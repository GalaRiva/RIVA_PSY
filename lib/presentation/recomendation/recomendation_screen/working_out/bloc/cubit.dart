import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/bloc/state.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/data/repository.dart';

import '../../../../../core/models/day_event_model.dart';
import '../../../../../core/user_data/user.dart';

class WorkingOutCubit extends Cubit<WorkingOutState> {
  final TickerProvider tickerProvider;

  WorkingOutCubit(this.tickerProvider)
      : super(WorkingOutState()) {
    tabController = TabController(length: 2, vsync: tickerProvider);
  }

  bool get showContent => CurrentUser.tariffIsOrion();
  TabController? tabController;
  int currentTab = 0;

  void goToPrevState(BuildContext context) {
    if (state.prevState == null) {
      Navigator.pop(context);
    } else {
      emit(state.prevState!);
    }
  }

  void goToNextState() {
      emit(WorkingOutState(prevState: state));
  }
}
