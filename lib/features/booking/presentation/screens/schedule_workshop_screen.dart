import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../logic/multi_vehicle_selection_provider.dart';
import '../../logic/booking_schedule_provider.dart';
import '../../logic/booking_summary_computed_provider.dart';

class ScheduleWorkshopScreen extends ConsumerWidget {
  const ScheduleWorkshopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleState = ref.watch(bookingScheduleProvider);
    final selectedVehicles = ref.watch(selectedVehiclesProvider);
    final summary = ref.watch(bookingSummaryComputedProvider);

    final today = DateTime.now();
    final timeSlots = ['09:00', '10:00', '11:00', '13:00', '14:00', '15:00'];

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
          'Jadwal Kedatangan',
          style: AppTypography.headline1.copyWith(
            color: AppColors.charcoalDark,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tanggal Kedatangan', style: AppTypography.headline2),
                  const SizedBox(height: 12),
                  _DateDropdownSelector(
                    initialDate: scheduleState.selectedDate ?? today,
                    onDateChanged: (date) {
                      ref.read(bookingScheduleProvider.notifier).setDate(date);
                    },
                  ),

                  const SizedBox(height: 24),
                  Text('Jam Kedatangan', style: AppTypography.headline2),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.5,
                        ),
                    itemCount: timeSlots.length,
                    itemBuilder: (context, index) {
                      final time = timeSlots[index];
                      final isSelected = scheduleState.selectedTimeSlot == time;
                      return GestureDetector(
                        onTap: () => ref
                            .read(bookingScheduleProvider.notifier)
                            .setTimeSlot(time),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryOrange
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryOrange
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            time,
                            style: AppTypography.body1Medium.copyWith(
                              color: isSelected
                                  ? AppColors.background
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  if (scheduleState.isValid) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryOrange.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Simulasi Penomoran Antrean Pit',
                            style: AppTypography.body1Medium.copyWith(
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...selectedVehicles.asMap().entries.map((e) {
                            final unitNum = e.key + 1;
                            final vehicle = e.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryOrange,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '#0$unitNum',
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.background,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Unit $unitNum (${vehicle.modelName})',
                                      style: AppTypography.body2.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    scheduleState.selectedTimeSlot!,
                                    style: AppTypography.body2.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Estimasi Total Durasi:',
                                style: AppTypography.body1Medium,
                              ),
                              Text(
                                '${summary.totalDurationMinutes} Menit',
                                style: AppTypography.headline2.copyWith(
                                  color: AppColors.primaryOrange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: PrimaryButton(
                text: 'Ke Ringkasan Pemesanan',
                onPressed: scheduleState.isValid
                    ? () {
                        context.push('/summary-checkout');
                      }
                    : null,
                backgroundColor: scheduleState.isValid
                    ? AppColors.primaryOrange
                    : AppColors.disabled,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateDropdownSelector extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateChanged;

  const _DateDropdownSelector({
    required this.initialDate,
    required this.onDateChanged,
  });

  @override
  State<_DateDropdownSelector> createState() => _DateDropdownSelectorState();
}

class _DateDropdownSelectorState extends State<_DateDropdownSelector> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
    _selectedDay = widget.initialDate.day;
  }

  int _getDaysInMonth(int year, int month) {
    if (month == 2) {
      bool isLeapYear =
          (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));
      return isLeapYear ? 29 : 28;
    }
    const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysInMonth[month - 1];
  }

  void _updateDate() {
    final maxDays = _getDaysInMonth(_selectedYear, _selectedMonth);
    if (_selectedDay > maxDays) {
      _selectedDay = maxDays;
    }
    widget.onDateChanged(DateTime(_selectedYear, _selectedMonth, _selectedDay));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final maxDays = _getDaysInMonth(_selectedYear, _selectedMonth);

    return Row(
      children: [
        // Tanggal
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedDay,
                isExpanded: true,
                items: List.generate(maxDays, (i) => i + 1).map((day) {
                  return DropdownMenuItem(
                    value: day,
                    child: Text(day.toString().padLeft(2, '0')),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    _selectedDay = val;
                    _updateDate();
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Bulan
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedMonth,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Jan')),
                  DropdownMenuItem(value: 2, child: Text('Feb')),
                  DropdownMenuItem(value: 3, child: Text('Mar')),
                  DropdownMenuItem(value: 4, child: Text('Apr')),
                  DropdownMenuItem(value: 5, child: Text('Mei')),
                  DropdownMenuItem(value: 6, child: Text('Jun')),
                  DropdownMenuItem(value: 7, child: Text('Jul')),
                  DropdownMenuItem(value: 8, child: Text('Agu')),
                  DropdownMenuItem(value: 9, child: Text('Sep')),
                  DropdownMenuItem(value: 10, child: Text('Okt')),
                  DropdownMenuItem(value: 11, child: Text('Nov')),
                  DropdownMenuItem(value: 12, child: Text('Des')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    _selectedMonth = val;
                    _updateDate();
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Tahun
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedYear,
                isExpanded: true,
                items: [
                  DropdownMenuItem(
                    value: DateTime.now().year,
                    child: Text('${DateTime.now().year}'),
                  ),
                  DropdownMenuItem(
                    value: DateTime.now().year + 1,
                    child: Text('${DateTime.now().year + 1}'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    _selectedYear = val;
                    _updateDate();
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
