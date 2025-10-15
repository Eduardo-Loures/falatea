import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthException implements Exception {
  String message;
  AuthException(this.message);
}

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? usuario;
  bool isLoading = true;

  AuthService() {
    _authCheck();
  }

  _authCheck() {
    _auth.authStateChanges().listen((User? user) {
      usuario = user;
      isLoading = false;
      notifyListeners();
    });
  }

  _getUser() {
    usuario = _auth.currentUser;
    notifyListeners();
  }

  Future<void> registrar(String email, String senha) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      _getUser();
    } on FirebaseAuthException catch (e) {
      // Mapeia TODOS os erros possíveis para português
      switch (e.code) {
        case 'weak-password':
          throw AuthException('A senha é muito fraca!');
        case 'email-already-in-use':
          throw AuthException('Este email já está cadastrado');
        case 'invalid-email':
          throw AuthException('Email inválido');
        case 'operation-not-allowed':
          throw AuthException('Operação não permitida');
        case 'network-request-failed':
          throw AuthException('Erro de conexão. Verifique sua internet');
        default:
          throw AuthException('Erro ao cadastrar. Tente novamente');
      }
    } catch (e) {
      throw AuthException('Erro desconhecido ao cadastrar');
    }
  }

  Future<void> login(String email, String senha) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      _getUser();
    } on FirebaseAuthException catch (e) {
      // Mapeia TODOS os erros possíveis para português
      switch (e.code) {
        case 'user-not-found':
          throw AuthException('Email não encontrado. Cadastre-se');
        case 'wrong-password':
          throw AuthException('Senha incorreta');
        case 'invalid-email':
          throw AuthException('Email inválido');
        case 'user-disabled':
          throw AuthException('Usuário desabilitado');
        case 'too-many-requests':
          throw AuthException('Muitas tentativas. Aguarde um momento');
        case 'operation-not-allowed':
          throw AuthException('Operação não permitida');
        case 'network-request-failed':
          throw AuthException('Erro de conexão. Verifique sua internet');
        case 'invalid-credential':
          throw AuthException('Email ou senha incorretos');
        case 'INVALID_LOGIN_CREDENTIALS':
          throw AuthException('Email ou senha incorretos');
        default:
          throw AuthException('Erro ao fazer login. Verifique seus dados');
      }
    } catch (e) {
      throw AuthException('Erro ao fazer login. Tente novamente');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _getUser();
  }
}