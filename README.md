# Morphling

Pacote Flutter com arquitetura base para telas orientadas a BloC e com um modulo de autenticacao generico (`MorphLoginBloc` + `MorphLoginPage`) para reutilizacao entre apps.

## Visao geral

A `morphling` tem dois objetivos principais:

1. Fornecer uma base arquitetural simples e reutilizavel para estado, eventos, navegacao e DI.
2. Entregar um fluxo de login completo e tipado por generics para diferentes dominios (`User`, `Token`, `Company`).

O pacote exporta:

- `architecture`: contratos e utilitarios base (`IBloC`, estados auxiliares, injecao, falhas, excecoes, use case).
- `components`: tokens visuais reutilizaveis (`DesignTokens`).
- `modules`: modulo de auth com bloc, estados, eventos, pagina e portas de integracao.

## Estrutura do pacote

```text
lib/
  morphling.dart
  src/
    src.dart
    injector.dart
    architecture/
      bloc/
        bloc.dart
        bloc_state.dart
        fetching_state.dart
        persisting_state.dart
        navigator.dart
        screen.dart
        mixins/
          fancy_mixin.dart
          hud_mixin.dart
      injection/
        inj_container.dart
        injector.dart
      failures/
      exceptions/
      use_case.dart
    components/
      layout/design_tokens.dart
    modules/
      auth/
        auth.dart
        domain/models/
          login_request.dart
          login_result.dart
          saved_login.dart
        presentation/
          bloc/
            login_bloc.dart
            login_event.dart
            login_state.dart
            login_status.dart
          ports/
            auth_gateways.dart
            auth_policies.dart
            auth_ui_mapper.dart
          screens/
            morph_login_page.dart
            login_field_labels.dart
            app_logo.dart
```

## Arquitetura base

### 1) Camada de estado/evento (`IBloC`)

Arquivo: `lib/src/architecture/bloc/bloc.dart`

`IBloC<Event, State>` e a base de gerenciamento de eventos e estados. Ele usa `FancyMixin` internamente (baseado em `fancy_stream`) para publicar e ouvir streams por tipo e chave.

Responsabilidades principais:

- `onInit()`: inicia escuta de eventos (`listen<Event>(handleEvent)`).
- `handleEvent(Event event)`: tratamento de eventos implementado pela classe concreta.
- `dispatchEvent(event)`: publica evento.
- `dispatchState(state)`: publica estado (com chave do proprio bloc).
- `onClose()`: libera recursos de stream (`fancyDispose()`).

Helpers de status operacional:

- `doFetch(...)`: padroniza fluxo de carregamento de leitura com `FetchingState`.
- `doPersist(...)`: padroniza fluxo de operacao de escrita com `PersistingState`.

### 2) Mixins de comportamento

- `FancyMixin` (`mixins/fancy_mixin.dart`): encapsula stream bus tipado.
- `HudMixin` (`mixins/hud_mixin.dart`): utilitarios de UI globais (snackbar, dialogo, bottom sheet, confirmacao, selecao), usando `NavigatorService.key.currentContext`.

### 3) Estados e contratos comuns

- `ScreenState<T>` (`bloc_state.dart`) com variantes `Empty`, `Loading`, `Stable`, `Error`.
- `FetchingState` e `PersistingState` (`enum`) para status operacional.
- `IUseCase<Input, Output>` (`use_case.dart`) como contrato de caso de uso.
- `Failure`, `RemoteFailure`, `CacheFailure` e excecoes associadas.

### 4) Navegacao desacoplada

Arquivo: `lib/src/architecture/bloc/navigator.dart`

`NavigatorService` encapsula navegacao por rota nomeada e guarda:

- rota atual (`currentRoute`),
- rota anterior (`lastRoute`),
- argumentos (`arguments`).

A chave global e `NavigatorService.key`. Isso permite blocs/mixins abrirem HUD/dialogos sem depender de `BuildContext` local de widget.

### 5) Injecao de dependencia

Arquivos:

- `lib/src/architecture/injection/inj_container.dart`
- `lib/src/architecture/injection/injector.dart`
- `lib/src/injector.dart`

