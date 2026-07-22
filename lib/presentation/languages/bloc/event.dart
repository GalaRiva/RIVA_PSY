part of 'bloc.dart';


@freezed
class LanguagesEvent with _$LanguagesEvent {
  const factory LanguagesEvent.fetch({required BuildContext context}) = _Fetch;

  const factory LanguagesEvent.select({required BuildContext context, required LanguageModel languageModel}) = _Select;
}
