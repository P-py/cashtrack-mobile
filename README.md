<a id="readme-top"></a>

[![Contributors][contributors-shield]][contributors-url]
[![project_license][license-shield]][license-url]

<!-- PROJECT LOGO -->
<br />
<div align="center">

<h3 align="center">Cash-Track Mobile</h3>

  <p align="center">
    O Cashtrack Mobile é a aplicação mobile de um ecossistema responsável por proprorcionar uma experiência fluída de gestão financeira pessoal, desenvolvida com Flutter (Dart) para Android e iOS.
    <br />
    <a href="https://github.com/P-py/cashtrack-mobile/tree/main/docs"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://cash-track-puce.vercel.app/">View Demo</a>
    &middot;
    <a href="https://github.com/P-py/cashtrack-mobile/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    &middot;
    <a href="https://github.com/P-py/cashtrack-mobile/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Conteúdos</summary>
  <ol>
    <li>
      <a href="#sobre-o-projeto">Sobre o projeto</a>
      <ul>
        <li><a href="#stack-de-tecnologias">Stack de tecnologias</a></li>
      </ul>
    </li>
    <li>
      <a href="#configuração-inicial">Configuração inicial</a>
      <ul>
        <li><a href="#pré-requisitos">Pré-requisitos</a></li>
        <li><a href="#instalação">Instalação</a></li>
      </ul>
    </li>
    <li><a href="#usabilidade">Usabilidade</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contribuindo">Contribuindo</a></li>
      <ul>
        <li><a href="#como-contribuir">Como contribuir</a></li>
        <li><a href="#regras-de-contribuição">Regras de contribuição</a></li>
      </ul>
    <li><a href="#licença-do-projeto">Licença do projeto</a></li>
    <li><a href="#contato">Contato</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## Sobre o projeto

