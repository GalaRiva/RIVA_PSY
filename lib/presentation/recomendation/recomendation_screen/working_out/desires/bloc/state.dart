part of 'bloc.dart';

@freezed
class DesiresState with _$DesiresState {
  const factory DesiresState.initial() = _Initial;
  const factory DesiresState.initialIsNotEmpty({required List<Desire> desires,
    required List<Desire> completed,
    required List<Desire> inProcess,
    required List<Desire> expired, }) = _InitialIsNotEmpty;
  const factory DesiresState.createDesire1({required TextEditingController desires}) = _CreateDesire1;
  const factory DesiresState.createDesire2({required TextEditingController details}) = _CreateDesire2;
  const factory DesiresState.createDesire3() = _CreateDesire3;


}
