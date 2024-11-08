import 'package:dorry/model/store/store_user_model.dart';

class StoreDetailsModel {
  final dynamic id;
  final String name;
  final String storeType;
  final dynamic partnerId;
  final List<StorePartnerModel> partners;
  final String? image;
  final String? area;
  final String? address;
  final String? facebookLink;
  final String? instagramLink;
  final String? snapchatLink;
  final String? tiktokLink;
  final String? bio;

  StoreDetailsModel({
    required this.id,
    required this.name,
    required this.storeType,
    required this.partnerId,
    required this.partners,
    this.image,
    this.area,
    this.address,
    this.facebookLink,
    this.instagramLink,
    this.snapchatLink,
    this.tiktokLink,
    this.bio,
  });

  factory StoreDetailsModel.fromJson(Map<String, dynamic> json) {
    return StoreDetailsModel(
      id: json['id'],
      name: json['store_name'],
      storeType: json['store_type'],
      partnerId: json['partner_id'],
      image: json['image'],
      area: json['area'],
      address: json['address'],
      partners: (json['partners'] as List)
          .map((user) => StorePartnerModel.fromJson(user))
          .toList(),
      facebookLink: json['facebook_link'],
      instagramLink: json['instagram_link'],
      snapchatLink: json['snapchat_link'],
      tiktokLink: json['tiktok_link'],
      bio: json['bio'],
    );
  }
}
