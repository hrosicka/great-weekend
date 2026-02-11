class Idea {
  final String text;
  final bool isCustom; // true = uživatel přidal, false = výchozí

  Idea({
    required this.text,
    this.isCustom = false,
  });

  // Serializace do JSON
  Map<String, dynamic> toJson() => {
    'text': text,
    'isCustom': isCustom,
  };

  // Deserializace z JSON
  factory Idea.fromJson(Map<String, dynamic> json) => Idea(
    text: json['text'],
    isCustom: json['isCustom'] ?? false,
  );
}