import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _username = ''; // Variável para armazenar o nome do usuário
  String _fichaMensagem = ''; // Para exibir a mensagem da ficha de treino
  String _exercicios = ''; // Para armazenar os exercícios da ficha de treino

  @override
  void initState() {
    super.initState();
    _loadUsername();  // Carrega o nome de usuário quando a tela for carregada
  }

  // Método para carregar o nome de usuário armazenado
  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '';  // Recupera o nome de usuário
    });
    if (_username.isNotEmpty) {
      _fetchFichaDeTreino();  // Faz a requisição da ficha de treino
    }
  }

  // Método para buscar a ficha de treino do usuário
  Future<void> _fetchFichaDeTreino() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/core/fichas/$_username'), // URL para obter a ficha de treino
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        setState(() {
          _fichaMensagem = responseBody['message'];
          _exercicios = responseBody['ficha']['exercicios']; // Pega os exercícios como texto
        });
      } else {
        final responseBody = json.decode(response.body);
        setState(() {
          _fichaMensagem = responseBody['message'];
          _exercicios = ''; // Caso não tenha ficha de treino
        });
      }
    } catch (e) {
      setState(() {
        _fichaMensagem = 'Erro ao conectar com o servidor: $e';
        _exercicios = ''; // Em caso de erro, não exibe a ficha de treino
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TreinAI (CIn - UFPE)'), // Título adicionado aqui
      ),
      body: SingleChildScrollView(  // Envolvendo todo o conteúdo com SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exibe a saudação com o nome do usuário
              Text(
                'Olá, $_username!',
                style: const TextStyle(fontSize: 30),
              ),
              const SizedBox(height: 20),
              
              // Exibe a mensagem da ficha de treino
              Text(
                _fichaMensagem,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Exibe os exercícios como texto corrido
              if (_exercicios.isNotEmpty) ...[
                Text(
                  _exercicios,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
              
              // Se não houver ficha de treino ou houver erro
              if (_exercicios.isEmpty && _fichaMensagem.isNotEmpty)
                const SizedBox(height: 20),

              // Botão para voltar para a tela de login
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);  // Volta para a tela de login
                },
                child: const Text('Voltar para Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
