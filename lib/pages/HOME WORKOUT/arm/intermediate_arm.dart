import 'package:etsport/pages/HOME%20WORKOUT/chest/beginner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:etsport/widgets/gender.dart';

class intermediate_armworkout extends StatelessWidget {
  const intermediate_armworkout({super.key});

  @override
  Widget build(BuildContext context) {
    final gender = Provider.of<GenderProvider>(context).selectedGender;

    final backgroundimage = gender == 'female'
        ? 'images/home workout/girl/arm.webp'
        : 'images/home workout/boy/arm.webp';

    return ReusableWorkoutPage(
      title: 'Intermediate Arm',
      subtitle: '10 mins - 7 Workouts',
      backgroundImage: backgroundimage,
      workouts: [
        {
          'name': 'Jumping Jacks',
          'image': 'images/workouts/jumping-jack.gif',
          'sec': '30 sec'
        },
        // 4 from Beginner Arms
        {
          'name': 'Wall Push-Ups',
          'image': 'images/workouts/wall-push-up.gif',
          'rep': '10'
        },
        {
          'name': 'Triceps Dips (Chair)',
          'image': 'images/workouts/triceps-dips.gif',
          'rep': '12'
        }, // Adjusted
        {
          'name': 'Standard Push-Ups',
          'image': 'images/workouts/push-up.gif',
          'rep': '8'
        }, // Adjusted
        {
          'name': 'Arm Circles',
          'image': 'images/workouts/arm-circles.gif',
          'sec': '30 sec forward'
        }, // Adjusted
        // 2 new intermediate
        {
          'name': 'Diamond Push-Ups',
          'image': 'images/workouts/diamond-push-up.gif',
          'rep': '8'
        },
        {
          'name': 'Archer Push-Ups',
          'image': 'images/workouts/archer-push-up.gif',
          'rep': '8 each side'
        }, // Adjusted
      ],
    );
  }
}
