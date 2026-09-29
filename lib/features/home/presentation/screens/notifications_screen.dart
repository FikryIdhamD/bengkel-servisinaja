import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/data/dummy_notifications.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoalDark),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Pengumuman',
          style: AppTypography.headline1.copyWith(
            color: AppColors.charcoalDark,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: dummyNotifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final notif = dummyNotifications[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: notif.isRead ? Colors.white : AppColors.primarySurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: notif.isRead
                    ? AppColors.border
                    : AppColors.primaryOrange.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: notif.isRead
                        ? AppColors.background
                        : AppColors.primaryOrange,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications,
                    color: notif.isRead
                        ? AppColors.textSecondary
                        : Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notif.title,
                        style: AppTypography.headline2.copyWith(
                          color: notif.isRead
                              ? AppColors.textPrimary
                              : AppColors.charcoalDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notif.message,
                        style: AppTypography.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
