
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/missao_service.dart';

class MissoesScreen extends StatefulWidget {
  const MissoesScreen({super.key});

  @override
  State<MissoesScreen> createState() => _MissoesScreenState();
}

class _MissoesScreenState extends State<MissoesScreen> {
  final MissaoService _service = MissaoService();
  final TextEditingController _tituloController =
      TextEditingController();

  bool _salvando = false;

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  // Registrar uma nova missão concluída
  Future<void> _registrarMissao() async {
    final titulo = _tituloController.text.trim();

    if (titulo.isEmpty || _salvando) return;

    setState(() => _salvando = true);

    try {
      await _service.registrarMissao(titulo);

      if (!mounted) return;

      _tituloController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missão concluída com sucesso!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  String _formatarData(dynamic valor) {
    if (valor is! Timestamp) {
      return 'Registrando data...';
    }

    final data = valor.toDate().toLocal();
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');

    return '$dia/$mes/${data.year} às $hora:$minuto';
  }

  @override
  Widget build(BuildContext context) {
    const ouro = Color(0xFFD4A94A);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MISSÕES CONCLUÍDAS'),
        backgroundColor: const Color(0xFF241B13),
        foregroundColor: ouro,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: ouro,
                  size: 55,
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título da missão',
                    hintText: 'Ex: Derrotar o dragão',
                    prefixIcon: Icon(Icons.flag),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        _salvando ? null : _registrarMissao,
                    icon: const Icon(Icons.check_circle),
                    label: Text(
                      _salvando
                          ? 'SALVANDO...'
                          : 'CONCLUIR MISSÃO',
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'HISTÓRICO DE MISSÕES',
                  style: TextStyle(
                    color: ouro,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: StreamBuilder<
                      QuerySnapshot<Map<String, dynamic>>>(
                    stream: _service.listarMissoes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Erro: ${snapshot.error}',
                          ),
                        );
                      }

                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final missoes =
                          snapshot.data?.docs ?? [];

                      if (missoes.isEmpty) {
                        return const Center(
                          child: Text(
                            'Nenhuma missão concluída ainda.',
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: missoes.length,
                        itemBuilder: (context, index) {
                          final dados = missoes[index].data();

                          return Card(
                            color: const Color(0xFF241B13),
                            child: ListTile(
                              leading: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              title: Text(
                                dados['titulo'] ?? '',
                              ),
                              subtitle: Text(
                                _formatarData(
                                  dados['concluidaEm'],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
