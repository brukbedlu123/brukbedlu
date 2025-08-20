import 'package:etsport/pages/Discovery/quick_pump.dart';
import 'package:etsport/pages/HOME%20WORKOUT/chest/beginner.dart';
import 'package:flutter/material.dart';

class weghitloss extends StatelessWidget {
  const weghitloss({super.key});

  @override
  Widget build(BuildContext context) {
    return const ReusableWorkoutPage(
        title: 'Weight loss',
        subtitle: '7 Min Workout',
        backgroundImage: 'images/First three/weight loss/boy.webp',
        workouts: [
          {
            'name': 'Jumping Jacks',
            'image': 'images/workouts/jumping-jack.gif',
            'sec': '30 sec'
          },
          {
            'name': 'High Knees',
            'image': 'images/workouts/high-knees.gif',
            'rep': '10'
          },
          {
            'name': 'Standard Push-Ups',
            'image': 'images/workouts/push-up.gif',
            'rep': '8'
          }, // Adjusted

          {
            'name': 'Butt Kicks',
            'image': 'images/workouts/butt-kicks.gif',
            'rep': '20'
          }, // Adjusted
          {
            'name': 'Arm Circles',
            'image': 'images/workouts/arm-circles.gif',
            'sec': '30 sec'
          }, // Adjusted
          // 2 new intermediate

          {
            'name': 'Jog in Place',
            'image': 'images/workouts/jog-in-place.gif',
            'sec': '60 sec'
          }, // Adjusted
          {
            'name': 'Shadow Boxing',
            'image': 'images/workouts/shadow-boxing.gif',
            'sec': '40 sec'
          }, // Adjusted
          // 2 new intermediate
          {
            'name': 'Burpees (no push-up)',
            'image': 'images/workouts/Burpees.gif',
            'rep': '12'
          }, // Adjusted
          {
            'name': 'Skip Jump Rope',
            'image': 'images/workouts/Skip-Jump-Rope.gif',
            'rep': '60'
          },
          {
            'name': 'Plank',
            'image': 'images/workouts/plank.gif',
            'sec': '30 sec'
          },

          {
            'name': 'Jump Squats',
            'image': 'images/workouts/jump-squats.gif',
            'rep': '15'
          },
          {
            'name': 'Diamond Push-Ups',
            'image': 'images/workouts/diamond-push-up.gif',
            'rep': '8'
          },
          {
            'name': 'Burpees',
            'image': 'images/workouts/Burpees.gif',
            'rep': '12'
          },

          {
            'name': 'Jump Rope (fast)',
            'image': 'images/workouts/Skip-Jump-Rope.gif',
            'sec': '45 sec'
          }, // Changed name for clarity
        ]);
  }
}