A base de DI usa `get_it` (instancia isolada via `GetIt.asNewInstance()`).

`ContainerInjector` oferece:

- `find<T>()`
- `put<T>()` (lazy singleton)
- `lazyPut<T>()` (factory)
- `putAsync<T>()`
- `delete<T>()`
- `reset()`

`DependencyInjector` define o contrato `dependencies()`.

`MorphlingInjector` registra dependencias basicas do pacote (atualmente `NavigatorService`).

## Modulo de autenticacao (Auth)

O modulo de auth e generico e desacoplado da camada de dados real. Integracoes externas entram por portas (`ports`), nao por implementacoes concretas no pacote.

### Modelos de dominio

- `LoginRequest<TCompany>`: payload da autenticacao.
- `LoginResult<TUser, TToken, TCompany>`: retorno consolidado do login.
- `SavedLogin<TToken, TCompany>`: dados persistidos para auto-preenchimento/biometria.

### Portas (contratos de integracao)

Arquivo: `presentation/ports/auth_gateways.dart`

- `AuthCatalogGateway`: busca tokens/autorizacao/empresas.
- `AuthSessionGateway`: executa login.
- `CredentialVault`: persiste/recupera credenciais e configuracao de biometria.
- `NotificationTokenProvider`: fornece token de push.
- `PasswordCipher`: cifra/decifra senha.
- `BiometricGateway`: disponibilidade e autenticacao biometrica.

Outras portas:

- `AuthUiMapper<TToken, TCompany>`: converte token/empresa para labels de UI.
- `AuthPolicy`: hooks `beforeLogin` e `afterLogin`.
- `AuthPostLoginHook`: acao final apos login bem-sucedido.

### Estado de login

Arquivo: `presentation/bloc/login_state.dart`

`LoginState<TUser, TToken, TCompany>` concentra:

- campos de formulario (`registrationNumber`, `user`, `password`),
- comportamento de persistencia (`saveData`, `isUseBiometry`),
- status (`LoginStatus`),
- dados de catalogo (`tokens`, `companies`, `authorization`, selecoes),
- erro (`errorMessage`),
- resultado final (`result`).

`canSubmit` valida os requisitos minimos para autenticar.

### Eventos de login

Arquivo: `presentation/bloc/login_event.dart`

Principais eventos:

- inicializacao: `InitRequested`
- digitacao/selecao: `RegistrationNumberChanged`, `TokenChanged`, `CompanyChanged`, `UserChanged`, `PasswordChanged`, `SaveDataChanged`
- acoes: `BiometricRequested`, `SubmitRequested`, `ResetErrorRequested`

### Status de login

Arquivo: `presentation/bloc/login_status.dart`

`LoginStatus`:

- `idle`
- `loadingRegistration`
- `loadingLogin`
- `success`
- `error`

### Fluxo do `MorphLoginBloc`

Arquivo: `presentation/bloc/login_bloc.dart`

Fluxo principal:

1. `onInit()` publica estado inicial atual (`currentState`).
2. `InitRequested`:
   - carrega dados salvos via `CredentialVault.load()`;
   - verifica biometria disponivel;
   - preenche formulario e, se CNPJ estiver completo, carrega catalogo automaticamente.
3. `RegistrationNumberChanged`:
   - atualiza CNPJ;
   - com 18 caracteres formatados, chama `_loadCatalog`.
4. `_loadCatalog`:
   - busca tokens -> autorizacao -> empresas;
   - resolve selecao preferida (com matchers customizaveis);
   - atualiza estado para `idle`.
5. `TokenChanged`:
   - recarrega autorizacao e lista de empresas do token selecionado.
6. `BiometricRequested`:
   - autentica com biometria;
   - le senha cifrada do vault;
   - decifra e dispara submit.
7. `SubmitRequested`:
   - valida `canSubmit`;
   - monta `LoginRequest`;
   - executa `policy.beforeLogin`;
   - executa login em `AuthSessionGateway`;
   - monta `LoginResult`;
   - executa `policy.afterLogin`;
   - salva/limpa credenciais no `CredentialVault`;
   - executa `postLoginHook`;
   - publica `success` com `result`.
