import 'dart:convert';

Product productFromJson(String str) => Product.fromJson(json.decode(str));

String productToJson(Product data) => json.encode(data.toJson());

class Product {
    final String id;
    final String name;
    final String description;
    final String imageUrl;
    final double price;
    final int stock;

    Product({
        required this.id,
        required this.name,
        required this.description,
        required this.imageUrl,
        required this.price,
        required this.stock,
    });

    factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["_id"], // ใน MongoDB primary key คือ _id
        name: json["name"],
        description: json["description"],
        imageUrl: json["imageUrl"],
        price: json["price"].toDouble(),
        stock: json["stock"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "description": description,
        "imageUrl": imageUrl,
        "price": price,
        "stock": stock,
    };
}