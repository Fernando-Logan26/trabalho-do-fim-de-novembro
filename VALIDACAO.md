# Validação da entrega

- Interface e regras implementadas em Dart/Flutter, sem WebView.
- `flutter analyze --no-pub`: nenhuma ocorrência.
- `flutter test --no-pub`: quatro testes aprovados (persistência e exclusão de ocorrências, persistência de preferências, navegação das boas-vindas e validação do formulário).
- Layout das boas-vindas conferido em renderização Flutter de 390 × 844 pixels.
- APK release compilado para ARM de 32 e 64 bits, Android 7 (API 24) ou superior.
- Assinatura APK v2 verificada; certificado de desenvolvimento para instalação de teste.
- Não foi realizado teste em aparelho físico. Câmera, galeria, carregamento dos mapas e abertura do Google Maps devem ser conferidos no celular.

Esta é uma demonstração funcional com armazenamento local. As notícias e os pontos de acessibilidade são exemplos; não há servidor, envio à Prefeitura ou cálculo de rotas acessíveis.

SHA-256 do APK entregue: `96682cb02f42e317184ee3890111637379cbf916a7fef9498ef595942647a04c`.
