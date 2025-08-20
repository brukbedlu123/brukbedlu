import 'package:etsport/pages/HOME%20WORKOUT/chest/beginner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:etsport/widgets/gender.dart';

class advanced_armworkout extends StatelessWidget {
  const advanced_armworkout({super.key});

  @override
  Widget build(BuildContext context) {
    final gender = Provider.of<GenderProvider>(context).selectedGender;

    final backgroundimage = gender == 'female'
        ? 'images/home workout/girl/arm.webp'
        : 'images/home workout/boy/arm.webp';

    return ReusableWorkoutPage(
      title: 'Advanced Arm',
      subtitle: '15 mins - 9 Workouts',
      backgroundImage: backgroundimage,
      workouts: [
        {
          'name': 'Jumping Jacks',
          'image': 'images/workouts/jumping-jack.gif',
          'sec': '30 sec'
        },
        {
          'name': 'Standard Push-Ups',
          'image': 'images/workouts/push-up.gif',
          'rep': '20'
        },
        {
          'name': 'Diamond Push-Ups',
          'image': 'images/workouts/diamond-push-up.gif',
          'rep': '15'
        },
        {
          'name': 'Triceps Dips (Chair)',
          'image': 'images/workouts/triceps-dips.gif',
          'rep': '15'
        },
        {
          'name': 'Diamond Push-Ups',
          'image': 'images/workouts/diamond-push-up.gif',
          'rep': '15'
        },
        {
          'name': 'Archer Push-Ups',
          'image': 'images/workouts/archer-push-up.gif',
          'rep': '10 each side'
        }, // Adjusted
        {
          'name': 'Arm Circles (dynamic)',
          'image': 'images/workouts/arm-circles.gif',
          'sec': '45 sec'
        },
        // New additions/replacements for common and different push-ups
        {
          'name': 'Close-Grip Push-Ups',
          'image': 'images/workouts/push-up.gif',
          'rep': '15'
        },
        {
          'name': 'Biceps Leg Concentration Curl',
          'image': 'images/workouts/Biceps-Leg-Concentration-Curl.gif',
          'rep': '10 each side'
        },
      ],
    );
  }
}
