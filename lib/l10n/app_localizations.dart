import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
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
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @academy.
  ///
  /// In en, this message translates to:
  /// **'My Communication Academy'**
  String get academy;

  /// No description provided for @headline.
  ///
  /// In en, this message translates to:
  /// **'Build your next skill.'**
  String get headline;

  /// No description provided for @intro.
  ///
  /// In en, this message translates to:
  /// **'Practical learning for curious engineers.'**
  String get intro;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search courses'**
  String get search;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @telecom.
  ///
  /// In en, this message translates to:
  /// **'Telecom'**
  String get telecom;

  /// No description provided for @programming.
  ///
  /// In en, this message translates to:
  /// **'Programming'**
  String get programming;

  /// No description provided for @ai.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get ai;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// No description provided for @intermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @unspecified.
  ///
  /// In en, this message translates to:
  /// **'Unspecified'**
  String get unspecified;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @priceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Price unavailable'**
  String get priceUnavailable;

  /// No description provided for @ratingUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Rating unavailable'**
  String get ratingUnavailable;

  /// No description provided for @durationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Duration unavailable'**
  String get durationUnavailable;

  /// No description provided for @catalogError.
  ///
  /// In en, this message translates to:
  /// **'Courses could not load'**
  String get catalogError;

  /// No description provided for @tryLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again in a moment.'**
  String get tryLater;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No courses found'**
  String get emptyTitle;

  /// No description provided for @emptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Try another search or category.'**
  String get emptyMessage;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @refreshError.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh. Your previous courses are still here.'**
  String get refreshError;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Course details'**
  String get details;

  /// No description provided for @missingTitle.
  ///
  /// In en, this message translates to:
  /// **'Course no longer available'**
  String get missingTitle;

  /// No description provided for @missingMessage.
  ///
  /// In en, this message translates to:
  /// **'This course may have been removed from the academy.'**
  String get missingMessage;

  /// No description provided for @detailError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this course'**
  String get detailError;

  /// No description provided for @temporaryMessage.
  ///
  /// In en, this message translates to:
  /// **'There is a temporary problem. Please try again.'**
  String get temporaryMessage;

  /// No description provided for @instructorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Instructor unavailable'**
  String get instructorUnavailable;

  /// No description provided for @descriptionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No description available.'**
  String get descriptionUnavailable;

  /// No description provided for @lessons.
  ///
  /// In en, this message translates to:
  /// **'Course lessons'**
  String get lessons;

  /// No description provided for @emptyLessons.
  ///
  /// In en, this message translates to:
  /// **'No lessons available yet'**
  String get emptyLessons;

  /// No description provided for @checkBack.
  ///
  /// In en, this message translates to:
  /// **'Please check back later.'**
  String get checkBack;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @lockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Enroll in this course to access this lesson.'**
  String get lockedMessage;

  /// No description provided for @chooseTitle.
  ///
  /// In en, this message translates to:
  /// **'Your next skill starts here'**
  String get chooseTitle;

  /// No description provided for @chooseMessage.
  ///
  /// In en, this message translates to:
  /// **'Select a course to explore its lessons.'**
  String get chooseMessage;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get language;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back to courses'**
  String get back;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading courses'**
  String get loading;

  /// No description provided for @courseCount.
  ///
  /// In en, this message translates to:
  /// **'{count} courses'**
  String courseCount(int count);

  /// No description provided for @minuteCount.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minuteCount(int count);

  /// No description provided for @secondCount.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min {seconds} sec'**
  String secondCount(int minutes, int seconds);

  /// No description provided for @lessonNumber.
  ///
  /// In en, this message translates to:
  /// **'Lesson {number}'**
  String lessonNumber(int number);

  /// No description provided for @playing.
  ///
  /// In en, this message translates to:
  /// **'Playing: {title}'**
  String playing(String title);

  /// No description provided for @totalDuration.
  ///
  /// In en, this message translates to:
  /// **'{duration} total'**
  String totalDuration(String duration);

  /// No description provided for @partialDuration.
  ///
  /// In en, this message translates to:
  /// **'{duration} known · {count} lesson duration(s) unavailable'**
  String partialDuration(String duration, int count);

  /// No description provided for @savedCatalog.
  ///
  /// In en, this message translates to:
  /// **'Saved courses · {time}'**
  String savedCatalog(String time);

  /// No description provided for @openCourse.
  ///
  /// In en, this message translates to:
  /// **'Open course: {title}'**
  String openCourse(String title);
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return L10nAr();
    case 'en':
      return L10nEn();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
