class Workshop {
  final String id;
  final String name;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final String mapsUrl;
  final String phoneNumber;
  final String openingHours;
  final double distanceKm;

  const Workshop(
    this.id,
    this.name,
    this.address,
    this.city, {
    this.latitude = -6.2,
    this.longitude = 106.8,
    this.mapsUrl = 'https://maps.google.com',
    this.phoneNumber = '0812-3456-7890',
    this.openingHours = '08:00 - 17:00',
    this.distanceKm = 5.0,
  });
}
