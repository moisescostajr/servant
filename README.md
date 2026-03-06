# Servant 🤵‍♂️🚀

**Servant** é um aplicativo nativo para macOS que vive na sua barra de menus (Menu Bar), projetado para simplificar a vida de desenvolvedores que gerenciam múltiplos servidores localmente. Pare, inicie e monitore seus processos (Node.js, Next.js, Docker, etc.) com um único clique.

![Status do Projeto](https://img.shields.io/badge/Status-Funcional-brightgreen)
![Platform](https://img.shields.io/badge/Plataforma-macOS-lightgrey)

---

## ✨ Funcionalidades

- **Acesso Rápido via Menu Bar:** Controle seus servidores sem precisar alternar entre dezenas de abas no terminal.
- **Monitoramento em Tempo Real:**
  - 🟢 **Verde:** Servidor rodando e respondendo na porta configurada (Health Check).
  - 🟡 **Amarelo:** Processo iniciado, aguardando resposta do servidor.
  - ⚪ **Cinza:** Inativo.
- **Diagnóstico Unificado:** Captura e exibe `stdout` e `stderr` diretamente, permitindo ver logs de erro se um servidor falhar ao iniciar.
- **Gerenciamento de Servidores:** Adicione, edite e remova configurações de servidores facilmente.
- **Ações Rápidas:** Abra a pasta do projeto no Finder ou no VS Code diretamente pelo menu do app.
- **Multi-idioma:** Suporte nativo para Português (Brasil), Inglês e Espanhol.

---

## 🛠️ Tecnologias

- **Linguagem:** Swift 6
- **Interface:** SwiftUI
- **Arquitetura:** MVVM (Model-View-ViewModel)
- **Gerenciamento de Processos:** Foundation `Process` (NSTask)
- **Persistência:** UserDefaults

---

## 🚀 Como Executar

### Pré-requisitos
- macOS 13.0 ou superior.
- Xcode 15+ (para compilação).

### Instalação (Build Manual)
1. Clone o repositório:
   ```bash
   git clone https://github.com/moisescostajr/servant.git
   cd servant
   ```
2. Execute o script de build para gerar o `.app` e o `.dmg`:
   ```bash
   ./build_app.sh
   ```
3. O aplicativo `Servant.app` será gerado na pasta raiz. Arraste-o para sua pasta de **Aplicativos**.

---

## 📖 Como Usar

1. Abra o **Servant**. Um ícone de "servidor" aparecerá na sua barra de menus superior.
2. Clique no ícone de engrenagem ⚙️ para abrir as **Configurações**.
3. Adicione um novo servidor informando:
   - **Nome:** Ex: "Meu Projeto Web"
   - **Caminho:** A pasta onde está o projeto.
   - **Porta:** Ex: `3000` (usada para o Health Check).
   - **Comando:** Ex: `npm run dev`.
4. Salve e clique no ícone de "Play" ▶️ no menu principal para iniciar.

---

## 👨‍💻 Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para abrir Issues ou enviar Pull Requests.

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.

---
*Desenvolvido para automatizar o caos do dia a dia dev.* 🤵‍♂️✨