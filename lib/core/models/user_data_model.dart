class UserDataModel {
  final String? number;
  final String? email;
  final String? service;
  final String? passwordHash;

  factory UserDataModel.fromJson (Map<String, dynamic> json) => UserDataModel(
    number: json['number'],
    service: json['service'],
    email: json['email'],
    passwordHash: json['password']
  );

  UserDataModel({this.service, this.number, this.passwordHash, this.email});

  Map<String, dynamic> toJson () => {
    'number': number,
    'password': passwordHash,
    'service': service,
    'email': email
  };
}