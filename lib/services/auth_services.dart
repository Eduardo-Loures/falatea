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

  // MeTODO DE LOGIN (apenas emails que já foram registrados)
  Future<String?> login({
    required String email,
    required String senha,
  }) async {
    try {
      // Firebase valida e realiza o login
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // Recarrega dados do usuário (necessário para contas antigas)
      await _auth.currentUser?.reload();
      usuario = _auth.currentUser;

      notifyListeners();
      return null; // Sucesso

    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Email não cadastrado.\nCrie uma conta primeiro clicando em "Registrar".';
        case 'wrong-password':
          return 'Senha incorreta.\nTente novamente.';
        case 'invalid-email':
          return 'Email inválido.';
        case 'user-disabled':
          return 'Esta conta foi desativada.';
        case 'invalid-credential':
          return 'Email ou senha incorretos.';
        case 'too-many-requests':
          return 'Muitas tentativas de login.';
        default:
          return 'Erro ao fazer login: ${e.message}';
      }
    } catch (e) {
      return 'Erro inesperado: $e';
    }
  }

  // MeTODO DE REGISTRO (criar nova conta)
  Future<String?> registrar({
    required String email,
    required String senha,
    required String nome,
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // Atualiza o nome
      await cred.user!.updateDisplayName(nome);
      await _auth.currentUser!.reload();
      usuario = _auth.currentUser;

      notifyListeners();
      return null;

    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Este email já está em uso.\nTente fazer login.';
        case 'invalid-email':
          return 'O email informado é inválido.';
        case 'weak-password':
          return 'A senha é muito fraca.\nUse pelo menos 6 caracteres.';
        case 'operation-not-allowed':
          return 'Cadastro com email/senha está desabilitado.';
        default:
          return 'Erro ao criar conta: ${e.message}';
      }
    } catch (e) {
      return 'Erro inesperado: $e';
    }
  }

  // Metodo auxiliar para verificar se email existe
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