import 'package:etsport/pages/Discovery/quick_pump.dart';
import 'package:etsport/pages/HOME%20WORKOUT/chest/beginner.dart';
import 'package:flutter/material.dart';

class BellyFat extends StatelessWidget {
  const BellyFat({super.key});

  @override
  Widget build(BuildContext context) {
    return const ReusableWorkoutPage(
        title: 'Cardio',
        subtitle: '7 Min Workout',
        backgroundImage: 'images/discovery/belly fat.webp',
        workouts: [
          {
            'name': 'Jumping Jacks',
            'image': 'images/workouts/jumping-jack.gif',
            'sec': '30 sec'
          },
          {
            'name': 'High Knees',
            'image': 'images/workouts/high-knees.gif',
            'sec': '45 sec'
          },
          {
            'name': 'Butt Kicks',
            'image': 'images/workouts/butt-kicks.gif',
            'sec': '50 sec'
          }, // Adjusted
          {
            'name': 'Jog in Place',
            'image': 'images/workouts/jog-in-place.gif',
            'sec': '60 sec'
          }, // Adjusted
          {
            'name': 'Shadow Boxing',
            'image': 'images/workouts/shadow-boxing.gif',
            'sec': '30 sec'
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
            'name': 'Burpees (no push-up)',
            'image': 'images/workouts/Burpees.gif',
            'rep': '15'
          },

          {
            'name': 'Jump Squats',
            'image': 'images/workouts/jump-squats.gif',
            'rep': '15'
          },

          {
            'name': 'Jump Rope (fast)',
            'image': 'images/workouts/Skip-Jump-Rope.gif',
            'sec': '45 sec'
          }, // Changed name for clarity
        ]);
  }
}
