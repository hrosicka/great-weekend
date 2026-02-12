import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/idea_model.dart';

class IdeaService {
  static const String _storageKey = 'custom_ideas';
  late SharedPreferences _prefs;

  // Výchozí nápady s přiřazenými kategoriemi
  static final List<Idea> defaultIdeas = [
    Idea(text: "Společná procházka v parku při západu slunce 🌅", category: IdeaCategory.venku),
    Idea(text: "Domácí pizza night (každý dělá svou polovinu) 🍕", category: IdeaCategory.jidlo),
    Idea(text: "Filmový maraton tvojí oblíbené série 🍿", category: IdeaCategory.doma),
    Idea(text: "Návštěva deskoherní kavárny 🎲", category: IdeaCategory.venku),
    Idea(text: "Výlet na nejbližší hrad nebo zříceninu 🏰", category: IdeaCategory.venku),
    Idea(text: "Společné vaření nového receptu 🍳", category: IdeaCategory.jidlo),
    Idea(text: "Večer bez telefonů jen s vínem a hudbou 🍷", category: IdeaCategory.doma),
    Idea(text: "Piknik na kapotě auta s výhledem do krajiny 🚗", category: IdeaCategory.venku),
    Idea(text: "Stavba bunkru v obýváku z polštářů a dek ⛺", category: IdeaCategory.doma),
    Idea(text: "Degustace řemeslných piv nebo čokolády doma 🍻", category: IdeaCategory.jidlo),
    Idea(text: "Návštěva útulku a společné venčení psů 🐕", category: IdeaCategory.venku),
    Idea(text: "Geocaching - hledání pokladů ve vašem okolí 📍", category: IdeaCategory.venku),
    Idea(text: "Noc v autě nebo pod širákem na zahradě 🌌", category: IdeaCategory.venku),
    Idea(text: "Kurz tance podle YouTube tutoriálu v obýváku 💃", category: IdeaCategory.doma),
    Idea(text: "Vytvoření společného 'wishlistu' zážitků na příští rok 📝", category: IdeaCategory.doma),
  ];

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<Idea>> getAllIdeas() async {
    List<Idea> allIdeas = List.from(defaultIdeas);
    List<Idea> customIdeas = await getCustomIdeas();
    allIdeas.addAll(customIdeas);
    return allIdeas;
  }

  Future<List<Idea>> getCustomIdeas() async {
    final jsonString = _prefs.getString(_storageKey);
    if (jsonString == null) return [];

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

  // UPRAVENÁ METODA: Přijímá text i kategorii
  Future<void> addIdea(String ideaText, {required IdeaCategory category}) async {
    if (ideaText.trim().isEmpty) return;

    List<Idea> customIdeas = await getCustomIdeas();
    
    if (customIdeas.any((idea) => idea.text.toLowerCase() == ideaText.toLowerCase())) {
      throw Exception('Tento nápad už existuje!');
    }

    // Vytvoříme nový objekt Idea s kategorií
    customIdeas.add(Idea(
      text: ideaText, 
      isCustom: true, 
      category: category,
    ));
    
    final jsonString = jsonEncode(
      customIdeas.map((idea) => idea.toJson()).toList(),
    );
    
    await _prefs.setString(_storageKey, jsonString);
  }

  Future<void> deleteIdea(String ideaText) async {
    List<Idea> customIdeas = await getCustomIdeas();
    customIdeas.removeWhere((idea) => idea.text == ideaText);
    
    final jsonString = jsonEncode(
      customIdeas.map((idea) => idea.toJson()).toList(),
    );
    
    await _prefs.setString(_storageKey, jsonString);
  }

  Future<void> clearCustomIdeas() async {
    await _prefs.remove(_storageKey);
  }
}