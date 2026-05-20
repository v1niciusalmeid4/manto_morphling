import 'dart:async';

import 'package:morphling/morphling.dart';

class MorphLoginBloc<
  TUser extends Object,
  TToken extends Object,
  TCompany extends Object
>
    extends
        IBloC<
          LoginEvent<TToken, TCompany>,
          LoginState<TUser, TToken, TCompany>
        > {
  MorphLoginBloc({
    required AuthCatalogGateway<TToken, TCompany> catalogGateway,
    required AuthSessionGateway<TUser, TCompany> sessionGateway,
    required CredentialVault<TToken, TCompany> credentialVault,
    required NotificationTokenProvider notificationTokenProvider,
    required PasswordCipher passwordCipher,
    required BiometricGateway biometricGateway,
    AuthPolicy<TUser, TToken, TCompany>? policy,
    AuthPostLoginHook<TUser, TToken, TCompany>? postLoginHook,
    bool Function(TToken left, TToken right)? tokenMatcher,
    bool Function(TCompany left, TCompany right)? companyMatcher,
    super.initialState,
  }) : _catalogGateway = catalogGateway,
       _sessionGateway = sessionGateway,
       _credentialVault = credentialVault,
       _notificationTokenProvider = notificationTokenProvider,
       _passwordCipher = passwordCipher,
       _biometricGateway = biometricGateway,
       _policy = policy ?? NoopAuthPolicy<TUser, TToken, TCompany>(),
       _postLoginHook =
           postLoginHook ?? NoopAuthPostLoginHook<TUser, TToken, TCompany>(),
       _tokenMatcher = tokenMatcher,
       _companyMatcher = companyMatcher,
       _currentState =
           initialState ?? LoginState<TUser, TToken, TCompany>.initial();

  final AuthCatalogGateway<TToken, TCompany> _catalogGateway;
  final AuthSessionGateway<TUser, TCompany> _sessionGateway;
  final CredentialVault<TToken, TCompany> _credentialVault;
  final AuthPolicy<TUser, TToken, TCompany> _policy;
  final AuthPostLoginHook<TUser, TToken, TCompany> _postLoginHook;

  final NotificationTokenProvider _notificationTokenProvider;
  final BiometricGateway _biometricGateway;
  final PasswordCipher _passwordCipher;

  final bool Function(TToken left, TToken right)? _tokenMatcher;
  final bool Function(TCompany left, TCompany right)? _companyMatcher;

  bool _isBiometryInProgress = false;
  bool _isInitialized = false;

  LoginState<TUser, TToken, TCompany> _currentState;

  LoginState<TUser, TToken, TCompany> get currentState => _currentState;

  @override
  void onInit() {
    if (_isInitialized) return;

    _isInitialized = true;

    super.onInit();

    dispatchState(_currentState);
  }

  @override
  Future<void> handleEvent(LoginEvent<TToken, TCompany> event) async {
    if (event is InitRequested<TToken, TCompany>) {
      return await _init();
    } else if (event is RegistrationNumberChanged<TToken, TCompany>) {
      return await _onRegistrationNumberChanged(event.value);
    } else if (event is TokenChanged<TToken, TCompany>) {
      return await _onTokenChanged(event.token);
    } else if (event is CompanyChanged<TToken, TCompany>) {
      return _onCompanyChanged(event.company);
    } else if (event is UserChanged<TToken, TCompany>) {
      return _onUserChanged(event.user);
    } else if (event is PasswordChanged<TToken, TCompany>) {
      return _onPasswordChanged(event.password);
    } else if (event is SaveDataChanged<TToken, TCompany>) {
      return _onSaveDataChanged(event.value);
    } else if (event is BiometricRequested<TToken, TCompany>) {
      return await _tryBiometricLogin(event.reason);
    } else if (event is SubmitRequested<TToken, TCompany>) {
      return await _submit();
    } else if (event is ResetErrorRequested<TToken, TCompany>) {
      return _resetError();
    }
  }

  @override
  void dispatchState(LoginState<TUser, TToken, TCompany> state) {
    _currentState = state;
    super.dispatchState(state);
  }

  Future<void> _init() async {
    try {
      final saved = await _credentialVault.load();
      final canUseBiometry =
          await _credentialVault.isBiometryEnabled() &&
          await _biometricGateway.isAvailable();

      dispatchState(
        currentState.copyWith(
          registrationNumber: saved?.registrationNumber ?? '',
          user: saved?.user ?? '',
          saveData: saved?.saveData ?? false,
          isUseBiometry: canUseBiometry,
          status: LoginStatus.idle,
          errorMessage: null,
        ),
      );

      if ((saved?.registrationNumber.length ?? 0) == 18) {
        await _loadCatalog(
          saved!.registrationNumber,
          preferredToken: saved.selectedToken,
          preferredCompany: saved.selectedCompany,
        );
      }
    } catch (e) {
      dispatchState(
        currentState.copyWith(
          status: LoginStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onRegistrationNumberChanged(String value) async {
    dispatchState(
      currentState.copyWith(registrationNumber: value, errorMessage: null),
    );

    if (value.length == 18) {
      await _loadCatalog(value);
      return;
    }

    dispatchState(
      currentState.copyWith(
        tokens: const [],
        companies: const [],
        selectedToken: null,
        selectedCompany: null,
        authorization: '',
      ),
    );
  }

  Future<void> _loadCatalog(
    String registrationNumber, {
    TToken? preferredToken,
    TCompany? preferredCompany,
  }) async {
    try {
      dispatchState(
        currentState.copyWith(status: LoginStatus.loadingRegistration),
      );

      final tokens = await _catalogGateway.fetchTokens(registrationNumber);
      if (tokens.isEmpty) {
        throw Exception('Nenhum token encontrado para o CNPJ informado.');
      }

      final selectedToken = _resolveToken(tokens, preferredToken);
      final authorization = await _catalogGateway.fetchAuthorization(
        selectedToken,
      );

      final companies = await _catalogGateway.fetchCompanies(authorization);
      if (companies.isEmpty) {
        throw Exception('Nenhuma empresa encontrada para o token selecionado.');
      }

      final selectedCompany = _resolveCompany(companies, preferredCompany);

      dispatchState(
        currentState.copyWith(
          status: LoginStatus.idle,
          registrationNumber: registrationNumber,
          tokens: tokens,
          selectedToken: selectedToken,
          authorization: authorization,
          companies: companies,
          selectedCompany: selectedCompany,
          errorMessage: null,
        ),
      );
    } catch (e) {
      dispatchState(
        currentState.copyWith(
          status: LoginStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onTokenChanged(TToken token) async {
    try {
      dispatchState(
        currentState.copyWith(
          selectedToken: token,
          status: LoginStatus.loadingRegistration,
          errorMessage: null,
        ),
      );

      final authorization = await _catalogGateway.fetchAuthorization(token);
      final companies = await _catalogGateway.fetchCompanies(authorization);

      dispatchState(
        currentState.copyWith(
          status: LoginStatus.idle,
          authorization: authorization,
          companies: companies,
          selectedCompany: companies.isNotEmpty ? companies.first : null,
        ),
      );
    } catch (e) {
      dispatchState(
        currentState.copyWith(
          status: LoginStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onCompanyChanged(TCompany? company) {
    dispatchState(
      currentState.copyWith(selectedCompany: company, errorMessage: null),
    );
  }

  void _onUserChanged(String user) {
    dispatchState(currentState.copyWith(user: user, errorMessage: null));
  }

  void _onPasswordChanged(String password) {
    dispatchState(
      currentState.copyWith(password: password, errorMessage: null),
    );
  }

  void _onSaveDataChanged(bool value) {
    dispatchState(currentState.copyWith(saveData: value));
  }

  Future<void> _tryBiometricLogin(String reason) async {
    if (_isBiometryInProgress || !currentState.isUseBiometry) return;

    _isBiometryInProgress = true;

    try {
      final didAuthenticate = await _biometricGateway.authenticate(
        reason: reason,
      );

      if (!didAuthenticate) return;

      final encrypted = await _credentialVault.readEncryptedPassword();
      if (encrypted == null || encrypted.isEmpty) {
        throw Exception('Senha salva nao encontrada para login com biometria.');
      }

      final password = _passwordCipher.decrypt(encrypted);
      dispatchState(currentState.copyWith(password: password));
      await _submit();
    } catch (e) {
      dispatchState(
        currentState.copyWith(
          status: LoginStatus.error,
          errorMessage: 'Falha ao autenticar com biometria',
        ),
      );
    } finally {
      _isBiometryInProgress = false;
    }
  }

  Future<void> _submit() async {
    if (!currentState.canSubmit) {
      dispatchState(
        currentState.copyWith(
          status: LoginStatus.error,
          errorMessage: 'Preencha os campos obrigatorios antes de continuar.',
        ),
      );
      return;
    }

    try {
      dispatchState(
        currentState.copyWith(
          status: LoginStatus.loadingLogin,
          errorMessage: null,
        ),
      );

      final request = LoginRequest<TCompany>(
        registrationNumber: currentState.registrationNumber,
        user: currentState.user,
        password: currentState.password,
        company: currentState.selectedCompany!,
        notificationToken:
            await _notificationTokenProvider.getNotificationToken(),
        authorization: currentState.authorization,
      );

      await _policy.beforeLogin(request);
      final loggedUser = await _sessionGateway.login(request);

      final result = LoginResult<TUser, TToken, TCompany>(
        user: loggedUser,
        token: currentState.selectedToken!,
        company: currentState.selectedCompany!,
        registrationNumber: currentState.registrationNumber,
        authorization: currentState.authorization,
      );

      await _policy.afterLogin(result);

      if (currentState.saveData) {
        await _credentialVault.save(
          SavedLogin<TToken, TCompany>(
            registrationNumber: currentState.registrationNumber,
            user: currentState.user,
            saveData: true,
            selectedToken: currentState.selectedToken,
            selectedCompany: currentState.selectedCompany,
            encryptedPassword: _passwordCipher.encrypt(currentState.password),
          ),
        );
      } else {
        await _credentialVault.clear();
      }

      await _postLoginHook.execute(result);

      dispatchState(
        currentState.copyWith(
          status: LoginStatus.success,
          result: result,
          errorMessage: null,
        ),
      );
    } catch (e) {
      dispatchState(
        currentState.copyWith(
          status: LoginStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _resetError() {
    dispatchState(
      currentState.copyWith(status: LoginStatus.idle, errorMessage: null),
    );
  }

  TToken _resolveToken(List<TToken> items, TToken? preferred) {
    if (preferred == null) return items.first;

    return items.firstWhere(
      (item) => _tokenEquals(item, preferred),
      orElse: () => items.first,
    );
  }

  TCompany _resolveCompany(List<TCompany> items, TCompany? preferred) {
    if (preferred == null) return items.first;

    return items.firstWhere(
      (item) => _companyEquals(item, preferred),
      orElse: () => items.first,
    );
  }

  bool _tokenEquals(TToken left, TToken right) {
    if (_tokenMatcher != null) {
      return _tokenMatcher(left, right);
    }

    return left == right;
  }

  bool _companyEquals(TCompany left, TCompany right) {
    if (_companyMatcher != null) {
      return _companyMatcher(left, right);
    }

    return left == right;
  }
}
