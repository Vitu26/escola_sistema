import 'package:flutter/material.dart';

class HomePageProfissional extends StatefulWidget {
  const HomePageProfissional({super.key});

  @override
  State<HomePageProfissional> createState() => _HomePageProfissionalState();
}

class _HomePageProfissionalState extends State<HomePageProfissional> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Você é um funcionário'),);
  }
}