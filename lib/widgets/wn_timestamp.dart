import 'package:flutter/material.dart';
import 'package:sloth/l10n/generated/app_localizations.dart';
import 'package:sloth/theme.dart';

class WnTimestamp extends StatelessWidget {
  const WnTimestamp({
    super.key,
    required this.timestamp,
    this.now,
  });

  final DateTime timestamp;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typographyScaled;
    final l10n = AppLocalizations.of(context);
    final text = _formatTimestamp(l10n);

    return Text(
      text,
      style: typography.medium12.copyWith(color: colors.backgroundContentSecondary),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  String _formatTimestamp(AppLocalizations l10n) {
    final currentTime = now ?? DateTime.now();
    final difference = currentTime.difference(timestamp);

    if (difference.inSeconds < 60) {
      return l10n.timestampNow;
    }

    if (difference.inMinutes < 60) {
      return l10n.timestampMinutes(difference.inMinutes);
    }

    if (difference.inHours < 12) {
      return l10n.timestampHours(difference.inHours);
    }

    if (_isSameDay(timestamp, currentTime)) {
      return _formatTime(timestamp);
    }

    if (_isYesterday(timestamp, currentTime)) {
      return l10n.timestampYesterday;
    }

    final normalizedTimestamp = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final normalizedCurrent = DateTime(currentTime.year, currentTime.month, currentTime.day);
    final dayDiff = normalizedCurrent.difference(normalizedTimestamp).inDays;

    if (dayDiff >= 2 && dayDiff <= 6) {
      return _formatWeekday(timestamp, l10n);
    }

    if (_isWithinOneYear(timestamp, currentTime)) {
      return _formatMonthDay(timestamp, l10n);
    }

    return _formatFullDate(timestamp, l10n);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  bool _isYesterday(DateTime date, DateTime currentTime) {
    final yesterday = DateTime(currentTime.year, currentTime.month, currentTime.day - 1);
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  bool _isWithinOneYear(DateTime date, DateTime currentTime) {
    return currentTime.difference(date).inDays <= 365;
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatWeekday(DateTime date, AppLocalizations l10n) {
    return switch (date.weekday) {
      DateTime.monday => l10n.weekdayMonday,
      DateTime.tuesday => l10n.weekdayTuesday,
      DateTime.wednesday => l10n.weekdayWednesday,
      DateTime.thursday => l10n.weekdayThursday,
      DateTime.friday => l10n.weekdayFriday,
      DateTime.saturday => l10n.weekdaySaturday,
      DateTime.sunday => l10n.weekdaySunday,
      _ => '',
    };
  }

  String _monthShortName(int month, AppLocalizations l10n) {
    return switch (month) {
      1 => l10n.monthJanShort,
      2 => l10n.monthFebShort,
      3 => l10n.monthMarShort,
      4 => l10n.monthAprShort,
      5 => l10n.monthMayShort,
      6 => l10n.monthJunShort,
      7 => l10n.monthJulShort,
      8 => l10n.monthAugShort,
      9 => l10n.monthSepShort,
      10 => l10n.monthOctShort,
      11 => l10n.monthNovShort,
      12 => l10n.monthDecShort,
      _ => '',
    };
  }

  String _formatMonthDay(DateTime date, AppLocalizations l10n) {
    final month = _monthShortName(date.month, l10n);
    return '$month ${date.day}';
  }

  String _formatFullDate(DateTime date, AppLocalizations l10n) {
    final month = _monthShortName(date.month, l10n);
    return '$month ${date.day}, ${date.year}';
  }
}
