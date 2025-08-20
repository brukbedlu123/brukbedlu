import 'package:etsport/pages/providers/languageprovide.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'nutrition.dart';

class Weightgain extends StatelessWidget {
  const Weightgain({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).locale.languageCode;

    return Nutrition(
      pageTitle: lang == 'am' ? 'የክብደት መጨመሪያ መመሪያ' : 'Weight Gain Guide',
      tabTitles: lang == 'am'
          ? ['አመጋገብ', 'እንቅስቃሴ', 'የተለመዱ ልምዶች']
          : ['Diet', 'Workout', 'Lifestyle'],
      pages: [
        SkinCarePageData(
          title: lang == 'am' ? 'የክብደት መጨመሪያ አመጋገብ' : 'Weight Gain Diet',
          description: lang == 'am'
              ? 'እንዲያድጉ በካሎሪ ከፍ ያላቸው ምግቦችና የተሟሉ መመገብ ዘዴ ላይ ይትኩ።'
              : 'To gain weight, focus on high-calorie, nutrient-dense foods combined with a proper meal schedule.',
          image: 'assets/images/weight_gain_diet.jpg',
          icon: Icons.restaurant_menu,
          tips: lang == 'am'
              ? [
                  'ቀኑን 5-6 ጊዜ ትንሽ ትንሽ ምግብ ይብሉ።',
                  'ከፍተኛ ፕሮቲን ያላቸው እንቁላል፣ ስጋ፣ ተክል ያካትቱ።',
                  'ጤናማ ስብ፣ እንደ በለስ፣ አቮካዶ፣ የወይራ ዘይት ያስገቡ።',
                  'ተጨማሪ ካሎሪ ለማግኘት ሼክ ወይም ስሙዝ ይጠጡ።',
                  'ቁርስን አትተዉ።',
                ]
              : [
                  'Eat 5–6 smaller meals throughout the day.',
                  'Include high-protein foods like eggs, meat, and legumes.',
                  'Add healthy fats like nuts, avocados, and olive oil.',
                  'Drink smoothies or shakes for extra calories.',
                  'Never skip breakfast.',
                ],
        ),
        SkinCarePageData(
          title: lang == 'am' ? 'የክብደት መጨመሪያ እንቅስቃሴ' : 'Weight Gain Workout',
          description: lang == 'am'
              ? 'የኃይል ልምምዶች ጡንቻን ማንጠጣጠሪያ ሲሆኑ ተጨማሪ ክብደት እንዳይሆን ይረዳሉ።'
              : 'Strength training is crucial to ensure the added weight is muscle, not fat.',
          image: 'images/discovery/weight gain.avif',
          icon: Icons.fitness_center,
          tips: lang == 'am'
              ? [
                  'ዋና ዋና እንቅስቃሴዎችን (squats, deadlifts, bench press) ይስሩ።',
                  'በሳምንት 3-5 ጊዜ ይስሩ።',
                  'ክብደቱን በቀጣይነት ያድጉ።',
                  'በእያንዳንዱ ስት መካከል በቂ ዕረፍት ይውሰዱ።',
                  'ከእንቅስቃሴ በኋላ ፕሮቲን ያለው ምግብ ይብሉ።',
                ]
              : [
                  'Focus on compound exercises (squats, deadlifts, bench press).',
                  'Train 3–5 times per week.',
                  'Progressively increase weights.',
                  'Get enough rest between sets and workouts.',
                  'Consume a protein-rich meal post-workout.',
                ],
        ),
        SkinCarePageData(
          title: lang == 'am' ? 'የክብደት መጨመሪያ ዘዴ ሕይወት' : 'Weight Gain Lifestyle',
          description: lang == 'am'
              ? 'የሕይወት ልምዶችዎ በጤናማ መንገድ ክብደት እንዲጨምሩ ያግዟሉ።'
              : 'Your daily routine and habits impact how effectively you gain healthy weight.',
          image: 'assets/images/weight_gain_lifestyle.jpg',
          icon: Icons.self_improvement,
          tips: lang == 'am'
              ? [
                  'በየሌሊቱ ቢያንስ 7-9 ሰዓት ዕንቅፍ ያድርጉ።',
                  'እንቅፋትን ለመቀነስ የማህበረሰብ ዘዴዎች ወይም ዮጋ ይሞክሩ።',
                  'ብዙ ካርዲዮ አትስሩ።',
                  'በምግብ እና እንቅስቃሴ ላይ ቀጣይነት ይኑሩ።',
                  'ስኬትዎን በሳምንት አንድ ጊዜ ይመዝግቡ።',
                ]
              : [
                  'Get at least 7–9 hours of sleep nightly.',
                  'Reduce stress through mindfulness or yoga.',
                  'Avoid excessive cardio workouts.',
                  'Stay consistent with meals and workouts.',
                  'Track your progress weekly.',
                ],
        ),
      ],
    );
  }
}
