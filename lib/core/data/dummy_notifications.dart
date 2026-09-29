class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    this.isRead = false,
  });
}

final List<NotificationItem> dummyNotifications = [
  NotificationItem(
    id: 'n1',
    title: 'Waktunya Servis Berkala!',
    message:
        'Honda Vario 150 Anda sudah waktunya servis bulan ini. Yuk jadwalkan sekarang di PitStop!',
    date: DateTime.now().subtract(const Duration(hours: 2)),
    isRead: false,
  ),
  NotificationItem(
    id: 'n2',
    title: 'Promo Ganti Oli 20%',
    message:
        'Khusus pengguna baru, dapatkan diskon 20% untuk penggantian oli mesin MPX2.',
    date: DateTime.now().subtract(const Duration(days: 1)),
    isRead: false,
  ),
  NotificationItem(
    id: 'n3',
    title: 'Servis Selesai',
    message:
        'Servis untuk Yamaha NMAX Anda telah selesai. Silakan ambil di bengkel PitStop BSD.',
    date: DateTime.now().subtract(const Duration(days: 3)),
    isRead: true,
  ),
  NotificationItem(
    id: 'n4',
    title: 'Bengkel Baru di Bandung!',
    message:
        'PitStop kini hadir di Bandung Pasteur. Kunjungi kami untuk layanan terbaik.',
    date: DateTime.now().subtract(const Duration(days: 7)),
    isRead: true,
  ),
];
