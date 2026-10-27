<p align="center">
  <img src="assets/logo/falatea.png" alt="Logo do FalaTEA" width="260">
</p>

<h1 align="center">FalaTEA</h1>

<p align="center">
  Aplicativo de Comunicação Aumentativa e Alternativa (CAA) para pessoas com Transtorno do Espectro Autista (TEA).
</p>

<p align="center">
  <a href="https://eduardo-loures.github.io/falatea/"><strong>Conheça o site do projeto</strong></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/Firebase-Auth%20%2B%20Firestore-FFCA28?logo=firebase&logoColor=white" alt="Firebase">
  <img src="https://img.shields.io/badge/Cloudinary-Imagens-3448C5?logo=cloudinary&logoColor=white" alt="Cloudinary">
  <img src="https://img.shields.io/badge/Plataforma-Android-3DDC84?logo=android&logoColor=white" alt="Android">
</p>

---

## Sobre o projeto

**FalaTEA** é um aplicativo de CAA (Comunicação Aumentativa e Alternativa) pensado para ajudar pessoas com TEA a se comunicarem através de pictogramas falados. O app converte toques em botões de comunicação em fala, permitindo que a criança monte frases simples selecionando imagens organizadas por categoria (Ações, Pessoas, Objetos, Emoções, Negação).

Além da comunicação, o app conta com **perfis independentes** (um por criança/usuário), **jogos educativos** para reforçar vocabulário, emoções e rotinas, e um **modo daltonismo** com paleta de cores acessível.

## Funcionalidades

### Comunicação
- **Grade de comunicação** com categorias fixas (Ações, Pessoas, Objetos, Emoções, Negação) e categorias personalizadas criadas pelo usuário.
- **Botões personalizados** com texto, ícone ou foto da galeria.
- **Síntese de voz (TTS)** em português do Brasil, com voz masculina/feminina e ajuste de velocidade e tom.
- Suporte a **orientação retrato e paisagem**, adaptando o layout da grade de botões automaticamente.

### Perfis e conta
- **Autenticação** com e-mail e senha (Firebase Auth), incluindo recuperação de senha.
- **Múltiplos perfis** por conta: cada perfil tem nome, foto, cor e ícone próprios, e mantém seus próprios botões e categorias.
- **Sincronização na nuvem**: perfis, categorias e botões ficam salvos no Cloud Firestore e as fotos no Cloudinary, então nada se perde ao trocar de aparelho.

### Jogos educativos
| Jogo | Objetivo |
|------|----------|
| **Qual é?** | Associar uma foto real ao pictograma correspondente. |
| **Emoções** | Reconhecer expressões faciais (feliz, triste, bravo, cansado). |
| **Cores** | Associar cada cor ao seu nome, ouvindo a palavra falada. |
| **Minha Rotina** | Colocar em ordem os passos de atividades do dia a dia (escovar os dentes, tomar banho, dormir…). |

Os jogos têm estrelas como recompensa e um botão de ajuda.

### Acessibilidade
- **Modo daltonismo**: troca as cores das categorias e dos jogos por uma paleta acessível (baseada em Okabe-Ito).
- **Avisos padronizados** para erros, confirmações e exclusões.
- Tamanho de fonte do sistema respeitado até um limite seguro, para não quebrar o layout.

## Tecnologias utilizadas

| Categoria         | Tecnologia                                  |
|-------------------|----------------------------------------------|
| Framework         | [Flutter](https://flutter.dev)               |
| Linguagem         | [Dart](https://dart.dev)                      |
| Autenticação      | [Firebase Auth](https://firebase.google.com/products/auth) |
| Banco de dados    | [Cloud Firestore](https://firebase.google.com/products/firestore) |
| Armazenamento de imagens | [Cloudinary](https://cloudinary.com) |
| Gerenciamento de estado | [Provider](https://pub.dev/packages/provider) |
| Persistência local| [shared_preferences](https://pub.dev/packages/shared_preferences) |
| Texto-para-fala   | [flutter_tts](https://pub.dev/packages/flutter_tts) |
| Seleção de imagens| [image_picker](https://pub.dev/packages/image_picker) |
| Requisições HTTP  | [http](https://pub.dev/packages/http) |

## Estrutura do projeto

```
lib/
├── games/          # Jogos educativos (Qual é?, Emoções, Cores, Minha Rotina)
├── models/         # Modelos de dados (Perfil, BotaoAAC)
├── pages/          # Telas do aplicativo
├── services/       # Regras de negócio (Auth, Perfis, TTS, Cloudinary, Acessibilidade)
├── utils/          # Paleta de cores acessível
└── widgets/        # Componentes reutilizáveis (avisos, verificação de login)
docs/               # Site de apresentação (GitHub Pages)
firestore.rules     # Regras de segurança do Firestore
```

## Como executar

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado e configurado.
- Um projeto no [Firebase Console](https://console.firebase.google.com/) com **Authentication** (e-mail/senha) e **Cloud Firestore** habilitados.
- Uma conta no [Cloudinary](https://cloudinary.com) com um *upload preset* do tipo **unsigned**.

### Passo a passo

```bash
# Clone o repositório
git clone https://github.com/Eduardo-Loures/falatea.git
cd falatea

# Instale as dependências
flutter pub get
```

1. Adicione o arquivo `google-services.json` do seu projeto Firebase em `android/app/` (esse arquivo não é versionado, por conter credenciais do projeto).
2. Publique as regras de segurança do Firestore usando o conteúdo de `firestore.rules` (pelo Console do Firebase ou com `firebase deploy --only firestore:rules`).
3. Configure `cloudName` e `uploadPreset` em `lib/services/cloudinary_service.dart` com os dados da sua conta Cloudinary.

```bash
# Rode o app em um emulador ou dispositivo conectado
flutter run
```

## Equipe

Projeto desenvolvido pelo **Grupo FalaTEA**, do curso de Engenharia de Computação (10º semestre):

- Eduardo Henrique Piellusch Loures ([@Eduardo-Loures](https://github.com/Eduardo-Loures))
- Fábio Machado de Moraes
- Polyana Pachel Lavrador
- Vinicius Fernandes Dutra

## Créditos

Pictogramas: Sergio Palao. Origem: [ARASAAC](https://arasaac.org). Licença: CC BY-NC-SA. Propriedade: Governo de Aragão (Espanha).
