class GenderModel {
  final String name;
  final Gender code;

  GenderModel({required this.name, required this.code});

  factory GenderModel.fromJson(Map<String, dynamic> json) {
    return GenderModel(
      name: json['name'],
      code: json['code'],
    );
  }

  //to json
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
    };
  }
}
final List<GenderModel> genderList = [
  GenderModel(name: 'ذكر', code: Gender.male),
  GenderModel(name: 'أنثى', code: Gender.female),
];

enum Gender {
  male,
  female;

  const Gender();
}
