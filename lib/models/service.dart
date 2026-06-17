/// Modelo que representa um serviço de bicicleta
class Service {
  final int id;
  final String title;
  final String description;
  final double price;
  final String icon; // Nome do ícone: 'settings', 'build', 'speed', 'bike', etc.
  final DateTime createdAt;

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.icon,
    required this.createdAt,
  });

  /// Cria um Service a partir de um mapa (útil para simular API)
  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      icon: map['icon'] as String,
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'] as String)
          : map['createdAt'] as DateTime,
    );
  }

  /// Converte o Service para um mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
