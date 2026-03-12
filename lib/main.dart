import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'models/idea_model.dart';
import 'services/idea_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ideaService = IdeaService();
  await ideaService.init();
  runApp(IdeaGeneratorApp(ideaService: ideaService));
}

class IdeaGeneratorApp extends StatelessWidget {
  final IdeaService ideaService;

  const IdeaGeneratorApp({super.key, required this.ideaService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.pink[50],
        textTheme: GoogleFonts.openSansTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.pink,
          centerTitle: true,
          titleTextStyle: GoogleFonts.openSans(
            color: Colors.pink,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
          iconTheme: const IconThemeData(color: Colors.pink),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink[400],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            elevation: 2,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 11,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          color: Colors.white,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          titleTextStyle: GoogleFonts.openSans(
            color: Colors.pink[800],
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
          contentTextStyle: GoogleFonts.openSans(
            color: Colors.brown[800],
            fontSize: 16,
          ),
        ),
      ),
      home: IdeaScreen(ideaService: ideaService),
    );
  }
}

class IdeaScreen extends StatefulWidget {
  final IdeaService ideaService;

  const IdeaScreen({super.key, required this.ideaService});

  @override
  _IdeaScreenState createState() => _IdeaScreenState();
}

class _IdeaScreenState extends State<IdeaScreen> {
  late List<Idea> allIdeas = [];
  String currentIdea = "Klikni na tlačítko a naplánuj nám program! ❤️";
  bool isLoading = true;

  // Nová proměnná pro filtr (vse = zobrazení všeho)
  IdeaCategory selectedFilter = IdeaCategory.vse;

  @override
  void initState() {
    super.initState();
    _loadIdeas();
  }

  Future<void> _loadIdeas() async {
    final ideas = await widget.ideaService.getAllIdeas();
    setState(() {
      allIdeas = ideas;
      isLoading = false;
    });
  }

  void generateIdea() {
    // 1. Vytvoříme filtrovaný seznam
    final filteredIdeas = selectedFilter == IdeaCategory.vse
        ? allIdeas
        : allIdeas.where((idea) => idea.category == selectedFilter).toList();

    if (filteredIdeas.isEmpty) {
      setState(() {
        currentIdea = "V této kategorii zatím nic není! 😊";
      });
      return;
    }

    // 2. Náhodný výběr z filtrovaného seznamu
    setState(() {
      currentIdea = filteredIdeas[Random().nextInt(filteredIdeas.length)].text;
    });
  }

