import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/idea_model.dart';

class IdeaService {
  static const String _storageKey = 'custom_ideas';
  late SharedPreferences _prefs;

  // Výchozí nápady s přiřazenými kategoriemi
  static final List<Idea> defaultIdeas = [
    // --- DOMA ---
    Idea(text: "Filmový maraton tvojí oblíbené série 🍿", category: IdeaCategory.doma),
    Idea(text: "Večer bez telefonů jen s vínem a hudbou 🍷", category: IdeaCategory.doma),
    Idea(text: "Stavba bunkru v obýváku z polštářů a dek ⛺", category: IdeaCategory.doma),
    Idea(text: "Kurz tance podle YouTube tutoriálu v obýváku 💃", category: IdeaCategory.doma),
    Idea(text: "Vytvoření společného 'wishlistu' zážitků na příští rok 📝", category: IdeaCategory.doma),
    Idea(text: "Společné skládání puzzle u dobrého čaje 🧩", category: IdeaCategory.doma),
    Idea(text: "Kreativní večer: Namalujte každý jeden obraz toho druhého 🎨", category: IdeaCategory.doma),
    Idea(text: "Domácí wellness: Pleťové masky, vana a relax 🛁", category: IdeaCategory.doma),
    Idea(text: "Plánování trasy na roadtrip nad papírovou mapou 🗺️", category: IdeaCategory.doma),

    // --- VENKU ---
    Idea(text: "Společná procházka v parku při západu slunce 🌅", category: IdeaCategory.venku),
    Idea(text: "Návštěva deskoherní kavárny 🎲", category: IdeaCategory.venku),
    Idea(text: "Výlet na nejbližší hrad nebo zříceninu 🏰", category: IdeaCategory.venku),
    Idea(text: "Piknik na kapotě auta s výhledem do krajiny 🚗", category: IdeaCategory.venku),
    Idea(text: "Návštěva útulku a společné venčení psů 🐕", category: IdeaCategory.venku),
    Idea(text: "Geocaching - hledání pokladů ve vašem okolí 📍", category: IdeaCategory.venku),
    Idea(text: "Noc v autě nebo pod širákem na zahradě 🌌", category: IdeaCategory.venku),
    Idea(text: "Foto-procházka: Foťte detaily města jen černobíle 📸", category: IdeaCategory.venku),
    Idea(text: "Půjčení lodičky nebo šlapadla na řece 🚣", category: IdeaCategory.venku),
    Idea(text: "Pozorování letadel u letiště s kávou v ruce ✈️", category: IdeaCategory.venku),
    

    // --- JÍDLO ---
    Idea(text: "Domácí pizza night (každý dělá svou polovinu) 🍕", category: IdeaCategory.jidlo),
    Idea(text: "Společné vaření nového receptu, který neznáte 🍳", category: IdeaCategory.jidlo),
    Idea(text: "Degustace řemeslných piv nebo čokolády doma 🍻", category: IdeaCategory.jidlo),
    Idea(text: "Slepo-chuťový test: Poznáte různé druhy pochutin? 🍫", category: IdeaCategory.jidlo),
    Idea(text: "Výprava do jiného města na tu nejlepší zmrzlinu 🍦", category: IdeaCategory.jidlo),
    Idea(text: "Společná příprava sushi rolí od základu 🍣", category: IdeaCategory.jidlo),
    Idea(text: "Snídaně v trávě (nebo v posteli) s lívancem 🥞", category: IdeaCategory.jidlo),
    Idea(text: "Příprava vlastních míchaných drinků (vytvořte si svůj!) 🍹", category: IdeaCategory.jidlo),
    Idea(text: "Návštěva farmářského trhu a nákup neznámých surovin 🥦", category: IdeaCategory.jidlo),
  
  // --- AKTIVNÍ ---
    Idea(text: "Souboj v bowlingu o to, kdo vybere příští večeři 🎳", category: IdeaCategory.aktivni),
    Idea(text: "Půjčení elektrokoloběžek a rychlá jízda městem 🛴", category: IdeaCategory.aktivni),
    Idea(text: "Návštěva lezecké stěny nebo boulderingu 🧗", category: IdeaCategory.aktivni),
    Idea(text: "Turnaj v minigolfu o největší zmrzlinu ⛳", category: IdeaCategory.aktivni),
    Idea(text: "Společný ranní běh nebo jóga v parku 🧘", category: IdeaCategory.aktivni),
    Idea(text: "Zápas v badmintonu nebo ping-pongu 🎾", category: IdeaCategory.aktivni),
    Idea(text: "Výšlap na nejvyšší kopec v okolí 🏔️", category: IdeaCategory.aktivni),
    Idea(text: "Návštěva trampolínového centra pro dospělé 🤸", category: IdeaCategory.aktivni),

    // --- ROMANTIKA ---
    Idea(text: "Večer při svíčkách s vaší oblíbenou hudbou 🕯️", category: IdeaCategory.romantika),
    Idea(text: "Psaní dopisů pro vaše budoucí já (otevřete za rok) ✉️", category: IdeaCategory.romantika),
    Idea(text: "Sledování hvězd z kapoty auta mimo město 🌌", category: IdeaCategory.romantika),
    Idea(text: "Návštěva místa, kde jste měli úplně první rande 💖", category: IdeaCategory.romantika),
    Idea(text: "Společná horká vana s pěnou a drinkem 🛁", category: IdeaCategory.romantika),
    Idea(text: "Vytvoření playlistu písniček, které vám sebe připomínají 🎵", category: IdeaCategory.romantika),
    Idea(text: "Piknik při svíčkách uprostřed obýváku 🍷", category: IdeaCategory.romantika),

    // --- KULTURA ---
    Idea(text: "Návštěva kina na film, o kterém nic nevíte 🎟️", category: IdeaCategory.kultura),
    Idea(text: "Prohlídka místního muzea nebo galerie 🖼️", category: IdeaCategory.kultura),
    Idea(text: "Večer v divadle nebo na stand-up komedii 🎭", category: IdeaCategory.kultura),
    Idea(text: "Návštěva antikvariátu a výběr knihy pro toho druhého 📚", category: IdeaCategory.kultura),
    Idea(text: "Procházka po historickém centru s výkladem z Wikipedie 🏛️", category: IdeaCategory.kultura),
    Idea(text: "Koncert místní kapely v malém klubu 🎸", category: IdeaCategory.kultura),

    // --- RYCHLOVKY (do 30 min) ---
    Idea(text: "Rychlá masáž zad nebo nohou (15 minut každý) 💆", category: IdeaCategory.rychlovky),
    Idea(text: "Společné vytřídění 10 starých věcí, co už nepoužíváte ♻️", category: IdeaCategory.rychlovky),
    Idea(text: "Souboj v jedné rychlé mobilní hře nebo kartách 🃏", category: IdeaCategory.rychlovky),
    Idea(text: "Prohlížení fotek v mobilu z minulého měsíce 📱", category: IdeaCategory.rychlovky),
    Idea(text: "Společné desetiminutové protažení nebo meditace 🧘", category: IdeaCategory.rychlovky),
    Idea(text: "Rychlá procházka kolem bloku pro čerstvý vzduch 👣", category: IdeaCategory.rychlovky),
    Idea(text: "Plánování jedné konkrétní věci na příští dovolenou ✈️", category: IdeaCategory.rychlovky),
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