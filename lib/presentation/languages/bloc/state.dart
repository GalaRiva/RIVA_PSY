part of 'bloc.dart';

@freezed
class LanguagesState with _$LanguagesState {
  const factory LanguagesState.initial({required List<LanguageModel> locales, required LanguageModel? selected}) = _Initial;

}
