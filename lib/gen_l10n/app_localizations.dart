import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en')
  ];

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'ET'**
  String get home;

  /// No description provided for @workout.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workout;

  /// No description provided for @fullbody.
  ///
  /// In en, this message translates to:
  /// **'Full Body'**
  String get fullbody;

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get running;

  /// No description provided for @kmTracking.
  ///
  /// In en, this message translates to:
  /// **'KM Tracking'**
  String get kmTracking;

  /// No description provided for @weightLoss.
  ///
  /// In en, this message translates to:
  /// **'Weight Loss'**
  String get weightLoss;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @discovery.
  ///
  /// In en, this message translates to:
  /// **'Discovery'**
  String get discovery;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @homeWorkout.
  ///
  /// In en, this message translates to:
  /// **'Home Workout'**
  String get homeWorkout;

  /// No description provided for @gymWorkout.
  ///
  /// In en, this message translates to:
  /// **'Gym Workout'**
  String get gymWorkout;

  /// No description provided for @withEquipment.
  ///
  /// In en, this message translates to:
  /// **'With Equipment'**
  String get withEquipment;

  /// No description provided for @specificBody.
  ///
  /// In en, this message translates to:
  /// **'Specific Body'**
  String get specificBody;

  /// No description provided for @calisthenics.
  ///
  /// In en, this message translates to:
  /// **'Calisthenics'**
  String get calisthenics;

  /// No description provided for @bodyWeightExercises.
  ///
  /// In en, this message translates to:
  /// **'Body Weight Exercises'**
  String get bodyWeightExercises;

  /// No description provided for @see_all.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get see_all;

  /// No description provided for @chestAndBiceps.
  ///
  /// In en, this message translates to:
  /// **'Chest & Biceps'**
  String get chestAndBiceps;

  /// No description provided for @strengthTone15Moves.
  ///
  /// In en, this message translates to:
  /// **'Strength & Tone • 15 Moves'**
  String get strengthTone15Moves;

  /// No description provided for @sixToEightReps.
  ///
  /// In en, this message translates to:
  /// **'6–8 Reps'**
  String get sixToEightReps;

  /// No description provided for @weightGain.
  ///
  /// In en, this message translates to:
  /// **'Weight Gain'**
  String get weightGain;

  /// No description provided for @sevenMin.
  ///
  /// In en, this message translates to:
  /// **'7 Min'**
  String get sevenMin;

  /// No description provided for @skinCare.
  ///
  /// In en, this message translates to:
  /// **'Skin Care'**
  String get skinCare;

  /// No description provided for @noEquipment.
  ///
  /// In en, this message translates to:
  /// **'No Equipment'**
  String get noEquipment;

  /// No description provided for @days30.
  ///
  /// In en, this message translates to:
  /// **'30 Days'**
  String get days30;

  /// No description provided for @nutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutrition;

  /// No description provided for @homeCardio.
  ///
  /// In en, this message translates to:
  /// **'Home Cardio'**
  String get homeCardio;

  /// No description provided for @buttWork.
  ///
  /// In en, this message translates to:
  /// **'Butt Workout'**
  String get buttWork;

  /// No description provided for @quickPump.
  ///
  /// In en, this message translates to:
  /// **'Quick Pump'**
  String get quickPump;

  /// No description provided for @dumbbells.
  ///
  /// In en, this message translates to:
  /// **'Dumbbells'**
  String get dumbbells;

  /// No description provided for @fiveMin.
  ///
  /// In en, this message translates to:
  /// **'5 Min'**
  String get fiveMin;

  /// No description provided for @bellyFat.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get bellyFat;

  /// No description provided for @tenMin.
  ///
  /// In en, this message translates to:
  /// **'10 Min'**
  String get tenMin;

  /// No description provided for @dailyStretch.
  ///
  /// In en, this message translates to:
  /// **'Daily Stretch'**
  String get dailyStretch;

  /// No description provided for @startnow.
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get startnow;

  /// No description provided for @mostpopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get mostpopular;

  /// No description provided for @quicktips.
  ///
  /// In en, this message translates to:
  /// **'Quick Tips'**
  String get quicktips;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @editprofile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editprofile;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @sure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get sure;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @motivation.
  ///
  /// In en, this message translates to:
  /// **'Your Motivation'**
  String get motivation;

  /// No description provided for @saveprofile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveprofile;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @confirmlogout.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmlogout;

  /// No description provided for @recentworkouts.
  ///
  /// In en, this message translates to:
  /// **'Recent Workouts'**
  String get recentworkouts;

  /// No description provided for @norecent.
  ///
  /// In en, this message translates to:
  /// **'No recent workouts found'**
  String get norecent;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @resetprogress.
  ///
  /// In en, this message translates to:
  /// **'Reset Progress'**
  String get resetprogress;

  /// No description provided for @setting.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get setting;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['am', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am': return AppLocalizationsAm();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
