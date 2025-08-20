import 'package:etsport/pages/HOME%20WORKOUT/chest/beginner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:etsport/widgets/gender.dart';

class intermediate_legworkout extends StatelessWidget {
  const intermediate_legworkout({super.key});

  @override
  Widget build(BuildContext context) {
    final gender = Provider.of<GenderProvider>(context).selectedGender;

    final backgroundimage = gender == 'female'
        ? 'images/home workout/girl/leg.webp'
        : 'images/home workout/boy/leg.webp';

    return ReusableWorkoutPage(
      title: 'Intermediate Leg',
      subtitle: '10 mins - 7 Workouts',
      backgroundImage: backgroundimage, // A different background image
      workouts: const [
        {
          'name': 'Jumping Jacks',
          'image': 'images/workouts/jumping-jack.gif',
          'sec': '30 sec'
        },
        // 4 from Beginner Legs
        {
          'name': 'Squats',
          'image': 'images/workouts/squats.gif',
          'rep': '20'
        }, // Adjusted
        {
          'name': 'Lunges (alternating)',
          'image': 'images/workouts/lunges.gif',
          'rep': '10 each leg'
        }, // Adjusted
        {
          'name': 'Wall Sit',
          'image': 'images/workouts/wall-sit.webp',
          'sec': '30 sec'
        }, // Adjusted
        {
          'name': 'Calf Raises',
          'image': 'images/workouts/calf-raises.gif',
          'rep': '25'
        }, // Adjusted
        // 2 new intermediate
        {
          'name': 'Jump Squats',
          'image': 'images/workouts/jump-squats.gif',
          'rep': '10'
        }, // Adjusted
        {
          'name': 'Power Lunges',
          'image': 'images/workouts/power-lunge.gif',
          'rep': '6 each leg'
        }, // Adjusted
      ],
    );
  }
}
