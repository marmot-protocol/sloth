import 'package:flutter/widgets.dart';
import 'package:whitenoise/l10n/generated/app_localizations.dart';

export 'package:whitenoise/l10n/generated/app_localizations.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
