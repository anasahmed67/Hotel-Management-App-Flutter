class RoomModel {
  final String id;
  final String roomNumber;
  final String type;
  final double pricePerNight;
  final List<String> amenities;
  final String? image;

  bool isAvailable;
  int totalRooms;

  RoomModel({
    required this.id,
    required this.roomNumber,
    required this.type,
    required this.pricePerNight,
    required this.amenities,
    this.image,
    this.isAvailable = true,
    required this.totalRooms,
  });
}