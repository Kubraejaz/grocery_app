// lib/models/category.dart

class Category {
  final String id;
  final String name;
  final String colorHex;

  const Category({
    required this.id,
    required this.name,
    required this.colorHex,
  });

  factory Category.fromJson(Map<String, dynamic> j) => Category(
        id:       j['id']        as String,
        name:     j['name']      as String,
        colorHex: j['color_hex'] as String? ?? '#2E7D32',
      );

  Map<String, dynamic> toJson() => {
        'id':        id,
        'name':      name,
        'color_hex': colorHex,
      };
}