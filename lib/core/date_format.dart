/// Simple date and time text (no extra packages).
class DateText {
  DateText._();

  static const List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const List<String> _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// "Tue 04 Nov, 09:30"
  static String full(DateTime d) =>
      '${_days[d.weekday - 1]} ${_two(d.day)} ${_months[d.month - 1]}, ${_two(d.hour)}:${_two(d.minute)}';

  /// "04 Nov 2026"
  /// Same as [full].
  static String when(DateTime d) => full(d);

  static String day(DateTime d) => '${_two(d.day)} ${_months[d.month - 1]} ${d.year}';
}
