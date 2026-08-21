import 'package:flutter/material.dart';
import 'persona_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('APP Gestión Personas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Icon(Icons.person, size: 80),
            const SizedBox(height: 24),
            const Text('APP Gestión Personas'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PersonaListScreen()),
                );
              },
              child: const Text('Ver Personas'),
            ),
          ],
        ),
      ),
    );
  }
}