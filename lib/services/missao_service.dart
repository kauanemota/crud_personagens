
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MissaoService {
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  String get _uid =>
      FirebaseAuth.instance.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _colecao =>
      firestore
          .collection('usuarios')
          .doc(_uid)
          .collection('missoes');

  // Registrar uma missão concluída
  Future<void> registrarMissao(String titulo) async {
    final nome = titulo.trim();

    if (nome.isEmpty) {
      throw ArgumentError('Informe o título da missão.');
    }

    await _colecao.add({
      'titulo': nome,
      'concluidaEm': FieldValue.serverTimestamp(),
    });
  }

  // Listar missões do usuário autenticado
  Stream<QuerySnapshot<Map<String, dynamic>>> listarMissoes() {
    return _colecao.snapshots();
  }
}