  void _showAddIdeaDialog() {
    final TextEditingController controller = TextEditingController();
    // Výchozí vybraná kategorie
    IdeaCategory selectedCategory = IdeaCategory.doma;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder( // Umožňuje měnit stav uvnitř dialogu
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Row(
              children: [
                Icon(Icons.add_box_rounded, color: Colors.pink[300]),
                const SizedBox(width: 8),
                Text("Přidej nový nápad", 
                  style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min, // Dialog se přizpůsobí obsahu
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: "Napiš nápad na aktivitu...",
                    filled: true,
                    fillColor: Colors.pink[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  maxLines: 2,
                  autofocus: true,
                ),
                const SizedBox(height: 20),
                // Výběr kategorie
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.pink[100]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<IdeaCategory>(
                      value: selectedCategory,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.pink),
                      items: IdeaCategory.values.where((c) => c != IdeaCategory.vse).map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Row(
                            children: [
                              Icon(_getCategoryIcon(cat), size: 20, color: Colors.pink[300]),
                              const SizedBox(width: 10),
                              Text(cat.name.toUpperCase()),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        // Tady používáme setDialogState místo setState!
                        setDialogState(() {
                          selectedCategory = newValue!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Zrušit"),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text("Přidat"),
                onPressed: () async {
                  final text = controller.text.trim();
                  if (text.isNotEmpty) {
                    try {
                      // POZOR: Tady musí tvůj IdeaService přijímat i kategorii!
                      await widget.ideaService.addIdea(text, category: selectedCategory);
                      await _loadIdeas();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Nápad přidán! 🎉")),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Chyba: $e")),
                      );
                    }
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCustomIdeasDialog() {
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<List<Idea>>(
        future: widget.ideaService.getCustomIdeas(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const AlertDialog(
              content: SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          final customIdeas = snapshot.data!;

          if (customIdeas.isEmpty) {
            return AlertDialog(
              title: const Text("Moje nápady"),
              content: const Text("Zatím jsi nepřidal žádné vlastní nápady."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            );
          }

          return AlertDialog(
            title: const Text("Moje nápady"),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: customIdeas.length,
                itemBuilder: (context, index) {
                  final idea = customIdeas[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      // Přidáme ikonku kategorie před text
                      leading: CircleAvatar(
                        backgroundColor: Colors.pink[50],
                        child: Icon(
                          _getCategoryIcon(idea.category),
                          color: Colors.pink[300],
                          size: 20,
                        ),
                      ),
                      title: Text(
                        idea.text,
                        style: GoogleFonts.openSans(fontWeight: FontWeight.w500),
                      ),
                      // Přidáme podnadpis s názvem kategorie
                      subtitle: Text(
                        idea.category.name.toUpperCase(),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () async {
                          await widget.ideaService.deleteIdea(idea.text);
                          await _loadIdeas();
                          Navigator.pop(context);
                          _showCustomIdeasDialog();
                        },
                        tooltip: "Smazat nápad",
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Zavřít"),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(IdeaCategory category) {
  switch (category) {
    case IdeaCategory.doma:
      return Icons.home_rounded;
    case IdeaCategory.venku:
      return Icons.forest_rounded;
    case IdeaCategory.jidlo:
      return Icons.restaurant_rounded;
    case IdeaCategory.aktivni:
      return Icons.fitness_center_rounded;
    case IdeaCategory.romantika:
      return Icons.favorite_rounded;
    case IdeaCategory.kultura:
      return Icons.theater_comedy_rounded;
    case IdeaCategory.rychlovky:
      return Icons.timer_rounded;
    case IdeaCategory.vse:
      return Icons.auto_awesome_motion_rounded;
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: const Text("Dáme akci?"),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _showCustomIdeasDialog,
          ),
        ],
      ),
      // Používáme LayoutBuilder, abychom věděli, kolik máme místa
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView( // Umožňuje skrolování na malých mobilech
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight, // Karta se bude snažit být na střed
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          
                          // Horizontální filtr (Wrap je super, že neuteče z obrazovky)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              alignment: WrapAlignment.center,
                              children: IdeaCategory.values.map((category) {
                                return ChoiceChip(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  label: Text(category.name.toUpperCase()),
                                  selected: selectedFilter == category,
                                  selectedColor: Colors.pink[300],
                                  backgroundColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: selectedFilter == category ? Colors.white : Colors.pink,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12, // Trochu menší písmo pro jistotu
                                  ),
                                  onSelected: (bool selected) {
                                    setState(() {
                                      selectedFilter = category;
                                      if (category == IdeaCategory.vse) {
                                        currentIdea = "Klikni a naplánuj nám program! ❤️";
                                      } else {
                                        currentIdea = "Zkusíme najít něco pro kategorii ${category.name.toUpperCase()}? ✨";
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          
                          // Hlavní část s kartou
                          // Nahrazen Expanded za Flexible/Padding kvůli ScrollView
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 40),
                            child: Center(
                              child: Card(
                                margin: const EdgeInsets.symmetric(horizontal: 24),
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0), // Mírně zmenšen padding
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getCategoryIcon(selectedFilter),
                                        color: Colors.pink[300], 
                                        size: 48, // Mírně zmenšeno
                                      ),
                                      const SizedBox(height: 20),
                                      AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 500),
                                        transitionBuilder: (Widget child, Animation<double> animation) =>
                                            FadeTransition(opacity: animation, child: child),
                                        child: Text(
                                          currentIdea,
                                          key: ValueKey<String>(currentIdea),
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.openSans(
                                            fontSize: 22, // Zmenšeno z 25 pro lepší čitelnost
                                            fontWeight: FontWeight.bold,
                                            color: Colors.brown[800],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                      ElevatedButton(
                                        onPressed: generateIdea,
                                        child: const Text("Co budeme dělat?"),
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton.icon(
                                        onPressed: _showAddIdeaDialog,
                                        icon: const Icon(Icons.add, size: 20),
                                        label: const Text("Přidat nápad"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.pink[300],
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}