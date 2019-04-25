import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:lp_utils/helpers.dart';
import 'package:lp_utils/models.dart';
import 'package:quiver/strings.dart';
import 'package:quiver/time.dart';
// This file was generated in two steps, using the Dart intl tools. With the
// app's root directory (the one that contains pubspec.yaml) as the current
// directory:
//
// flutter pub get
// flutter pub pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/l10n/localizations.dart
// flutter pub pub run intl_translation:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/l10n/localizations.dart lib/l10n/intl_en.arb
//
// The second command generates intl_messages.arb and the third generates
// messages_all.dart. There's more about this process in
// https://pub.dartlang.org/packages/intl.
import 'package:lp_utils/l10n.dart';

class UtilLocalizations implements FieldErrorFormatter, FieldWarningFormatter {
  static Future<UtilLocalizationsContainer> load<T extends UtilLocalizations>(
      Locale locale, T Function() builder) {
    final name =
        isBlank(locale.countryCode) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return UtilLocalizationsContainer(builder());
    });
  }

  static T of<T extends UtilLocalizations>(BuildContext context) {
    return Localizations.of(context, UtilLocalizationsContainer).l10n;
  }

  ///////////////////////////////////////////////////////////////////////////////////
  /// La liste des traductions
  ///

  // Les boutons
  String get validateBtnText => validateText.toUpperCase();
  String get previousBtnText => previousText.toUpperCase();
  String get nextBtnText => nextText.toUpperCase();
  String get continueBtnText => continueText.toUpperCase();
  String get okBtnText => okText.toUpperCase();
  String get yesBtnText => yesText.toUpperCase();
  String get noBtnText => noText.toUpperCase();
  String get cancelBtnText => cancelText.toUpperCase();

  String get validateText => Intl.message('Valider');
  String get previousText => Intl.message('Précédent');
  String get nextText => Intl.message('Suivant');
  String get okText => Intl.message('Ok');
  String get yesText => Intl.message('Oui');
  String get noText => Intl.message('Non');
  String get continueText => Intl.message('Continuer');
  String get cancelText => Intl.message('Annuler');

  String get yesterdayText => Intl.message('Hier');
  String get todayText => Intl.message('Aujourd\'hui');
  String get tomorrowText => Intl.message('Demain');

  String get errorTechnicalContentText =>
      Intl.message('Erreur d\'origine inconnue.');

  String get errorTechnicalTitleText => Intl.message('Erreur technique');

  // Helpers
  String formatDuration(Duration taskDuration) {
    var nf = NumberFormat('0.##');
    return '${nf.format(taskDuration.inMinutes / 60)}h';
  }

  String formatDateTime(DateTime datetime) =>
      '${formatDate(datetime)} - ${formatTime(datetime)}';

  String formatDate(DateTime datetime) => DateFormat.yMd().format(datetime);

  String formatTime(DateTime datetime) => DateFormat.jm().format(datetime);

  String formatMonth(DateTime datetime) {
    if (clock.now().year != datetime.year) {
      return DateFormat.yMMM().format(datetime);
    }
    return DateFormat.MMM().format(datetime);
  }

  final _timeOfDayMinutesNf = NumberFormat('00');
  String formatTimeOfDay(int hour, int minute, {bool sentence = false}) {
    final minutes = _timeOfDayMinutesNf.format(minute);
    final time = Intl.message('${hour}h$minutes',
        name: 'formatTimeOfDay', args: [hour, minutes]);
    if (sentence) {
      return Intl.message('à $time',
          name: 'formatTimeOfDayWithSentence', args: [time]);
    }
    return time;
  }

  String humanizeDate(DateTime date,
      {bool weekDay = false, bool sentence = false, bool withYear = true}) {
    date = getDate(date);
    var today = getDate();

    if (date == today.subtract(aDay)) {
      return yesterdayText;
    } else if (date == today) {
      return todayText;
    } else if (date == today.add(aDay)) {
      return tomorrowText;
    } else {
      String result;
      if (weekDay) {
        result = withYear
            ? DateFormat.yMMMEd().format(date)
            : DateFormat.MMMEd().format(date);
      } else {
        result = withYear
            ? DateFormat.yMMMd().format(date)
            : DateFormat.MMMd().format(date);
      }
      if (!sentence) return result;
      return Intl.message('le $result',
          name: 'humanizeDateSentence', args: [result]);
    }
  }

  String humanizeDateTime(DateTime date,
      {bool weekDay = false, bool sentence = false, bool withYear = true}) {
    final dateHumanized = humanizeDate(date,
        weekDay: weekDay, sentence: sentence, withYear: withYear);
    final timeFormatted = formatTimeOfDay(date.hour, date.minute);
    return Intl.message('$dateHumanized à $timeFormatted',
        name: 'humanizeDateTime', args: [dateHumanized, timeFormatted]);
  }

  @override
  String formatWarning(warning,
      {int? min, int? max, int? equals, Duration? duration}) {
    switch (warning) {
      default:
        return Intl.message('Message d\'alerte inconnu',
            name: 'unknownWarningMessageText');
    }
  }

  @override
  String formatFieldError(validation,
      {int? min, int? max, int? equals, Duration? duration}) {
    switch (validation) {
      case Errors.fieldRequired:
        return Intl.message('Saisie requise', name: Errors.fieldRequired);
      case Errors.fieldMinLength:
        return Intl.message('Il faut au moins $min caractères',
            name: Errors.fieldMinLength);
      case Errors.fieldExactLength:
        return Intl.message('Il faut $equals caractères',
            name: Errors.fieldExactLength);
      case Errors.fieldMaxLength:
        return Intl.message('Le nombre de $max caractères est atteint',
            name: Errors.fieldMaxLength);
      case Errors.fieldMaxValue:
        return Intl.message('Maximum $max', name: Errors.fieldMaxValue);
      case Errors.fieldMinValue:
        return Intl.message('Minimum $min', name: Errors.fieldMinValue);
      case Errors.fieldBadFormat:
        return Intl.message('Mauvais format', name: Errors.fieldBadFormat);
      case Errors.fieldOnlyAlphanum:
        return Intl.message(
            'Ne doit contenir que des caractères et des nombres',
            name: Errors.fieldOnlyAlphanum);
      default:
        return Intl.message('Message inconnu', name: 'unknownMessageText');
    }
  }

  String formatDialogTitleError(error) => errorTechnicalTitleText;

  String formatError(error) {
    switch (error.runtimeType) {
      case HttpException:
      case SocketException:
        return Intl.message('Erreur lors de la communication avec le serveur',
            name: 'errorTechnicalText');
      default:
        return errorTechnicalContentText;
    }
  }

  String formatDialogBtnLabelError(error) => continueBtnText;
}

class UtilLocalizationsContainer {
  final UtilLocalizations l10n;

  UtilLocalizationsContainer(this.l10n);
}

typedef UtilLocalizationsBuilder<T extends UtilLocalizations> = T Function();

class UtilLocalizationsDelegate<T extends UtilLocalizations>
    extends LocalizationsDelegate<UtilLocalizationsContainer> {
  final UtilLocalizationsBuilder builder;

  UtilLocalizationsDelegate(this.builder);

  @override
  bool isSupported(Locale locale) => ['fr', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(UtilLocalizationsDelegate old) => false;

  @override
  Future<UtilLocalizationsContainer> load(Locale locale) async {
    final localizationsContainer =
        await UtilLocalizations.load(locale, builder);

    return localizationsContainer;
  }
}
