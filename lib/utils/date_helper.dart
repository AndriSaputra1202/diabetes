// Utility class untuk manipulasi dan formatting tanggal
// Menggunakan locale Indonesia untuk format yang user-friendly
import 'package:intl/intl.dart';

class DateHelper {
  static const String _locale = 'id_ID';

  static String formatDate(DateTime date) {
    try {
      final formatter = DateFormat('d MMMM yyyy', _locale);
      return formatter.format(date);
    } catch (e) {
      return date.toString();
    }
  }

  static String formatDateShort(DateTime date) {
    try {
      final formatter = DateFormat('d MMM yyyy', _locale);
      return formatter.format(date);
    } catch (e) {
      return date.toString();
    }
  }

  static String formatTime(DateTime date) {
    try {
      final formatter = DateFormat('HH:mm', _locale);
      return formatter.format(date);
    } catch (e) {
      return date.toString();
    }
  }

  static String formatDateTime(DateTime date) {
    try {
      final formatter = DateFormat('d MMM yyyy, HH:mm', _locale);
      return formatter.format(date);
    } catch (e) {
      return date.toString();
    }
  }

  static String formatDateTimeFull(DateTime date) {
    try {
      final formatter = DateFormat('EEEE, d MMMM yyyy HH:mm', _locale);
      return formatter.format(date);
    } catch (e) {
      return date.toString();
    }
  }

  static String formatDateForDatabase(DateTime date) {
    try {
      final formatter = DateFormat('yyyy-MM-dd');
      return formatter.format(date);
    } catch (e) {
      return date.toIso8601String().split('T')[0];
    }
  }

  static String formatDateWithDay(DateTime date) {
    try {
      final formatter = DateFormat('EEEE, d MMMM yyyy', _locale);
      return formatter.format(date);
    } catch (e) {
      return date.toString();
    }
  }

  static String formatDateWithDayShort(DateTime date) {
    try {
      final formatter = DateFormat('EEE, d MMM yyyy', _locale);
      return formatter.format(date);
    } catch (e) {
      return date.toString();
    }
  }

  static String formatDateRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final tomorrow = today.add(Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (isSameDay(targetDate, today)) {
      return 'Hari ini';
    } else if (isSameDay(targetDate, yesterday)) {
      return 'Kemarin';
    } else if (isSameDay(targetDate, tomorrow)) {
      return 'Besok';
    } else {
      return formatDateShort(date);
    }
  }

