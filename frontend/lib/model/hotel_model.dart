class HotelModel {
  final String hotelId;
  final String name;
  final String address;
  final double rating;
  final String description;
  final String mainImage;

  HotelModel({
    required this.hotelId,
    required this.name,
    required this.address,
    required this.rating,
    required this.description,
    required this.mainImage,
  });

  Map<String, dynamic> toJson() => {
    "hotelId": hotelId,
    "name": name,
    "address": address,
    "rating": rating,
    "description": description,
    "mainImage": mainImage,
  };

  factory HotelModel.fromJson(Map<String, dynamic> json) => HotelModel(
    hotelId: json["hotelId"],
    name: json["name"],
    address: json["address"],
    rating: json["rating"].toDouble(),
    description: json["description"],
    mainImage: json["mainImage"],
  );
}