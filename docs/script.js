// Menu mobile
const menuBtn = document.querySelector('.menu-btn');
const menu = document.getElementById('menu');

menuBtn.addEventListener('click', () => {
  const aberto = menu.classList.toggle('aberto');
  menuBtn.setAttribute('aria-expanded', aberto);
});
menu.addEventListener('click', (e) => {
  if (e.target.tagName === 'A') {
    menu.classList.remove('aberto');
    menuBtn.setAttribute('aria-expanded', false);
  }
});

// Prancha de demonstração (mesmas categorias e cores do app)
const CATEGORIAS = {
  'Ações': { cor: '#ef6c00', itens: ['quero', 'comer', 'beber', 'ir', 'dormir'] },
  'Pessoas': { cor: '#1e88e5', itens: ['eu', 'voce', 'mamae', 'papai'] },
  'Objetos': { cor: '#00897b', itens: ['agua', 'suco', 'pao', 'maca', 'bola', 'carro', 'brinquedo'] },
  'Emoções': { cor: '#558b2f', itens: ['feliz', 'triste', 'nervoso'] },
  'Negação': { cor: '#e53935', itens: ['nao', 'pare', 'acabou'] },
};

const ROTULOS = {
  voce: 'você', mamae: 'mamãe', pao: 'pão', maca: 'maçã', nao: 'não',
};

const MAX_FRASE = 8;

const abas = document.querySelector('.abas');
const grade = document.querySelector('.grade');
const fraseItens = document.querySelector('.frase-itens');
const frase = [];

const temVoz = 'speechSynthesis' in window;
let vozPtBr = null;

if (temVoz) {
  const escolherVoz = () => {
    const vozes = speechSynthesis.getVoices();
    vozPtBr = vozes.find((v) => v.lang === 'pt-BR') ||
      vozes.find((v) => v.lang.startsWith('pt')) || null;
  };
  escolherVoz();
  speechSynthesis.addEventListener('voiceschanged', escolherVoz);
} else {
  document.querySelector('.aviso-voz').hidden = false;
}

function falar(texto) {
  if (!temVoz) return;
  speechSynthesis.cancel();
  const fala = new SpeechSynthesisUtterance(texto);
  fala.lang = 'pt-BR';
  if (vozPtBr) fala.voice = vozPtBr;
  fala.rate = 0.9;
  speechSynthesis.speak(fala);
}

const rotulo = (id) => ROTULOS[id] || id;

function renderAbas(ativa) {
  abas.innerHTML = '';
  for (const [nome, { cor }] of Object.entries(CATEGORIAS)) {
    const aba = document.createElement('button');
    aba.className = 'aba';
    aba.role = 'tab';
    aba.textContent = nome;
    aba.style.setProperty('--c', cor);
    aba.setAttribute('aria-selected', nome === ativa);
    aba.addEventListener('click', () => {
      renderAbas(nome);
      renderGrade(nome);
    });
    abas.appendChild(aba);
  }
}

function renderGrade(categoria) {
  const { cor, itens } = CATEGORIAS[categoria];
  grade.innerHTML = '';
  for (const id of itens) {
    const botao = document.createElement('button');
    botao.className = 'picto';
    botao.style.setProperty('--c', cor);
    botao.innerHTML = `<img src="img/picto/${id}.webp" alt="" width="200" height="200"><span>${rotulo(id)}</span>`;
    botao.addEventListener('click', () => adicionar(id, cor));
    grade.appendChild(botao);
  }
}

function renderFrase() {
  fraseItens.innerHTML = '';
  if (frase.length === 0) {
    fraseItens.innerHTML = '<span class="frase-vazia">Toque nos pictogramas abaixo…</span>';
    return;
  }
  for (const { id, cor } of frase) {
    const item = document.createElement('div');
    item.className = 'frase-item';
    item.style.setProperty('--c', cor);
    item.innerHTML = `<img src="img/picto/${id}.webp" alt=""><span>${rotulo(id)}</span>`;
    fraseItens.appendChild(item);
  }
  fraseItens.scrollLeft = fraseItens.scrollWidth;
}

function adicionar(id, cor) {
  falar(rotulo(id));
  if (frase.length >= MAX_FRASE) return;
  frase.push({ id, cor });
  renderFrase();
}

document.querySelector('.frase-acoes').addEventListener('click', (e) => {
  const acao = e.target.closest('[data-acao]')?.dataset.acao;
  if (acao === 'apagar') frase.pop();
  if (acao === 'limpar') frase.length = 0;
  if (acao === 'falar' && frase.length) {
    falar(frase.map((p) => rotulo(p.id)).join(' '));
    fraseItens.querySelectorAll('.frase-item').forEach((el, i) => {
      el.classList.remove('falando');
      setTimeout(() => el.classList.add('falando'), i * 120);
    });
    return;
  }
  renderFrase();
});

renderAbas('Ações');
renderGrade('Ações');