  static String getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks minggu lalu';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months bulan lalu';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years tahun lalu';
    }
  }

  // Get nama bulan dalam bahasa Indonesia
  // Example: "November"
  //
  // Parameters:
  // - month: Nomor bulan (1-12)
  //
  // Returns: String nama bulan
  static String getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    if (month < 1 || month > 12) {
      return '';
    }

    return months[month - 1];
  }

  // Get nama hari dalam bahasa Indonesia
  // Example: "Senin"
  //
  // Parameters:
  // - date: DateTime
  //
  // Returns: String nama hari
  static String getDayName(DateTime date) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    return days[date.weekday - 1];
  }

  // Get tanggal hari ini (jam 00:00:00)
  // Returns: DateTime today at midnight
  static DateTime getToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // Get tanggal kemarin (jam 00:00:00)
  // Returns: DateTime yesterday at midnight
  static DateTime getYesterday() {
    final today = getToday();
    return today.subtract(Duration(days: 1));
  }

  // Get tanggal besok (jam 00:00:00)
  // Returns: DateTime tomorrow at midnight
  static DateTime getTomorrow() {
    final today = getToday();
    return today.add(Duration(days: 1));
  }

  // Get tanggal N hari yang lalu

  // Parameters:
  // - days: Jumlah hari ke belakang
  // Returns: DateTime N days ago at midnight
  static DateTime getDaysAgo(int days) {
    final today = getToday();
    return today.subtract(Duration(days: days));
  }

  static DateTime getDaysFromNow(int days) {
    final today = getToday();
    return today.add(Duration(days: days));
  }

  static Map<String, DateTime> getWeekRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Cari hari Senin minggu ini
    final monday = today.subtract(Duration(days: today.weekday - 1));

    // Cari hari Minggu minggu ini
    final sunday = monday.add(Duration(days: 6));

    return {'start': monday, 'end': sunday};
  }

  static Map<String, DateTime> getMonthRange() {
    final now = DateTime.now();

    // Tanggal 1 bulan ini
    final firstDay = DateTime(now.year, now.month, 1);

    // Tanggal terakhir bulan ini
    final lastDay = DateTime(now.year, now.month + 1, 0);

    return {'start': firstDay, 'end': lastDay};
  }

  static Map<String, DateTime> getLast7DaysRange() {
    final today = getToday();
    final sevenDaysAgo = today.subtract(Duration(days: 6));

    return {'start': sevenDaysAgo, 'end': today};
  }

  static Map<String, DateTime> getLast30DaysRange() {
    final today = getToday();
    final thirtyDaysAgo = today.subtract(Duration(days: 29));

    return {'start': thirtyDaysAgo, 'end': today};
  }

  static Map<String, DateTime> getYearRange() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, 1, 1);
    final lastDay = DateTime(now.year, 12, 31);

    return {'start': firstDay, 'end': lastDay};
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = getYesterday();
    return isSameDay(date, yesterday);
  }

  // Check apakah tanggal adalah besok
  // Returns: bool true jika besok
  static bool isTomorrow(DateTime date) {
    final tomorrow = getTomorrow();
    return isSameDay(date, tomorrow);
  }

  // Check apakah dua tanggal adalah hari yang sama
  // Returns: bool true jika sama
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Check apakah date1 sebelum date2 (hanya membandingkan tanggal, tidak jam)
  // Returns: bool true jika date1 sebelum date2
  static bool isBeforeDay(DateTime date1, DateTime date2) {
    final d1 = DateTime(date1.year, date1.month, date1.day);
    final d2 = DateTime(date2.year, date2.month, date2.day);
    return d1.isBefore(d2);
  }

  // Check apakah date1 sesudah date2 (hanya membandingkan tanggal, tidak jam)
  // Returns: bool true jika date1 sesudah date2
  static bool isAfterDay(DateTime date1, DateTime date2) {
    final d1 = DateTime(date1.year, date1.month, date1.day);
    final d2 = DateTime(date2.year, date2.month, date2.day);
    return d1.isAfter(d2);
  }

  // Hitung jumlah hari antara dua tanggal
  // Returns: int jumlah hari (bisa negatif jika start > end)
  static int daysBetween(DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    return endDate.difference(startDate).inDays;
  }

  // Hitung umur dari tanggal lahir
  // Returns: int umur dalam tahun
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  // Check apakah tanggal berada dalam range
  // Returns: bool true jika dalam range
  static bool isInRange(DateTime date, DateTime start, DateTime end) {
    final targetDate = DateTime(date.year, date.month, date.day);
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    return (targetDate.isAtSameMomentAs(startDate) ||
            targetDate.isAfter(startDate)) &&
        (targetDate.isAtSameMomentAs(endDate) || targetDate.isBefore(endDate));
  }

  // Parse string tanggal dari database
  // Returns: DateTime atau null jika parsing gagal
  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Get list tanggal dalam range
  // Returns: List<DateTime> semua tanggal dalam range
  static List<DateTime> getDateRange(DateTime start, DateTime end) {
    List<DateTime> dates = [];
    DateTime current = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    while (!current.isAfter(endDate)) {
      dates.add(current);
      current = current.add(Duration(days: 1));
    }

    return dates;
  }

  // Get jumlah hari dalam bulan
  // Returns: int jumlah hari dalam bulan
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  // Check apakah tahun kabisat
  // Returns: bool true jika tahun kabisat
  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  // Get waktu saat ini dalam format HH:mm
  // Returns: String current time
  static String getCurrentTime() {
    return formatTime(DateTime.now());
  }

  // Get tanggal saat ini dalam format lengkap
  // Returns: String current date
  static String getCurrentDate() {
    return formatDate(DateTime.now());
  }
}
