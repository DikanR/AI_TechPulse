import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  /// Formats an ISO 8601 date string to a human-readable format like "Nov 19, 2026 • 14:30"
  static String formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'Recent';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      final formatter = DateFormat('MMM d, yyyy • HH:mm');
      return formatter.format(dateTime);
    } catch (_) {
      return isoString;
    }
  }

  /// Returns friendly relative time string, such as "2h ago", "Just now", etc.
  static String timeAgo(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'Recently';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      final difference = DateTime.now().difference(dateTime);

      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return DateFormat('MMM d, yyyy').format(dateTime);
      }
    } catch (_) {
      return 'Recently';
    }
  }
}
