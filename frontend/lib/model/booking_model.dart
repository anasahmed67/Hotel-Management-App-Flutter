class BookingModel {
  final String bookingId;
  final String userName;
  final String phone;
  final String nic;
  final String roomId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int roomCount;
  final int persons;
  final double totalAmount;
  final String status;
  final String? assignedRoom;

  BookingModel({
    required this.bookingId,
    required this.userName,
    required this.phone,
    required this.nic,
    required this.roomId,
    required this.checkIn,
    required this.checkOut,
    required this.roomCount,
    required this.persons,
    required this.totalAmount,
    required this.status,
    this.assignedRoom,
  });

  BookingModel copyWith({
    String? bookingId,
    String? status,
    String? assignedRoom,
  }) {
    return BookingModel(
      bookingId: bookingId ?? this.bookingId,
      userName: userName,
      phone: phone,
      nic: nic,
      roomId: roomId,
      checkIn: checkIn,
      checkOut: checkOut,
      roomCount: roomCount,
      persons: persons,
      totalAmount: totalAmount,
      status: status ?? this.status,
      assignedRoom: assignedRoom ?? this.assignedRoom,
    );
  }
}
