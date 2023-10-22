import 'package:flutter/material.dart';
import '../bloc/state.dart';

abstract class WorkingOutWidget extends StatelessWidget {
  WorkingOutIrrationalStage stage();
  @override
  Widget build(BuildContext context);
}
