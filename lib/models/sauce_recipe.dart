class SauceRecipe {
  final String id;
  final String name;
  final String tag;
  final String description;
  final List<String> ingredients;
  final bool isCustom;

  const SauceRecipe({
    required this.id,
    required this.name,
    required this.tag,
    required this.description,
    required this.ingredients,
    this.isCustom = false,
  });

  factory SauceRecipe.fromJson(Map<String, dynamic> json) {
    return SauceRecipe(
      id: json['id'] as String,
      name: json['name'] as String,
      tag: json['tag'] as String? ?? '自定义',
      description: json['description'] as String? ?? '',
      ingredients: (json['ingredients'] as List<dynamic>? ?? const [])
          .map((ing) => ing.toString())
          .toList(),
      isCustom: json['isCustom'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tag': tag,
      'description': description,
      'ingredients': ingredients,
      'isCustom': isCustom,
    };
  }
}
