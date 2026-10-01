import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';

/// Jenis notifikasi / pengumuman atas (Top Announcement Banner).
enum AppNotificationType {
  /// Peringatan bahaya / error / kegagalan (Merah)
  error,

  /// Pemberitahuan / peringatan ringan / informasi (Kuning)
  warning,

  /// Konfirmasi aksi berhasil / sukses (Hijau)
  success,

  /// Informasi umum / netral (Biru)
  info,
}

class _NotificationStyleConfig {
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;

  const _NotificationStyleConfig({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
  });
}

/// Pengganti SnackBar default: Muncul dari atas (top announcement banner),
/// tidak mendorong FloatingActionButton pada bottom navigation bar,
/// dan memiliki kode warna terstandar (Merah: error/peringatan, Kuning: info/warning, Hijau: confirm/sukses).
class AppNotification {
  /// Global navigator key yang dapat dipasang ke GoRouter atau MaterialApp
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static OverlayEntry? _activeEntry;
  static _TopNotificationViewState? _activeState;

  /// Menampilkan notifikasi banner dari atas layar.
  static void show(
    BuildContext? context, {
    required String message,
    String? title,
    AppNotificationType type = AppNotificationType.info,
    Duration duration = const Duration(milliseconds: 3500),
  }) {
    // Hapus notifikasi yang sedang aktif sebelumnya agar tidak bertumpuk
    dismissImmediately();

    OverlayState? overlay;
    if (context != null && context.mounted) {
      overlay =
          Overlay.maybeOf(context, rootOverlay: true) ??
          Overlay.maybeOf(context);
    }
    overlay ??= navigatorKey.currentState?.overlay;

    if (overlay == null) {
      debugPrint(
        'AppNotification: Overlay tidak ditemukan untuk menampilkan notifikasi.',
      );
      return;
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _TopNotificationView(
        message: message,
        title: title,
        type: type,
        duration: duration,
        onDismissed: () {
          if (_activeEntry == entry) {
            try {
              if (entry.mounted) {
                entry.remove();
              }
            } catch (_) {}
            _activeEntry = null;
            _activeState = null;
          }
        },
        onStateReady: (state) {
          _activeState = state;
        },
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);
  }

  /// Menampilkan notifikasi sukses / konfirmasi (HIJAU).
  static void showSuccess(
    BuildContext? context,
    String message, {
    String? title,
    Duration duration = const Duration(milliseconds: 3200),
  }) {
    show(
      context,
      message: message,
      title: title,
      type: AppNotificationType.success,
      duration: duration,
    );
  }

  /// Menampilkan notifikasi peringatan / error / kegagalan (MERAH).
  static void showError(
    BuildContext? context,
    String message, {
    String? title,
    Duration duration = const Duration(milliseconds: 4000),
  }) {
    show(
      context,
      message: message,
      title: title,
      type: AppNotificationType.error,
      duration: duration,
    );
  }

  /// Menampilkan notifikasi pemberitahuan / catatan / peringatan ringan (KUNING).
  static void showWarning(
    BuildContext? context,
    String message, {
    String? title,
    Duration duration = const Duration(milliseconds: 3500),
  }) {
    show(
      context,
      message: message,
      title: title,
      type: AppNotificationType.warning,
      duration: duration,
    );
  }

  /// Menampilkan notifikasi informasi umum (BIRU).
  static void showInfo(
    BuildContext? context,
    String message, {
    String? title,
    Duration duration = const Duration(milliseconds: 3200),
  }) {
    show(
      context,
      message: message,
      title: title,
      type: AppNotificationType.info,
      duration: duration,
    );
  }

  /// Menutup notifikasi aktif dengan animasi keluar.
  static void dismiss() {
    _activeState?.dismiss();
  }

  /// Menutup notifikasi aktif secara instan tanpa menunggu animasi.
  static void dismissImmediately() {
    if (_activeEntry != null) {
      try {
        if (_activeEntry!.mounted) {
          _activeEntry!.remove();
        }
      } catch (_) {}
      _activeEntry = null;
      _activeState = null;
    }
  }
}

class _TopNotificationView extends StatefulWidget {
  final String message;
  final String? title;
  final AppNotificationType type;
  final Duration duration;
  final VoidCallback onDismissed;
  final ValueChanged<_TopNotificationViewState> onStateReady;

