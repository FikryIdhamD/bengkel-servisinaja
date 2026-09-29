import 'package:flutter_riverpod/flutter_riverpod.dart';

class Workshop {
  final String id;
  final String name;
  final String address;
  final String city;

  const Workshop(this.id, this.name, this.address, this.city);
}

const defaultWorkshops = [
  Workshop(
    '11111111-1111-1111-1111-111111111111',
    'PitStop BSD Autoparts',
    'Jl. Letnan Sutopo No. 12',
    'Tangerang Selatan',
  ),
  Workshop(
    '22222222-2222-2222-2222-222222222222',
    'PitStop Cipete Raya',
    'Jl. Cipete Raya No. 45',
    'Jakarta Selatan',
  ),
  Workshop(
    '33333333-3333-3333-3333-333333333333',
    'PitStop Kelapa Gading',
    'Boulevard Raya Blok M No. 8',
    'Jakarta Utara',
  ),
  Workshop(
    '44444444-4444-4444-4444-444444444444',
    'PitStop Bekasi Barat',
    'Jl. Jenderal Sudirman No. 99',
    'Bekasi',
  ),
  Workshop(
    '55555555-5555-5555-5555-555555555555',
    'PitStop Depok Margonda',
    'Jl. Margonda Raya No. 123',
    'Depok',
  ),
  Workshop(
    '66666666-6666-6666-6666-666666666666',
    'PitStop Bintaro Sektor 7',
    'Bintaro Jaya Sektor 7',
    'Tangerang Selatan',
  ),
  Workshop(
    '77777777-7777-7777-7777-777777777777',
    'PitStop Kebon Jeruk',
    'Jl. Panjang No. 10',
    'Jakarta Barat',
  ),
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

