import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(IdeaGeneratorApp());

class IdeaGeneratorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.pink),
      home: IdeaScreen(),
    );
  }
}

class IdeaScreen extends StatefulWidget {
  @override
  _IdeaScreenState createState() => _IdeaScreenState();
}

class _IdeaScreenState extends State<IdeaScreen> {
  // --- TADY SI DOPRAV VLASTNÍ NÁPADY ---
  final List<String> ideas = [
    "Společná procházka v parku při západu slunce 🌅",
    "Domácí pizza night (každý dělá svou polovinu) 🍕",
    "Filmový maraton tvojí oblíbené série 🍿",
    "Návštěva deskoherní kavárny 🎲",
    "Výlet na nejbližší hrad nebo zříceninu 🏰",
    "Společné vaření nového receptu 🍳",
    "Večer bez telefonů jen s vínem a hudbou 🍷",
  ];

  String currentIdea = "Klikni na tlačítko a naplánuj nám program! ❤️";

  void generateIdea() {
    setState(() {
      currentIdea = ideas[Random().nextInt(ideas.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(title: Text("Generátor našich nápadů")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite, color: Colors.pink, size: 50),
              SizedBox(height: 20),
              Text(
                currentIdea,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.brown[800]),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: generateIdea,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text("Co budeme dělat?", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}