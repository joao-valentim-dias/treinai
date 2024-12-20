import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/core/login/'), // URL para o backend Django
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'usuario': username,
          'senha': password,
        }),
      );

      if (response.statusCode == 200) {  // Status 200 de sucesso
        // Se o POST for bem-sucedido, armazena o nome de usuário
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('username', username);  // Armazenando o nome do usuário

        // Navega para a tela Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // Se houver erro, exibe a mensagem de erro do backend
        final responseBody = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseBody['message'])),
        );
      }
    } catch (e) {
      // Exibe erro caso ocorra algum problema de conexão
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao conectar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TreinAI (CIn - UFPE)'), // Título atualizado
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Usuário'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,  // Chama o método _login
              child: const Text('Entrar'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);  // Volta para a tela anterior
              },
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}
