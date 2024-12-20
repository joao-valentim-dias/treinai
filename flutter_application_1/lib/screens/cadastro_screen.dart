import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _selectedMeta;
  int? _selectedFrequencia;
  Map<String, bool> _diasDescanso = {
    "Segunda-feira": false,
    "Terça-feira": false,
    "Quarta-feira": false,
    "Quinta-feira": false,
    "Sexta-feira": false,
    "Sábado": false,
    "Domingo": false,
  };
  bool _isProcessing = false; // Controla o estado de processamento

  Future<void> _cadastrar() async {
    setState(() {
      _isProcessing = true; // Exibe a mensagem de processamento
    });

    try {
      final descansoSelecionado = _diasDescanso.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/core/cadastro/'), // URL da view cadastro no Django
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'usuario': _usernameController.text,
          'senha': _passwordController.text,
          'idade': int.parse(_ageController.text),
          'peso': double.parse(_weightController.text),
          'metas': _selectedMeta,
          'frequencia': _selectedFrequencia.toString(),
          'descanso': descansoSelecionado,
        }),
      );

      setState(() {
        _isProcessing = false; // Finaliza o estado de processamento
      });

      if (response.statusCode == 201) {
        // Cadastro realizado com sucesso
        final responseBody = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseBody['message'])),
        );

        // Volta para a tela inicial
        Navigator.pop(context);
      } else {
        // Exibe erro do backend
        final responseBody = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseBody['message'])),
        );
      }
    } catch (e) {
      // Exibe erro geral
      setState(() {
        _isProcessing = false; // Finaliza o estado de processamento
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao se cadastrar: $e')),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Idade'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Peso (kg)'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedMeta,
                decoration: const InputDecoration(labelText: 'Meta'),
                items: const [
                  DropdownMenuItem(value: "ganhar massa muscular", child: Text("Ganhar Massa Muscular")),
                  DropdownMenuItem(value: "perder gordura", child: Text("Perder Gordura")),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedMeta = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: _selectedFrequencia,
                decoration: const InputDecoration(labelText: 'Frequência (vezes por semana)'),
                items: List.generate(
                  5,
                  (index) => DropdownMenuItem(
                    value: index + 3,
                    child: Text("${index + 3} vezes"),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedFrequencia = value;
                    // Resetar os dias de descanso quando a frequência mudar
                    _diasDescanso.updateAll((key, value) => false);
                  });
                },
              ),
              const SizedBox(height: 10),
              const Text(
                "Dias de Descanso",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Column(
                children: _diasDescanso.keys.map((dia) {
                  final diasPermitidos = 7 - (_selectedFrequencia ?? 0);
                  final diasMarcados = _diasDescanso.values.where((v) => v).length;

                  return CheckboxListTile(
                    title: Text(dia),
                    value: _diasDescanso[dia],
                    onChanged: diasMarcados < diasPermitidos || _diasDescanso[dia] == true
                        ? (bool? value) {
                            setState(() {
                              _diasDescanso[dia] = value ?? false;
                            });
                          }
                        : null, // Desativa se o limite for atingido
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Exibe o texto roxo enquanto o cadastro está sendo processado
              if (_isProcessing)
                const Center(
                  child: Text(
                    'Cadastro em processo...',
                    style: TextStyle(fontSize: 18, color: Colors.purple),
                  ),
                ),

              // Botão de cadastro
              Center(
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _cadastrar, // Desabilita o botão durante o processamento
                  child: const Text('Cadastrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