8. Qualquer excecao atualiza `status = error` e `errorMessage`.

## UI de autenticacao (`MorphLoginPage`)

Arquivo: `presentation/screens/morph_login_page.dart`

`MorphLoginPage` e um `StatefulWidget` que renderiza todo o layout de login e conversa com `MorphLoginBloc` por stream.

### Responsabilidades da tela

- Cria e sincroniza controllers com o estado do bloc.
- Dispara eventos de formulario para o bloc.
- Reage a `LoginStatus`:
  - abre loading em `loadingLogin`,
  - mostra dialogo de erro em `error`,
  - chama `onLoginSuccess(result)` em `success`.

### Customizacao da UI

Paramentros configuraveis:

- textos (`LoginFieldLabels`, titulos/subtitulos, labels de card),
- branding (`AppSettings`, `headerLogo`, badge de dev, versao),
- loading custom (`loadingWidget`),
- comportamento biometrico inicial (`requestBiometricOnInit`),
- callback final (`onLoginSuccess`).

### Componentes internos

- `AppLogo`: cabecalho visual com asset do pacote.
- `MorphCustomTextFormField`: campo reutilizavel com estilos/tokens da biblioteca.
- `_CnpjInputFormatter`: mascara de CNPJ.
- `_LoginBackground`: fundo com gradiente e formas decorativas.

## Design tokens

Arquivo: `lib/src/components/layout/design_tokens.dart`

Centraliza espacamentos, dimensoes e constantes de layout para manter consistencia visual entre telas.

## Integracao recomendada no app hospedeiro

Passos tipicos para usar o login da `morphling`:

1. Implementar as portas de `auth_gateways.dart` no app (API, storage, biometria, criptografia, push).
2. Implementar `AuthUiMapper` para labels de token/empresa.
3. Instanciar `MorphLoginBloc` com as implementacoes concretas.
4. Renderizar `MorphLoginPage` passando:
   - `bloc`
   - `mapper`
   - `onLoginSuccess`
   - labels/textos de acordo com o produto.
5. No callback de sucesso, persistir contexto de sessao e navegar para a home do app.

## Exemplo de composicao

```dart
final bloc = MorphLoginBloc<User, Token, Company>(
  catalogGateway: myCatalogGateway,
  sessionGateway: mySessionGateway,
  credentialVault: myCredentialVault,
  notificationTokenProvider: myNotificationTokenProvider,
  passwordCipher: myPasswordCipher,
  biometricGateway: myBiometricGateway,
  tokenMatcher: (a, b) => a.id == b.id,
  companyMatcher: (a, b) => a.code == b.code,
);

MorphLoginPage<User, Token, Company>(
  bloc: bloc,
  mapper: myUiMapper,
  settings: const AppSettings(
    appName: 'Meu App',
    subName: 'Logistica',
    label: 'Acesse sua conta e continue suas rotas',
  ),
  onLoginSuccess: (result) {
    // salva sessao + navega
  },
)
```

## Decisoes arquiteturais importantes

- O pacote prioriza desacoplamento por contratos (ports), evitando dependencia de API/storage especificos.
- O bloc de login e stateful (mantem `_currentState`) para facilitar snapshot atual e sincronizacao de controllers.
- A comunicacao de estado/evento e baseada em stream bus tipado (`FancyMixin`), e nao em `flutter_bloc`.
- `MorphLoginPage` encapsula toda experiencia de login para acelerar reaproveitamento entre apps.

## Observacoes de manutencao

- `lib/src/modules/auth/presentation/screens/view.dart` e `lib/src/modules/auth/domain/domain.dart` estao presentes, mas atualmente vazios.
- Como a biblioteca usa asset interno (`assets/manto.jpg`), o pacote declara esse asset no `pubspec.yaml`.
- Se for evoluir para mais modulos (alem de auth), a estrutura atual de `architecture + modules + ports` ja suporta expansao sem acoplamento forte.
