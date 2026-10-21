
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/personagem.dart';

class PersonagemService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // UID do usuário autenticado
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // Cada usuário tem sua própria subcoleção de personagens
  CollectionReference<Map<String, dynamic>> get _colecao =>
      firestore
          .collection('usuarios')
          .doc(_uid)
          .collection('personagens');

  // Criar personagem
  Future<void> criarHeroi(Personagem p) async {
    await _colecao.add(p.toMap());
  }

  // Listar somente os personagens do usuário atual
  Stream<QuerySnapshot<Map<String, dynamic>>> listarPersonagens() {
    return _colecao.snapshots();
  }

  // Atualizar a vida do personagem
  Future<void> tomarDano(String id, int novaVida) async {
    await _colecao.doc(id).update({'vida': novaVida});
  }

  // Excluir personagem
  Future<void> deletarPersonagem(String id) async {
    await _colecao.doc(id).delete();
  }
}
