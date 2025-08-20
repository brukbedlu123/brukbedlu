import 'package:etsport/pages/HOME%20WORKOUT/chest/beginner.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:etsport/widgets/gender.dart';

class advanced_legworkout extends StatelessWidget {
  const advanced_legworkout({super.key});

  @override
  Widget build(BuildContext context) {
    final gender = Provider.of<GenderProvider>(context).selectedGender;

    final backgroundimage = gender == 'female'
        ? 'images/home workout/girl/leg.webp'
        : 'images/home workout/boy/leg.webp';

    return ReusableWorkoutPage(
      title: 'Advanced Leg',
      subtitle: '15 mins - 9 Workouts',
      backgroundImage: backgroundimage,
      workouts: [
        {
          'name': 'Jumping Jacks',
          'image': 'images/workouts/jumping-jack.gif',
          'sec': '30 sec'
        },
        // 6 from Intermediate Legs
        {
          'name': 'Squats',
          'image': 'images/workouts/squats.gif',
          'rep': '25'
        }, // Adjusted
        {
          'name': 'Walking Lunges',
          'image': 'images/workouts/lunges.gif',
          'rep': '15 each leg'
        },
        {
          'name': 'Wall Sit',
          'image': 'images/workouts/wall-sit.webp',
          'sec': '75 sec'
        }, // Adjusted
        {
          'name': 'Jump Squats',
          'image': 'images/workouts/jump-squats.gif',
          'rep': '15'
        }, // Adjusted
        {
          'name': 'Single Leg Calf Raises',
          'image': 'images/workouts/calf-raises.gif',
          'rep': '15 each leg'
        }, // Adjusted
        {
          'name': 'Glute Bridge',
          'image': 'images/workouts/glute-bridge.gif',
          'rep': '15 each leg'
        },
        // 2 new advanced
        {
          'name': 'Pistol Squats (assisted)',
          'image': 'images/workouts/pistol-squats.jpg',
          'rep': '8 each leg'
        },
        {
          'name': 'Box Jumps',
          'image': 'images/workouts/box-jumps.gif',
          'rep': '12'
        },
      ],
    );
  }
}
