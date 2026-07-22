part of 'bloc.dart';


@freezed
class DesiresEvent with _$DesiresEvent {
  const factory DesiresEvent.cancel() = _Cancel;
  const factory DesiresEvent.goToReport() = _GoToReport;

  const factory DesiresEvent.start() = _Start;
  const factory DesiresEvent.getDetails(BuildContext context) = _GetDetails;
  const factory DesiresEvent.saveDesiresText() = _SaveDesiresText;
  const factory DesiresEvent.saveDetailsText() = _SaveDetailsText;
  const factory DesiresEvent.executeNewDesire({DateTime? dateTime}) = _ExecuteNewDesire;
  const factory DesiresEvent.saveDesire() = _SaveDesire;

  const factory DesiresEvent.execute(Desire desire) = _Execute;


}
