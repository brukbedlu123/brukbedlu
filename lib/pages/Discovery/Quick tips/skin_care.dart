import 'package:etsport/pages/providers/languageprovide.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'nutrition.dart'; // Make sure this is the correct import path for your Nutrition widget file

class SkinCare extends StatelessWidget {
  const SkinCare({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).locale.languageCode;

    return Nutrition(
      pageTitle: lang == 'am' ? 'የቆዳ እንክብካቤ መመሪያ' : 'Skin Care Guide',
      tabTitles:
          lang == 'am' ? ['ዘይታማ', 'ደረቅ', 'ስሜታዊ'] : ['Oily', 'Dry', 'Sensitive'],
      pages: [
        SkinCarePageData(
          title: lang == 'am' ? 'ዘይታማ ቆዳ እንክብካቤ' : 'Oily Skin Care',
          description: lang == 'am'
              ? 'ዘይታማ ቆዳን ለመቆጣጠር ትክክለኛ ማጠቢያ እና የዘይት መቆጣጠሪያ ምርቶች ያስፈልጋሉ።'
              : 'Oily skin needs proper cleansing and oil control to prevent breakouts and shine.',
          image: 'assets/images/oily_skin.jpg',
          icon: Icons.wb_sunny_outlined,
          tips: lang == 'am'
              ? [
                  'ቀኑን ሁለት ጊዜ በቀላሉ የሚያጠብ እና የተመረጠ ማጠቢያ ይጠቀሙ።',
                  'ዘይት የሌለበትን እና ፍትፈት የማይሰበስብ አቀማመጥ ይምረጡ።',
                  'ቅንድብዎችን ለማንፀባረቅ በመደበኛነት ቆዳዎን ይቆርጡ።',
                  'ከመተኛት በፊት ማኬፕ ያስወግዱ።',
                  'ተጨማሪ ዘይት ለመቆጣጠር ዘይት የሚሰበስቡ ወረቀቶች (blotting papers) ይጠቀሙ።',
                ]
              : [
                  'Use a gentle, foaming cleanser twice daily.',
                  'Choose oil-free and non-comedogenic moisturizers.',
                  'Exfoliate regularly to unclog pores.',
                  'Remove makeup before sleeping.',
                  'Use blotting papers to control excess oil.',
                ],
        ),
        SkinCarePageData(
          title: lang == 'am' ? 'ደረቅ ቆዳ እንክብካቤ' : 'Dry Skin Care',
          description: lang == 'am'
              ? 'ደረቅ ቆዳ ለመከላከል እና ለመቀስቀስ በጣም እርጥበት ያስፈልጋል።'
              : 'Dry skin requires intense hydration to prevent flakiness and irritation.',
          image: 'images/discovery/skincare.avif',
          icon: Icons.opacity,
          tips: lang == 'am'
              ? [
                  'የሚያረግበውን ማጠቢያ ይጠቀሙ።',
                  'ከመታጠብ በኋላ ወዲያው እርጥበት ያቀቡ።',
                  'ብዙ ውሃ ይጠጡ።',
                  'ሀይድሮሎኒክ አሲድ ያለው ምርት ይጠቀሙ።',
                ]
              : [
                  'Use a hydrating cleanser.',
                  'Apply moisturizer immediately after washing.',
                  'Drink plenty of water.',
                  'Use products with hyaluronic acid.',
                ],
        ),
        SkinCarePageData(
          title: lang == 'am' ? 'ስሜታዊ ቆዳ እንክብካቤ' : 'Sensitive Skin Care',
          description: lang == 'am'
              ? 'ስሜታዊ ቆዳ ቀላል እና ምቾት ያለው የቆዳ እንክብካቤ ምርት ያስፈልጋል።'
              : 'Sensitive skin needs gentle products to avoid redness and irritation.',
          image: 'images/discovery/skincare.avif',
          icon: Icons.spa_outlined,
          tips: lang == 'am'
              ? [
                  'ሽቱ የሌለውን እና ያልተሰናከለ የቆዳ እንክብካቤ ይጠቀሙ።',
                  'አዲስ ምርት ከመጠቀም በፊት በአንድ ቦታ ይሞክሩ (patch test)።',
                  'ከብዙ ፀሐይ ተጋላጭ መሆንን ያስወግዱ።',
                  'ቀላል እና በቀጥታ የሚከተለውን የቆዳ እንክብካቤ ስርዓት ይጠብቁ።',
                ]
              : [
                  'Use fragrance-free skincare.',
                  'Patch test new products before use.',
                  'Avoid excessive sun exposure.',
                  'Stick to a simple skincare routine.',
                ],
        ),
      ],
    );
  }
}
