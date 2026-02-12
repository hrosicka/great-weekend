import 'package:flutter/material.dart';

/// Definice kategorií nápadů
enum IdeaCategory {
  vse,       // Pro zobrazení všeho
  doma, 
  venku, 
  jidlo 
}

class Idea {
  final String text;
  final bool isCustom; // true = uživatel přidal, false = výchozí
  final IdeaCategory category; // Nové pole pro kategorii

  Idea({
    required this.text,
    this.isCustom = false,
    this.category = IdeaCategory.vse, // Výchozí hodnota
  });

  // Serializace do JSON
  Map<String, dynamic> toJson() => {
    'text': text,
    'isCustom': isCustom,
    'category': category.name, // Ukládáme jako String (např. "doma")
  };

  // Deserializace z JSON
  factory Idea.fromJson(Map<String, dynamic> json) {
    return Idea(
      text: json['text'],
      isCustom: json['isCustom'] ?? false,
      // Převedeme String zpět na Enum, pokud neexistuje, dáme .vse
      category: IdeaCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => IdeaCategory.vse,
      ),
    );
  }
}