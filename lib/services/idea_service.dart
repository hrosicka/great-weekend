import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/idea_model.dart';

class IdeaService {
  static const String _storageKey = 'custom_ideas';
  late SharedPreferences _prefs;

  // Výchozí nápady
  static final List<Idea> defaultIdeas = [
    Idea(text: "Společná procházka v parku při západu slunce 🌅"),
    Idea(text: "Domácí pizza night (každý dělá svou polovinu) 🍕"),
    Idea(text: "Filmový maraton tvojí oblíbené série 🍿"),
    Idea(text: "Návštěva deskoherní kavárny 🎲"),
    Idea(text: "Výlet na nejbližší hrad nebo zříceninu 🏰"),
    Idea(text: "Společné vaření nového receptu 🍳"),
    Idea(text: "Večer bez telefonů jen s vínem a hudbou 🍷"),
    Idea(text: "Piknik na kapotě auta s výhledem do krajiny 🚗"),
    Idea(text: "Stavba bunkru v obýváku z polštářů a dek ⛺"),
    Idea(text: "Degustace řemeslných piv nebo čokolády doma 🍻"),
    Idea(text: "Návštěva útulku a společné venčení psů 🐕"),
    Idea(text: "Geocaching - hledání pokladů ve vašem okolí 📍"),
    Idea(text: "Noc v autě nebo pod širákem na zahradě 🌌"),
    Idea(text: "Kurz tance podle YouTube tutoriálu v obýváku 💃"),
    Idea(text: "Vytvoření společného 'wishlistu' zážitků na příští rok 📝"),
  ];

  // Inicializace
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Načtení všech nápadů (výchozí + vlastní)
  Future<List<Idea>> getAllIdeas() async {
    List<Idea> allIdeas = List.from(defaultIdeas);
    List<Idea> customIdeas = await getCustomIdeas();
    allIdeas.addAll(customIdeas);
    return allIdeas;
  }

  // Načtení pouze vlastních nápadů
  Future<List<Idea>> getCustomIdeas() async {
    final jsonString = _prefs.getString(_storageKey);
    
    if (jsonString == null) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => Idea.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Chyba při načítání nápadů: $e');
      return [];
    }
  }

  // Přidání nového nápadu
  Future<void> addIdea(String ideaText) async {
    if (ideaText.trim().isEmpty) return;

    List<Idea> customIdeas = await getCustomIdeas();
    
    // Kontrola duplikátů
    if (customIdeas.any((idea) => idea.text.toLowerCase() == ideaText.toLowerCase())) {
      throw Exception('Tento nápad už existuje!');
    }

    customIdeas.add(Idea(text: ideaText, isCustom: true));
    
    final jsonString = jsonEncode(
      customIdeas.map((idea) => idea.toJson()).toList(),
    );
    
    await _prefs.setString(_storageKey, jsonString);
  }

  // Smazání nápadu
  Future<void> deleteIdea(String ideaText) async {
    List<Idea> customIdeas = await getCustomIdeas();
    customIdeas.removeWhere((idea) => idea.text == ideaText);
    
    final jsonString = jsonEncode(
      customIdeas.map((idea) => idea.toJson()).toList(),
    );
    
    await _prefs.setString(_storageKey, jsonString);
  }

  // Smazání všech vlastních nápadů
  Future<void> clearCustomIdeas() async {
    await _prefs.remove(_storageKey);
  }
}