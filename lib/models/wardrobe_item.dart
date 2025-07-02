class WardrobeItem {
  final int id;
  final String imagePath;
  final String name;
  final String type;
  final String color;

  WardrobeItem({
    required this.id,
    required this.imagePath,
    required this.name,
    required this.type,
    required this.color,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'imagePath': imagePath,
        'name': name,
        'type': type,
        'color': color,
      };
}