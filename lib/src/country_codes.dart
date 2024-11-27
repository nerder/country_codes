import 'dart:async';

import 'package:country_codes/src/codes.dart';
import 'package:country_codes/src/country_details.dart';
import 'package:country_codes/src/sub_regions.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class CountryCodes {
  static const MethodChannel _channel = const MethodChannel('country_codes');
  static Locale? _deviceLocale;
  static late Map<String, String> _localizedCountryNames;

  static String? _resolveLocale(Locale? locale) {
    locale ??= _deviceLocale;
    assert(locale != null && locale.countryCode != null, '''
         Locale and country code cannot be null. If you are using an iOS simulator, please, make sure you go to region settings and select any country (even if it\'s already selected) because otherwise your country might be null.
         If you didn\'t provide one, please make sure you call init before using Country Details
        ''');
    return locale!.countryCode;
  }

  // Helper method to get flag emoji from country code
  static String getEmojiFlag(String countryCode) {
    final int firstLetter = countryCode.toUpperCase().codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = countryCode.toUpperCase().codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  static Future<bool> init([Locale? appLocale]) async {
    final List<dynamic>? locale = List<dynamic>.from(
        await (_channel.invokeMethod('getLocale', appLocale?.toLanguageTag())));
    if (locale != null) {
      String countryCode = locale[1];

      if (!codes.containsKey(countryCode)) {
        countryCode = subRegionToCountryCode[countryCode] ?? countryCode;
      }

      _deviceLocale = Locale(locale[0], countryCode);
      _localizedCountryNames = Map.from(locale[2]);
    }
    return _deviceLocale != null;
  }

  static Locale? getDeviceLocale() {
    assert(_deviceLocale != null,
        'Please, make sure you call await init() before calling getDeviceLocale()');
    return _deviceLocale;
  }

  static List<String?> dialNumbers() {
    return codes.values
        .map((each) => CountryDetails.fromMap(each).dialCode)
        .toList();
  }

  static List<CountryDetails> countryCodes() {
    return codes.entries
        .map((entry) {
          var data = Map<String, dynamic>.from(entry.value);
          data['emoji'] = getEmojiFlag(entry.key);
          return CountryDetails.fromMap(data, _localizedCountryNames[entry.key]);
        })
        .toList();
  }

  static CountryDetails detailsForLocale([Locale? locale]) {
    String? code = _resolveLocale(locale);
    var data = Map<String, dynamic>.from(codes[code!]);
    data['emoji'] = getEmojiFlag(code);
    return CountryDetails.fromMap(data, _localizedCountryNames[code]);
  }

  static CountryDetails detailsFromAlpha2(String alpha2) {
    var data = Map<String, dynamic>.from(
        codes.entries.where((entry) => entry.key == alpha2).single.value);
    data['emoji'] = getEmojiFlag(alpha2);
    return CountryDetails.fromMap(data);
  }

  static String? alpha2Code([Locale? locale]) {
    String? code = _resolveLocale(locale);
    return CountryDetails.fromMap(codes[code!], _localizedCountryNames[code])
        .alpha2Code;
  }

  static String? dialCode([Locale? locale]) {
    String? code = _resolveLocale(locale);
    return CountryDetails.fromMap(codes[code!], _localizedCountryNames[code])
        .dialCode;
  }

  static String? name({Locale? locale}) {
    String? code = _resolveLocale(locale);
    return CountryDetails.fromMap(codes[code!], _localizedCountryNames[code])
        .name;
  }

  // New method to get emoji flag
  static String? emoji([Locale? locale]) {
    String? code = _resolveLocale(locale);
    return getEmojiFlag(code!);
  }
}
