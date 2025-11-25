class CategoryData {
  final String category;
  final List<String> items;

  CategoryData({
    required this.category,
    required this.items,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      category: json['category'] as String? ?? '',
      items: List<String>.from(
        (json['items'] as List<dynamic>?)?.map((item) => item.toString()) ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'items': items,
    };
  }
}

