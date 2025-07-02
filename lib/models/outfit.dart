class Outfit {
  final int id;
  final String name;
  final List<int> itemIds;

  Outfit({required this.id, required this.name, required this.itemIds});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'itemIds': itemIds.join(',')
      };
}
