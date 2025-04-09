class Handoff {
  final String productId;
  final String senderId;
  final String receiverId;
  final String location;
  final String notes;

  Handoff({
    required this.productId,
    required this.senderId,
    required this.receiverId,
    required this.location,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'senderId': senderId,
      'receiverId': receiverId,
      'location': location,
      'notes': notes,
    };
  }

  factory Handoff.fromJson(Map<String, dynamic> json) {
    return Handoff(
      productId: json['productId'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      location: json['location'],
      notes: json['notes'] ?? '',
    );
  }
}