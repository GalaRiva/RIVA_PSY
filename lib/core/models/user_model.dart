import 'tariff_model.dart';
import 'package:json_annotation/json_annotation.dart';
part 'generated/user_model.g.dart';

@JsonSerializable()
class UserModel {
   String? login;
   String? email;
   String? password;
   int? reminderTime;
   TariffModel? currentTariff;
   int? old;
   bool? male;
   DateTime registrationDate;
   List<String> reminderTimeInStr = [];
  bool passwordEnable = false;

  UserModel({
    this.login,
    this.email,
    this.password,
    this.reminderTime,
    this.currentTariff,
    this.old,
    this.male,
    required this.registrationDate
  });

   factory UserModel.fromJson(Map<String, dynamic> json) =>
       _$UserModelFromJson(json);

   factory UserModel.userFromFirebase (Map<String, dynamic> json) {
     return UserModel(
       registrationDate: DateTime.parse(json['registration_date']),
       login: json['login'],
       currentTariff: json['tariff'].toString().toLowerCase() == 'стандарт' ? TariffModel(
           name: TariffModel.STANDARD_TARIFF.name,
           endDate: DateTime.parse(json['tariff_is_end']),
           description: TariffModel.STANDARD_TARIFF.description,
           cost: TariffModel.STANDARD_TARIFF.cost,
           advantages: TariffModel.STANDARD_TARIFF.advantages) : TariffModel.BASE_TARIFF,
       email: json['email'],
       male: json['male'],
       old: json['old'],
     );
   }



   Map<String, dynamic> userToFirebase () => {
     'registration_date': this.registrationDate.toIso8601String(),
     'login': this.login,
     'tariff': this.currentTariff!.name,
     'tariff_is_end': this.currentTariff!.endDate.toIso8601String(),
     'email': this.email,
     'male': this.male,
     'old': this.old
   };

   Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
