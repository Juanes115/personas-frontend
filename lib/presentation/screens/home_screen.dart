import 'package:flutter/material.dart';
import 'persona_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9F3EC),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.people_alt_rounded,
                  size: 42,
                  color: Color(0xFF0F766E),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Personas',
                style: TextStyle(
                  fontSize: 44,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF12312F),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Gestiona tus contactos de forma simple, rápida y ordenada.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF55706C),
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PersonaListScreen()),
                  );
                },
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('Explorar personas'),
              ),
              const Spacer(),
              const Text(
                'GESTIÓN DE DATOS · CRUD',
                style: TextStyle(
                  letterSpacing: 1.5,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF78938E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}