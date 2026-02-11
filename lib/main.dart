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

  const IdeaGeneratorApp({required this.ideaService});

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

  const IdeaScreen({required this.ideaService});

  @override
  _IdeaScreenState createState() => _IdeaScreenState();
}

class _IdeaScreenState extends State<IdeaScreen> {
  late List<Idea> allIdeas = [];
  String currentIdea = "Klikni na tlačítko a naplánuj nám program! ❤️";
  bool isLoading = true;

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
    if (allIdeas.isEmpty) {
      setState(() {
        currentIdea = "Zatím žádné nápady! Přidej si nějaké. 😊";
      });
      return;
    }

    setState(() {
      currentIdea = allIdeas[Random().nextInt(allIdeas.length)].text;
    });
  }

  void _showAddIdeaDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(Icons.add_box_rounded, color: Colors.pink[300]),
            const SizedBox(width: 8),
            Text("Přidej nový nápad", style: GoogleFonts.openSans(fontWeight: FontWeight.bold)),
          ],
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Napiš nápad na aktivitu...",
            filled: true,
            fillColor: Colors.pink[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Zrušit"),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text("Přidat"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink[400],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              try {
                if (controller.text.trim().isNotEmpty) {
                  await widget.ideaService.addIdea(controller.text.trim());
                  await _loadIdeas();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Nápad přidán! 🎉"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Chyba: $e")),
                );
              }
            },
          ),
        ],
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
              content: CircularProgressIndicator(),
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
                      title: Text(idea.text, style: GoogleFonts.openSans(fontWeight: FontWeight.w500)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: const Text("Generátor našich nápadů"),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _showCustomIdeasDialog,
            tooltip: "Moje nápady",
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Card(
                margin: const EdgeInsets.all(24),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite, color: Colors.pink[300], size: 54),
                      const SizedBox(height: 20),
                      Text(
                        currentIdea,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.openSans(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[800],
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: generateIdea,
                        child: const Text("Co budeme dělat?"),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showAddIdeaDialog,
                        icon: const Icon(Icons.add),
                        label: const Text("Přidat nápad"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink[300],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}