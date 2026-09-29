import 'package:flutter_riverpod/flutter_riverpod.dart';

class Workshop {
  final String id;
  final String name;
  final String address;
  final String city;

  const Workshop(this.id, this.name, this.address, this.city);
}

const defaultWorkshops = [
  Workshop('WS_1', 'BSD Autoparts', 'Jl. Letnan Sutopo', 'Tangerang Selatan'),
  Workshop('WS_2', 'Cipete Raya', 'Jl. Cipete Raya No. 12', 'Jakarta Selatan'),
];

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
    return ScheduleDraft(selectedDate: DateTime.now());
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
    state = ScheduleDraft(selectedDate: DateTime.now());
  }
}
