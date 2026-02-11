import 'package:flutter/material.dart';
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
      theme: ThemeData(primarySwatch: Colors.pink),
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
        title: const Text("Přidej nový nápad 💡"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Napiš nápad na aktivitu...",
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Zrušit"),
          ),
          ElevatedButton(
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
            child: const Text("Přidat"),
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
                itemCount: customIdeas.length,
                itemBuilder: (context, index) {
                  final idea = customIdeas[index];
                  return ListTile(
                    title: Text(idea.text),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await widget.ideaService.deleteIdea(idea.text);
                        await _loadIdeas();
                        Navigator.pop(context);
                        _showCustomIdeasDialog();
                      },
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
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite, color: Colors.pink, size: 50),
                    const SizedBox(height: 20),
                    Text(
                      currentIdea,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[800],
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: generateIdea,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Co budeme dělat?",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _showAddIdeaDialog,
                      icon: const Icon(Icons.add),
                      label: const Text("Přidat nápad"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[300],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}