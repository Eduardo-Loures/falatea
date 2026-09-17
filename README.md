<p align="center">
  <img src="assets/logo/falatea.png" alt="Logo do FalaTEA" width="260">
</p>

<h1 align="center">FalaTEA</h1>

<p align="center">
  Aplicativo de Comunicação Aumentativa e Alternativa (CAA) para pessoas com Transtorno do Espectro Autista (TEA).
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Firebase-Auth-FFCA28?logo=firebase&logoColor=white" alt="Firebase">
  <img src="https://img.shields.io/badge/Plataforma-Android-3DDC84?logo=android&logoColor=white" alt="Android">
</p>

---

## Sobre o projeto

**FalaTEA** é um aplicativo de CAA (Comunicação Aumentativa e Alternativa) pensado para ajudar pessoas com TEA a se comunicarem através de pictogramas falados. O app converte toques em botões de comunicação em fala, permitindo que a criança monte frases simples selecionando imagens organizadas por categoria (Ações, Pessoas, Objetos, Emoções, Negação).

Além da comunicação, o app conta com **perfis independentes** (um por criança/usuário) e **jogos educativos** para reforçar o reconhecimento de palavras e emoções.

## Funcionalidades

- **Autenticação** com e-mail e senha (Firebase Auth), incluindo recuperação de senha.
- **Múltiplos perfis** por conta — cada perfil tem nome, foto, cor e ícone próprios, e mantém seus próprios botões e categorias.
- **Grade de comunicação** com categorias fixas (Ações, Pessoas, Objetos, Emoções, Negação) e categorias personalizadas criadas pelo usuário.
- **Botões personalizados** com texto, ícone ou foto da galeria.
- **Síntese de voz (TTS)** em português do Brasil, com voz masculina/feminina, controle de velocidade, tom e volume.
- **Dois jogos educativos**:
  - *Qual é?* — associar uma foto real ao pictograma correspondente.
  - *Emoções* — reconhecer expressões faciais (feliz, triste, bravo, cansado).
- Suporte a **orientação retrato e paisagem**, adaptando o layout da grade de botões automaticamente.

## Tecnologias utilizadas

| Categoria         | Tecnologia                                  |
|-------------------|----------------------------------------------|
| Framework         | [Flutter](https://flutter.dev)               |
| Linguagem         | [Dart](https://dart.dev)                      |
| Autenticação      | [Firebase Auth](https://firebase.google.com/products/auth) |
| Gerenciamento de estado | [Provider](https://pub.dev/packages/provider) |
| Persistência local| [shared_preferences](https://pub.dev/packages/shared_preferences) |
| Texto-para-fala   | [flutter_tts](https://pub.dev/packages/flutter_tts) |
| Seleção de imagens| [image_picker](https://pub.dev/packages/image_picker) |
| Identificadores   | [uuid](https://pub.dev/packages/uuid)         |

## Estrutura do projeto

```
lib/
├── games/          # Jogos educativos (Emoções, Qual é?)
├── models/         # Modelos de dados (Perfil, BotaoAAC)
├── pages/          # Telas do aplicativo
├── services/        # Regras de negócio (Auth, Perfis, TTS)
└── widgets/         # Componentes reutilizáveis
```

## Como executar

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado e configurado.
- Um projeto no [Firebase Console](https://console.firebase.google.com/) com Authentication (e-mail/senha) habilitado.

### Passo a passo

```bash
# Clone o repositório
git clone https://github.com/Eduardo-Loures/falatea.git
cd falatea

# Instale as dependências
flutter pub get
```

Adicione o arquivo `google-services.json` do seu projeto Firebase em `android/app/` (esse arquivo não é versionado, por conter credenciais do projeto).

```bash
# Rode o app em um emulador ou dispositivo conectado
flutter run
```

## Autor

Desenvolvido por **Eduardo Loures** — [@Eduardo-Loures](https://github.com/Eduardo-Loures)
