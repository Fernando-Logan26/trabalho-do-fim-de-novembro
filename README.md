# Mobilidade PVH — Flutter e Dart

Protótipo Android do projeto acadêmico de mobilidade e acessibilidade urbana de Porto Velho. Interface, navegação, formulários e regras implementados em Dart com Flutter, sem WebView.

## Funcionalidades

- Boas-vindas com explicação do aplicativo.
- Início com notícias ilustrativas das principais ruas e filtros por tema.
- Mapa interativo OpenStreetMap com zoom, regiões predefinidas e marcadores demonstrativos de rampas e barreiras.
- Ocorrências com endereço, descrição e foto da câmera ou galeria, persistidas no aparelho.
- Histórico, detalhes e exclusão de registros locais.
- Preferências de tamanho de texto, contraste dos controles e perfil de mobilidade.
- Destino informado pelo usuário abre direções a pé no Google Maps externo.

## Limites desta versão

Notícias e marcadores não representam acontecimentos ou condições reais. O aplicativo não calcula rotas acessíveis, não envia ocorrências à Prefeitura, não tem contas de usuário ou servidor, e não publica os registros no mapa. A busca do mapa oferece três regiões predefinidas. Os mapas exigem internet. Desinstalar o aplicativo apaga os registros locais. O uso dos serviços de mapa está sujeito às políticas de seus provedores; para distribuição em escala, configure um provedor de mapas apropriado.

## Desenvolvimento

Versão usada: Flutter 3.35.7 / Dart 3.9.2. JDK 17 e Android SDK 36.

O APK entregue é destinado a celulares ARM de 32 e 64 bits com Android 7 ou superior.

```bash
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk --release --target-platform android-arm,android-arm64
```

O APK é gerado em `build/app/outputs/flutter-apk/app-release.apk`. A configuração usa assinatura de desenvolvimento para testes; para publicação configure sua própria chave de assinatura. Não há chave de API ou credencial de produção no projeto.

## Organização

- `lib/main.dart`: aplicativo, tema e navegação.
- `lib/screens/`: telas Flutter.
- `lib/widgets/`: mapa, componentes e ilustração vetorial.
- `lib/models/occurrence.dart`: modelo do registro.
- `lib/services/app_store.dart`: persistência local.
- `test/app_test.dart`: validações de persistência, preferências e interface.

Mapas © OpenStreetMap contributors: https://www.openstreetmap.org/copyright
