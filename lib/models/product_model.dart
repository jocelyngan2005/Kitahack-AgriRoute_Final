class Product {
  final String productId;
  final String name;
  final String producerName;
  final String location;
  final DateTime harvestDate;

  Product({
    required this.productId,
    required this.name,
    required this.producerName,
    required this.location,
    required this.harvestDate,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'],
      name: json['name'],
      producerName: json['producerName'],
      location: json['location'],
      harvestDate: DateTime.parse(json['harvestDate']),
    );
  }
}