  const _TopNotificationView({
    required this.message,
    this.title,
    required this.type,
    required this.duration,
    required this.onDismissed,
    required this.onStateReady,
  });

  @override
  State<_TopNotificationView> createState() => _TopNotificationViewState();
}

class _TopNotificationViewState extends State<_TopNotificationView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _dismissTimer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    widget.onStateReady(this);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 250),
    );

    _offsetAnimation =
        Tween<Offset>(begin: const Offset(0.0, -1.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _controller.forward();

    _dismissTimer = Timer(widget.duration, () {
      dismiss();
    });
  }

  void dismiss() {
    if (_isDismissing || !mounted) return;
    _isDismissing = true;
    _dismissTimer?.cancel();
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  _NotificationStyleConfig _getStyleConfig() {
    switch (widget.type) {
      case AppNotificationType.error:
        return const _NotificationStyleConfig(
          backgroundColor: AppColors.statusError,
          foregroundColor: Colors.white,
          icon: Icons.error_outline_rounded,
        );
      case AppNotificationType.warning:
        return const _NotificationStyleConfig(
          backgroundColor: AppColors.statusWaiting,
          foregroundColor: Color(0xFF1E293B),
          icon: Icons.warning_amber_rounded,
        );
      case AppNotificationType.success:
        return const _NotificationStyleConfig(
          backgroundColor: AppColors.statusSuccess,
          foregroundColor: Colors.white,
          icon: Icons.check_circle_outline_rounded,
        );
      case AppNotificationType.info:
        return const _NotificationStyleConfig(
          backgroundColor: AppColors.statusProgress,
          foregroundColor: Colors.white,
          icon: Icons.info_outline_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _getStyleConfig();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SlideTransition(
            position: _offsetAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  // Geser ke atas untuk menutup
                  if (details.primaryDelta != null &&
                      details.primaryDelta! < -4) {
                    dismiss();
                  }
                },
                child: Material(
                  color: Colors.transparent,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: style.backgroundColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: style.foregroundColor.withValues(
                              alpha: 0.15,
                            ),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.14),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: style.backgroundColor.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: style.foregroundColor.withValues(
                                  alpha: 0.18,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                style.icon,
                                color: style.foregroundColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.title != null &&
                                      widget.title!.isNotEmpty) ...[
                                    Text(
                                      widget.title!,
                                      style: AppTypography.headline2.copyWith(
                                        fontSize: 14,
                                        color: style.foregroundColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                  ],
                                  Text(
                                    widget.message,
                                    style: AppTypography.body1Medium.copyWith(
                                      fontSize: 13,
                                      color: style.foregroundColor,
                                      fontWeight: widget.title != null
                                          ? FontWeight.normal
                                          : FontWeight.w600,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: dismiss,
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: style.foregroundColor.withValues(
                                    alpha: 0.75,
                                  ),
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Extension helper pada [BuildContext] agar pemanggilan lebih ringkas
extension AppNotificationContextExtension on BuildContext {
  void showSuccessNotification(
    String message, {
    String? title,
    Duration duration = const Duration(milliseconds: 3200),
  }) {
    AppNotification.showSuccess(
      this,
      message,
      title: title,
      duration: duration,
    );
  }

  void showErrorNotification(
    String message, {
    String? title,
    Duration duration = const Duration(milliseconds: 4000),
  }) {
    AppNotification.showError(this, message, title: title, duration: duration);
  }

  void showWarningNotification(
    String message, {
    String? title,
    Duration duration = const Duration(milliseconds: 3500),
  }) {
    AppNotification.showWarning(
      this,
      message,
      title: title,
      duration: duration,
    );
  }

  void showInfoNotification(
    String message, {
    String? title,
    Duration duration = const Duration(milliseconds: 3200),
  }) {
    AppNotification.showInfo(this, message, title: title, duration: duration);
  }
}
