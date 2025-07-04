import 'package:timeago/timeago.dart' as timeago;

class ShortMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';

  @override
  String prefixFromNow() => '';

  @override
  String suffixAgo() => "";

  @override
  String suffixFromNow() => 'just now';

  @override
  String lessThanOneMinute(int seconds) {
    return 'just now';
  }

  @override
  String aboutAMinute(int minutes) => '1 min ago';
  @override
  String minutes(int minutes) => '$minutes mins ago';
  @override
  String aboutAnHour(int minutes) => '1 hr ago';
  @override
  String hours(int hours) => '$hours hrs ago';
  @override
  String aDay(int hours) => '1 day ago';
  @override
  String days(int days) => '$days days ago';
  @override
  String aboutAMonth(int days) => '1 mo ago';
  @override
  String months(int months) => '$months mos ago';
  @override
  String aboutAYear(int year) => '1 yr ago';
  @override
  String years(int years) => '$years yrs ago';
  @override
  String wordSeparator() => ' ';

}
