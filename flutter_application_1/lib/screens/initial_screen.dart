import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'cadastro_screen.dart'; // Importação da tela de cadastro

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TreinaAI (CIn - UFPE)'), // Título adicionado aqui
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagem acima dos botões
            Image.asset(
              'assets/images/logo.png',  // Caminho da imagem no projeto
              height: 150,  // Ajuste a altura conforme necessário
            ),
            const SizedBox(height: 30), // Espaço entre a imagem e os botões
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 20), // Espaçamento entre os botões
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CadastroScreen()),
                );
              },
              child: const Text('Cadastro'),
            ),
          ],
        ),
      ),
    );
  }
}
