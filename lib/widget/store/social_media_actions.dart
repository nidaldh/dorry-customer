import 'package:flutter/material.dart';
import 'package:dorry/model/store/store_details_model.dart';
import 'package:dorry/utils/sizes.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialMediaActions extends StatelessWidget {
  final StoreDetailsModel storeDetails;

  const SocialMediaActions({
    super.key,
    required this.storeDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (storeDetails.facebookLink == null &&
        storeDetails.instagramLink == null &&
        storeDetails.snapchatLink == null &&
        storeDetails.tiktokLink == null) {
      return SizedBox.shrink();
    }
    final socialMediaLinks = [
      {
        'title': 'Facebook',
        'image': 'assets/image/facebook.webp',
        'link': storeDetails.facebookLink
      },
      {
        'title': 'Instagram',
        'image': 'assets/image/instagram.webp',
        'link': storeDetails.instagramLink
      },
      {
        'title': 'Snapchat',
        'image': 'assets/image/snapchat.webp',
        'link': storeDetails.snapchatLink
      },
      {
        'title': 'TikTok',
        'image': 'assets/image/tiktok.webp',
        'link': storeDetails.tiktokLink
      },
    ];

    return Column(
      children: [
        Text(
          'تواصل معنا',
          style: TextStyle(
            fontSize: Sizes.textSize_22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: Sizes.height_10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: Sizes.width_10,
          children: socialMediaLinks
              .where((media) => media['link'] != null && media['link'] != '')
              .map((media) {
            return GestureDetector(
              onTap: () async {
                final link = media['link'] as String;
                if (await canLaunchUrl(Uri.parse(link))) {
                  await launchUrl(Uri.parse(link));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تعذر فتح ${media['title']}')),
                  );
                }
              },
              child: Image.asset(
                media['image'] as String,
                width: Sizes.width_40,
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}
