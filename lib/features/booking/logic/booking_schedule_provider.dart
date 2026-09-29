import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/workshop.dart';
import '../../../../core/data/dummy_workshops.dart';

class ScheduleDraft {
  final Workshop? selectedWorkshop;
  final DateTime? selectedDate;
  final String? selectedTimeSlot;

  const ScheduleDraft({
    this.selectedWorkshop,
    this.selectedDate,
    this.selectedTimeSlot,
  });

  ScheduleDraft copyWith({
    Workshop? selectedWorkshop,
    DateTime? selectedDate,
    String? selectedTimeSlot,
  }) {
    return ScheduleDraft(
      selectedWorkshop: selectedWorkshop ?? this.selectedWorkshop,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
    );
  }

  bool get isValid =>
      selectedWorkshop != null &&
      selectedDate != null &&
      selectedTimeSlot != null;
}

final bookingScheduleProvider =
    NotifierProvider<BookingScheduleNotifier, ScheduleDraft>(
      BookingScheduleNotifier.new,
    );

class BookingScheduleNotifier extends Notifier<ScheduleDraft> {
  @override
  ScheduleDraft build() {
    return ScheduleDraft(
      selectedDate: DateTime.now(),
      selectedWorkshop: defaultWorkshops.firstWhere(
        (w) => w.name.contains('Cipete'),
        orElse: () => defaultWorkshops.first,
      ),
    );
  }

  void setWorkshop(Workshop workshop) {
    state = state.copyWith(selectedWorkshop: workshop);
  }

  void setDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void setTimeSlot(String timeSlot) {
    state = state.copyWith(selectedTimeSlot: timeSlot);
  }

  void reset() {
    state = ScheduleDraft(
      selectedDate: DateTime.now(),
      selectedWorkshop: defaultWorkshops.firstWhere(
        (w) => w.name.contains('Cipete'),
        orElse: () => defaultWorkshops.first,
      ),
    );
  }
}