O Cashtrack Mobile é a aplicação cliente do ecossistema Cashtrack, desenvolvida com Flutter (Dart) para Android e iOS. Criado como parte de um projeto acadêmico na disciplina de *Desenvolvimento Mobile* da [Faculdade de Engenharia de Sorocaba (FACENS)](https://facens.br/), o sistema oferece uma experiência moderna e segura para usuários que desejam registrar suas receitas e despesas, visualizar históricos e gerenciar suas finanças.

Seu principal objetivo é proporcionar uma experiência fluida e intuitiva de gestão financeira pessoal, permitindo o registro de receitas, despesas, visualização de gráficos, e gerenciamento de conta diretamente no smartphone do usuário.

Este repositório representa o front-end mobile, que se comunica com a [Cashtrack API](https://github.com/P-py/cash-track-api/) por meio de autenticação JWT e endpoints RESTful.
O aplicativo foi projetado para ser leve, seguro, acessível e livre de anúncios, seguindo boas práticas de arquitetura, usabilidade e persistência local de dados.

<p align="right">(<a href="#readme-top">back to top</a>)</p>


### Stack de tecnologias

[![Dart Logo][dart-shield]]()
[![Flutter Logo][flutter-shield]]()

A arquitetura segue o padrão MVVM simplificado, com separação de responsabilidades entre services, screens e widgets reutilizáveis, garantindo escalabilidade e manutenibilidade do código.

- **Flutter** – Framework multiplataforma moderno e performático.
- **Dart** – Linguagem fortemente tipada e otimizada para o Flutter.
- **Provider** – Gerenciamento de estado reativo e seguro.
- **HTTP** – Comunicação com a API REST Cashtrack.
- **Shared Preferences** – Armazenamento seguro do token JWT.
- **FL Chart** – Renderização de gráficos dinâmicos de despesas e receitas.
- **Material Design 3** – Layout moderno, com dark mode nativo e paleta personalizada.

> **Nota:** Este repositório contém exclusivamente o código do **mobile** da aplicação. Para a lógica de serviço, acesse o repositório do [backend](https://github.com/P-py/cash-track-api).


<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- GETTING STARTED -->
## Configuração inicial

Esta seção fornece instruções sobre como obter uma cópia local do projeto e executá-lo para desenvolvimento e testes.

### Pré-requisitos

Certifique-se de ter instalado:

- [Flutter SDK 3.22+](https://flutter.dev/docs/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio) ou [VSCode](https://code.visualstudio.com/)
- Emulador Android / iOS configurado
- Backend do Cashtrack em execução ([Cashtrack API](https://github.com/P-py/cashtrack-api))

Para verificar a instalação:
```bash
flutter doctor
```

### ⚡ Instalação e execução

1. Clone o repositório:
   ```bash
   git clone https://github.com/P-py/cashtrack-mobile.git
   cd cashtrack-mobile
   ```

2. Instale as dependências:
   ```bash
   flutter pub get
   ```

3. Execute o aplicativo:
   ```bash
   flutter run
   ```

4. (Opcional) Gere o APK de release:
   ```bash
   flutter build apk --release
   ```

O app será iniciado no emulador ou dispositivo conectado.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usabilidade

O Cashtrack Mobile foi desenvolvido com foco em **acessibilidade, responsividade e experiência fluida**.

Funcionalidades principais:

- 🔐 **Autenticação segura** via JWT  
- 💰 **Registro de receitas e despesas** com categorização  
- 📊 **Gráficos dinâmicos** de evolução financeira  
- ⚙️ **Gerenciamento de conta e perfil**  
- 📴 **Uso offline** com sincronização automática  
- 🌙 **Interface dark elegante e responsiva**

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ROADMAP -->
## 🧭 Roadmap

- v0.5.0  
  - [ ] Integração completa com backend de notificações  
  - [ ] Suporte offline aprimorado  
  - [ ] Melhorias de performance e build size  

- v1.0.0  
  - [ ] Publicação nas stores (Play Store e App Store)  
  - [ ] Integração biométrica  
  - [ ] Internacionalização (i18n)  

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->
### 🧩 Como contribuir

1. Faça um fork:
   ```bash
   git fork https://github.com/P-py/cashtrack-mobile
   ```
2. Crie uma branch:
   ```bash
   git checkout -b minha-feature
   ```
3. Faça commit das mudanças:
   ```bash
   git commit -m "Adiciona nova tela de relatórios"
   ```
4. Envie suas alterações:
   ```bash
   git push origin minha-feature
   ```
5. Abra um Pull Request 💡

### Regras de contribuição
- Sempre mantenha seu código limpo e documentado.
- Escreva commits claros e objetivos.
- Siga a estrutura do projeto e os padrões de nomenclatura existentes.
- Certifique-se de que suas alterações não quebram funcionalidades existentes.
- Sugestões de contribuição

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- LICENSE -->
## Licença do projeto

Este projeto está licenciado sob os termos da licença MIT. Seus autores podem ser encontrados na aba de [Contributors](https://github.com/P-py/cashtrack-mobile/graphs/contributors) do GitHub.

Você pode consultar os detalhes completos no arquivo [`LICENSE.txt`](./LICENSE.txt).

Sinta-se à vontade para usar, modificar e distribuir este projeto, respeitando os termos da licença.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->
## Contato

Entre em contato com os desenvolvedores do projeto Cashtrack:

- **Pedro Salviano Santos** – 236586@facens.br  
- **Luiz Gustavo Motta Viana** – 236428@facens.br  
- **Ronaldo Simeone Antonio** – 190232@facens.br  
- **Erick Ferreira Ribeiro** – 237046@facens.br
- **Leonardo Vergilio Luz** - 234674@facens.br

Projeto desenvolvido como parte da disciplina de **Desenvolvimento Mobile**

Facens – 2025

Sinta-se à vontade para contribuir, abrir issues ou enviar sugestões via GitHub!

<p align="right">(<a href="#readme-top">back to top</a>)</p>

[contributors-shield]: https://img.shields.io/github/contributors/P-py/cash-track.svg?style=for-the-badge
[dart-shield]: https://img.shields.io/badge/dart-black?logo=dart
[flutter-shield]: https://img.shields.io/badge/flutter-black?logo=flutter
[contributors-url]: https://github.com/P-py/cashtrack-mobile/graphs/contributors
[license-shield]: https://img.shields.io/github/license/P-py/cashtrack-mobile.svg?style=for-the-badge
[license-url]: https://github.com/P-py/cashtrack-mobile/blob/main/LICENSE.txt
