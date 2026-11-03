enum ItemStatus {
  lost('perdido', 'Perdido'),
  found('encontrado', 'Encontrado');

  const ItemStatus(this.value, this.label);

  final String value;
  final String label;

  static ItemStatus fromValue(String value) =>
      ItemStatus.values.firstWhere((status) => status.value == value);
}

class LostItem {
  const LostItem({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final String location;
  final ItemStatus status;
  final DateTime createdAt;

  factory LostItem.fromJson(Map<String, dynamic> json) => LostItem(
    id: json['id'].toString(),
    name: json['name'] as String,
    description: json['description'] as String,
    location: json['location'] as String,
    status: ItemStatus.fromValue(json['status'] as String),
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'location': location,
    'status': status.value,
  };
}
