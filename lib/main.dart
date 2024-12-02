import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokéAPI Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const PokemonPage(),
    );
  }
}

class PokemonPage extends StatefulWidget {
  const PokemonPage({super.key});

  @override
  _PokemonPageState createState() => _PokemonPageState();
}

class _PokemonPageState extends State<PokemonPage> {
  Map<String, dynamic>? pokemonData;
  bool isLoading = false;
  String? errorMessage;

  // Fetch Pokémon data from the API
  Future<void> fetchPokemon(String name) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$name'));
      if (response.statusCode == 200) {
        setState(() {
          pokemonData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Pokémon not found!';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred. Please try again.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokémon Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search for a Pokémon',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Pokémon Name',
              ),
              onSubmitted: (value) {
                fetchPokemon(value.toLowerCase());
              },
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (errorMessage != null)
              Center(
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 18),
                ),
              ),
            if (pokemonData != null && !isLoading)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pokemonData!['name'].toString().toUpperCase(),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Image.network(
                        pokemonData!['sprites']['front_default'],
                        height: 200,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Height: ${pokemonData!['height']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Weight: ${pokemonData!['weight']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Abilities:',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      for (var ability in pokemonData!['abilities'])
                        Text(
                          '- ${ability['ability']['name']}',
                          style: const TextStyle(fontSize: 18),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    
  }
}