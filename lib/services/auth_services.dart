import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? usuario;
  bool isLoading = true;

  AuthService() {
    _authCheck();
  }

  // Monitora mudanças no estado de autenticação
  _authCheck() {
    _auth.authStateChanges().listen((User? user) {
      usuario = user;
      isLoading = false;
      notifyListeners();
    });
  }

  // MÉTODO DE LOGIN (apenas emails que já foram registrados)
  Future<String?> login({
    required String email,
    required String senha,
  }) async {
    try {
      // Remove a verificação prévia - deixa o Firebase validar
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      return null; // Sucesso

    } on FirebaseAuthException catch (e) {
      // Tratamento específico de erros do Firebase
      switch (e.code) {
        case 'user-not-found':
          return 'Email não cadastrado.\nCrie uma conta primeiro clicando em "Registrar".';
        case 'wrong-password':
          return 'Senha incorreta.\nTente novamente.';
        case 'invalid-email':
          return 'Email inválido.\nVerifique o formato do email.';
        case 'user-disabled':
          return 'Esta conta foi desativada.\nEntre em contato com o suporte.';
        case 'invalid-credential':
          return 'Email ou senha incorretos.\nVerifique seus dados.';
        case 'too-many-requests':
          return 'Muitas tentativas de login.\nTente novamente em alguns minutos.';
        case 'network-request-failed':
          return 'Erro de conexão.\nVerifique sua internet.';
        default:
          return 'Erro ao fazer login: ${e.message}';
      }
    } catch (e) {
      return 'Erro inesperado: $e';
    }
  }

  // MÉTODO DE REGISTRO (criar nova conta - HABILITADO)
  Future<String?> registrar({
    required String email,
    required String senha,
  }) async {
    try {
      // Remove a verificação prévia também aqui
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      return null; // Sucesso

    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Este email já está em uso.\nFaça login ou use outro email.';
        case 'weak-password':
          return 'Senha muito fraca.\nUse pelo menos 6 caracteres com letras e números.';
        case 'invalid-email':
          return 'Email inválido.\nVerifique o formato (exemplo@email.com).';
        case 'operation-not-allowed':
          return 'Registro temporariamente desabilitado.\nTente novamente mais tarde.';
        default:
          return 'Erro ao registrar: ${e.message}';
      }
    } catch (e) {
      return 'Erro inesperado: $e';
    }
  }

  // Método auxiliar para verificar se email existe
  Future<bool> emailExiste(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      print('Erro ao verificar email: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Resetar senha
  Future<String?> resetarSenha(String email) async {
    try {
      // Verifica se email existe
      final methods = await _auth.fetchSignInMethodsForEmail(email);

      if (methods.isEmpty) {
        return 'Email não encontrado.\nVerifique se digitou corretamente.';
      }

      await _auth.sendPasswordResetEmail(email: email);
      return null; // Sucesso

    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'Email inválido.';
        case 'user-not-found':
          return 'Usuário não encontrado.';
        default:
          return 'Erro ao enviar email: ${e.message}';
      }
    } catch (e) {
      return 'Erro inesperado: $e';
    }
  }
}