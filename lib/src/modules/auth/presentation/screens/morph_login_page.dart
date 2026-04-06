import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:morphling/morphling.dart';
import 'package:morphling/src/components/layout/design_tokens.dart';
import 'package:morphling/src/modules/auth/presentation/bloc/login_bloc.dart';
import 'package:morphling/src/modules/auth/presentation/bloc/login_event.dart';
import 'package:morphling/src/modules/auth/presentation/bloc/login_state.dart';
import 'package:morphling/src/modules/auth/presentation/bloc/login_status.dart';
import 'package:morphling/src/modules/auth/domain/models/login_result.dart';
import 'package:morphling/src/modules/auth/presentation/ports/auth_ui_mapper.dart';
import 'package:morphling/src/modules/auth/presentation/screens/app_logo.dart';
import 'package:morphling/src/modules/auth/presentation/screens/login_field_labels.dart';

class AppSettings {
  final String appName;
  final String subName;
  final String label;

  const AppSettings({
    this.appName = 'Manto Sistemas',
    this.subName = '',
    this.label = 'Acesse sua conta!',
  });
}

class MorphLoginPage<
  TUser extends Object,
  TToken extends Object,
  TCompany extends Object
>
    extends StatefulWidget {
  const MorphLoginPage({
    required this.bloc,
    required this.mapper,
    required this.onLoginSuccess,
    required this.settings,
    super.key,
    this.labels = const LoginFieldLabels(),
    this.title = 'Manto Sistemas',
    this.subtitle = 'System',
    this.madeBy = 'Manto Sistemas',
    this.headerDescription = 'Acesse sua conta e continue suas vendas',
    this.loginCardTitle = 'Entrar',
    this.loginCardSubtitle = 'Preencha os dados para continuar',
    this.versionLabel,
    this.requestBiometricOnInit = true,
    this.loadingWidget,
    this.onHeaderTap,
    this.showDeveloperBadge = false,
    this.developerBadgeLabel = 'MODO DESENVOLVEDOR',
    this.headerLogo,
  });

  final MorphLoginBloc<TUser, TToken, TCompany> bloc;
  final AuthUiMapper<TToken, TCompany> mapper;
  final LoginFieldLabels labels;
  final AppSettings settings;

  final String title;
  final String subtitle;
  final String madeBy;
  final String headerDescription;
  final String loginCardTitle;
  final String loginCardSubtitle;
  final String? versionLabel;
  final String developerBadgeLabel;

  final Widget? loadingWidget;
  final VoidCallback? onHeaderTap;
  final bool showDeveloperBadge;
  final bool requestBiometricOnInit;

  final Widget? headerLogo;

  final void Function(LoginResult<TUser, TToken, TCompany> result)
  onLoginSuccess;

  @override
  State<MorphLoginPage<TUser, TToken, TCompany>> createState() =>
      _MorphLoginPageState<TUser, TToken, TCompany>();
}

class _MorphLoginPageState<
  TUser extends Object,
  TToken extends Object,
  TCompany extends Object
>
    extends State<MorphLoginPage<TUser, TToken, TCompany>> {
  final formKeyRegistrationNumber = GlobalKey<FormState>();
  final formKeyUser = GlobalKey<FormState>();
  final formKeyPassWord = GlobalKey<FormState>();

  late final TextEditingController registrationController;
  late final TextEditingController userController;
  late final TextEditingController passwordController;

  StreamSubscription<LoginState<TUser, TToken, TCompany>>? _subscription;
  bool _isLoadingDialogOpen = false;
  bool _isChangedUser = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.bloc.currentState;
    registrationController = TextEditingController(
      text: initial.registrationNumber,
    );
    userController = TextEditingController(text: initial.user);
    passwordController = TextEditingController(text: initial.password);

    widget.bloc.onInit();
    _subscription = widget.bloc.state.listen(_onStateChanged);

    widget.bloc.dispatchEvent(InitRequested<TToken, TCompany>());
    if (widget.requestBiometricOnInit) {
      widget.bloc.dispatchEvent(BiometricRequested<TToken, TCompany>());
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _closeLoadingDialog();
    registrationController.dispose();
    userController.dispose();
    passwordController.dispose();
    widget.bloc.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          const _LoginBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: StreamBuilder<LoginState<TUser, TToken, TCompany>>(
                  stream: widget.bloc.state,
                  initialData: widget.bloc.currentState,
                  builder: (context, snapshot) {
                    final state = snapshot.data ?? widget.bloc.currentState;

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        DesignTokens.sizeM,
                        DesignTokens.sizeM,
                        DesignTokens.sizeM,
                        DesignTokens.sizeXXM,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildBrandHeader(theme),
                          const SizedBox(height: DesignTokens.sizeM),
                          _buildLoginCard(theme, state),
                          const SizedBox(height: DesignTokens.sizeSM),
                          if (widget.versionLabel != null)
                            _buildVersionChip(theme),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandHeader(ThemeData theme) {
    return GestureDetector(
      onTap: () => widget.onHeaderTap?.call(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignTokens.sizeXM),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F62D8), Color(0xFF1495FF)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2B073577),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.sizeM),
          child: Column(
            children: [
              AppLogo(
                iconColor: Colors.white,
                titleColor: Colors.white,
                borderColor: Color(0x80FFFFFF),
                appName: widget.settings.appName,
                subName: widget.settings.subName,
              ),
              const SizedBox(height: DesignTokens.sizeSM),
              Text(
                widget.settings.label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: DesignTokens.sizeXS),
              Visibility(
                visible: widget.showDeveloperBadge,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.sizeXS,
                    vertical: DesignTokens.sizeXXS,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x1FFFFFFF),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0x59FFFFFF)),
                  ),
                  child: Text(
                    'MODO DESENVOLVEDOR',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(
    ThemeData theme,
    LoginState<TUser, TToken, TCompany> state,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(DesignTokens.sizeXM),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12062457),
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.sizeM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.loginCardTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: DesignTokens.sizeXXS),
            Text(
              widget.loginCardSubtitle,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: DesignTokens.sizeSM),
            Form(
              key: formKeyRegistrationNumber,
              child: MorphCustomTextFormField(
                leading: Icons.account_balance_outlined,
                labelText: widget.labels.registrationNumber,
                controller: registrationController,
                validator: _validateCnpj,
                inputFormatters: [CnpjInputFormatter()],
                keyboardType: TextInputType.number,
                suffixIcon: _registrationNumberFeedBack(state.status, theme),
                onChanged: (value) {
                  _onRegistrationChanged(value ?? '');
                  setState(() {});
                },
              ),
            ),
            Visibility(
              visible: state.tokens.length > 1,
              child: _buildTokenDropdown(theme, state),
            ),
            if (state.companies.length > 1)
              _buildBusinessDropdown(theme, state),
            const SizedBox(height: DesignTokens.sizeXXS),
            Form(
              key: formKeyUser,
              child: MorphCustomTextFormField(
                leading: Icons.person_outline,
                labelText: widget.labels.user,
                controller: userController,
                validator: _validateUsuario,
                onChanged: (value) {
                  setState(() => _isChangedUser = true);
                  widget.bloc.dispatchEvent(
                    UserChanged<TToken, TCompany>(value ?? ''),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Form(
                    key: formKeyPassWord,
                    child: MorphCustomTextFormField(
                      leading: Icons.lock_outline,
                      labelText: widget.labels.password,
                      controller: passwordController,
                      isLast: true,
                      obscureText: true,
                      validator: _validateSenha,
                      onChanged:
                          (value) => widget.bloc.dispatchEvent(
                            PasswordChanged<TToken, TCompany>(value ?? ''),
                          ),
                      onComplete: _onLogin,
                    ),
                  ),
                ),
                if (state.isUseBiometry && !_isChangedUser)
                  Padding(
                    padding: const EdgeInsets.only(left: DesignTokens.sizeXS),
                    child: Tooltip(
                      message: widget.labels.biometry,
                      child: Material(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            DesignTokens.sizeSM,
                          ),
                          side: BorderSide(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.16,
                            ),
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            DesignTokens.sizeSM,
                          ),
                          onTap:
                              () => widget.bloc.dispatchEvent(
                                BiometricRequested<TToken, TCompany>(),
                              ),
                          child: Padding(
                            padding: const EdgeInsets.all(DesignTokens.sizeXS),
                            child: Icon(
                              _biometricIcon,
                              size: DesignTokens.sizeXM,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: DesignTokens.sizeXXS),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.sizeXS,
                vertical: DesignTokens.sizeXXS,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DesignTokens.sizeSM),
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.55,
                ),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.save_outlined,
                    size: DesignTokens.sizeM,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: DesignTokens.sizeXS),
                  Expanded(
                    child: Text(
                      widget.labels.saveData,
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                  Switch.adaptive(
                    value: state.saveData,
                    onChanged:
                        (value) => widget.bloc.dispatchEvent(
                          SaveDataChanged<TToken, TCompany>(value),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.sizeM),
            _buildLoginButton(theme, state.status.isLoadingLogin),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenDropdown(
    ThemeData theme,
    LoginState<TUser, TToken, TCompany> state,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.sizeXXS),
      child: DropdownButtonFormField<TToken>(
        isDense: true,
        isExpanded: true,
        value: state.selectedToken,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.storage_outlined),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignTokens.sizeMD),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignTokens.sizeMD),
            borderSide: BorderSide(color: theme.colorScheme.error),
          ),
        ),
        items:
            state.tokens
                .map(
                  (token) => DropdownMenuItem<TToken>(
                    value: token,
                    child: Text(
                      widget.mapper.tokenLabel(token),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                )
                .toList(),
        onChanged: (value) {
          if (value != null) {
            widget.bloc.dispatchEvent(TokenChanged<TToken, TCompany>(value));
          }
        },
      ),
    );
  }

  Widget _buildBusinessDropdown(
    ThemeData theme,
    LoginState<TUser, TToken, TCompany> state,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.sizeXXS),
      child: DropdownButtonFormField<TCompany>(
        isDense: true,
        isExpanded: true,
        value: state.selectedCompany,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.business_outlined),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignTokens.sizeMD),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignTokens.sizeMD),
            borderSide: BorderSide(color: theme.colorScheme.error),
          ),
        ),
        items:
            state.companies
                .map(
                  (company) => DropdownMenuItem<TCompany>(
                    value: company,
                    child: Text(
                      widget.mapper.companyLabel(company),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                )
                .toList(),
        onChanged:
            (value) => widget.bloc.dispatchEvent(
              CompanyChanged<TToken, TCompany>(value),
            ),
      ),
    );
  }

  Widget _buildLoginButton(ThemeData theme, bool isSubmitting) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignTokens.sizeMD),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F62D8), Color(0xFF1495FF)],
        ),
      ),
      child: FilledButton(
        onPressed: _onLogin,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.sizeMD),
          ),
        ),
        child:
            isSubmitting
                ? const SizedBox(
                  width: DesignTokens.sizeMD,
                  height: DesignTokens.sizeMD,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: DesignTokens.sizeXXXS,
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.login_rounded, color: Colors.white),
                    const SizedBox(width: DesignTokens.sizeXS),
                    Text(
                      widget.labels.loginButton,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildVersionChip(ThemeData theme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.sizeXS,
          vertical: DesignTokens.sizeXXS,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: theme.colorScheme.surface.withValues(alpha: 0.8),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Text(widget.versionLabel!, style: theme.textTheme.labelSmall),
      ),
    );
  }

  void _onStateChanged(LoginState<TUser, TToken, TCompany> state) {
    _syncControllers(state);

    if (state.status.isLoadingRegistration) return;

    if (state.status.isLoadingLogin) {
      _openLoadingDialog();
    } else {
      _closeLoadingDialog();
    }

    if (state.status.isError && (state.errorMessage?.isNotEmpty ?? false)) {
      _showErrorDialog(state.errorMessage!);
      return;
    }

    if (state.status.isSuccess && state.result != null) {
      widget.onLoginSuccess(state.result!);
    }
  }

  void _syncControllers(LoginState<TUser, TToken, TCompany> state) {
    if (registrationController.text != state.registrationNumber) {
      registrationController.text = state.registrationNumber;
      registrationController.selection = TextSelection.collapsed(
        offset: registrationController.text.length,
      );
    }

    if (userController.text != state.user) {
      userController.text = state.user;
      userController.selection = TextSelection.collapsed(
        offset: userController.text.length,
      );
    }

    if (passwordController.text != state.password) {
      passwordController.text = state.password;
      passwordController.selection = TextSelection.collapsed(
        offset: passwordController.text.length,
      );
    }
  }

  void _openLoadingDialog() {
    if (_isLoadingDialogOpen || !mounted) return;
    _isLoadingDialogOpen = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) =>
              widget.loadingWidget ??
              const Center(child: CircularProgressIndicator.adaptive()),
    );
  }

  void _closeLoadingDialog() {
    if (!_isLoadingDialogOpen || !mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    _isLoadingDialogOpen = false;
  }

  Future<void> _showErrorDialog(String message) async {
    _closeLoadingDialog();
    if (!mounted) return;
    final normalizedMessage = message.replaceAll('Exception: ', '');

    await showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Aviso'),
            content: Text(normalizedMessage),
          ),
    );
    widget.bloc.dispatchEvent(ResetErrorRequested<TToken, TCompany>());
  }

  void _onRegistrationChanged(String value) {
    widget.bloc.dispatchEvent(
      RegistrationNumberChanged<TToken, TCompany>(value),
    );
  }

  Future<void> _onLogin() async {
    if (formKeyRegistrationNumber.currentState?.validate() == false) return;
    if (formKeyUser.currentState?.validate() == false) return;
    if (formKeyPassWord.currentState?.validate() == false) return;
    widget.bloc.dispatchEvent(
      UserChanged<TToken, TCompany>(userController.text),
    );
    widget.bloc.dispatchEvent(
      PasswordChanged<TToken, TCompany>(passwordController.text),
    );
    widget.bloc.dispatchEvent(SubmitRequested<TToken, TCompany>());
  }

  String? _validateCnpj(String text) {
    if (text.isEmpty) {
      return 'Informe seu CNPJ!';
    }
    if (text.length < 18) {
      return 'Informe um CNPJ valido!';
    }
    return null;
  }

  String? _validateUsuario(String text) {
    if (text.isEmpty) {
      return 'Informe seu usuario!';
    }
    return null;
  }

  String? _validateSenha(String text) {
    if (text.isEmpty) {
      return 'Informe sua senha!';
    }
    return null;
  }

  Widget _registrationNumberFeedBack(LoginStatus status, ThemeData theme) {
    if (status.isLoadingRegistration) {
      return const Padding(
        padding: EdgeInsets.all(DesignTokens.sizeS),
        child: SizedBox(
          height: DesignTokens.sizeS,
          width: DesignTokens.sizeS,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (status.isError) {
      return Padding(
        padding: const EdgeInsets.all(DesignTokens.sizeM),
        child: Material(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(DesignTokens.sizeXXM),
          child: const Icon(Icons.close, color: Colors.white),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  IconData get _biometricIcon => Icons.face_retouching_natural;
}

class MorphCustomTextFormField extends StatefulWidget {
  const MorphCustomTextFormField({
    super.key,
    this.initialValue,
    this.controller,
    this.formKey,
    this.keyboardType,
    this.style,
    this.labelText,
    this.labelStyle,
    this.hintStyle,
    this.hintText,
    this.validator,
    this.onChanged,
    this.onTapOutside,
    this.onComplete,
    this.inputFormatters,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines,
    this.leading,
    this.textAlign,
    this.textAlignVertical,
    this.focusNode,
    this.enable = true,
    this.isLast = false,
    this.obscureText = false,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.autoCorrect = false,
  });

  final String? initialValue;
  final TextEditingController? controller;
  final bool enable;
  final bool isLast;
  final bool obscureText;
  final bool autofocus;
  final GlobalKey<FormState>? formKey;
  final IconData? leading;
  final String? labelText;
  final String? hintText;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String)? validator;
  final void Function(String?)? onChanged;
  final void Function()? onTapOutside;
  final VoidCallback? onComplete;
  final TextAlign? textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final bool autoCorrect;

  @override
  State<MorphCustomTextFormField> createState() =>
      _MorphCustomTextFormFieldState();
}

class _MorphCustomTextFormFieldState extends State<MorphCustomTextFormField> {
  bool isTextObscured = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignTokens.sizeXXS),
      child: TextFormField(
        focusNode: widget.focusNode,
        textCapitalization: widget.textCapitalization,
        enabled: widget.enable,
        autofocus: widget.autofocus,
        initialValue: widget.initialValue,
        controller: widget.controller,
        maxLines: widget.maxLines ?? 1,
        maxLength: widget.maxLength,
        textAlign: widget.textAlign ?? TextAlign.start,
        textAlignVertical: widget.textAlignVertical,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        obscureText: widget.obscureText ? !isTextObscured : false,
        style: widget.style,
        autocorrect: widget.autoCorrect,
        decoration: InputDecoration(
          counterText: '',
          hintText: widget.hintText,
          hintStyle: widget.hintStyle,
          prefixIcon:
              widget.prefixIcon ??
              (widget.leading != null
                  ? Icon(widget.leading, size: DesignTokens.sizeXM)
                  : null),
          suffixIcon:
              widget.obscureText
                  ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.sizeXS,
                    ),
                    child: IconButton(
                      onPressed:
                          () =>
                              setState(() => isTextObscured = !isTextObscured),
                      icon: Icon(
                        isTextObscured
                            ? CupertinoIcons.eye
                            : CupertinoIcons.eye_slash,
                      ),
                    ),
                  )
                  : widget.suffixIcon,
          labelText: widget.labelText,
          labelStyle:
              widget.labelStyle ??
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.normal),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignTokens.sizeMD),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignTokens.sizeMD),
            borderSide: BorderSide(color: theme.colorScheme.error),
          ),
          isDense: true,
          filled: true,
          errorMaxLines: 3,
        ),
        validator:
            widget.validator != null
                ? (value) => widget.validator!(value ?? '')
                : null,
        onTapOutside: (_) {
          FocusScope.of(context).unfocus();
          widget.formKey?.currentState?.validate();
          widget.onTapOutside?.call();
        },
        onChanged: widget.onChanged,
        onFieldSubmitted: (_) {
          widget.formKey?.currentState?.validate();
          widget.onComplete?.call();
        },
        textInputAction:
            widget.isLast ? TextInputAction.go : TextInputAction.next,
      ),
    );
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                isLight
                    ? const [Color(0xFFF2F7FF), Color(0xFFFFFFFF)]
                    : const [Color(0xFF171616), Color(0xFF111111)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -70,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isLight
                          ? const Color(0x261495FF)
                          : const Color(0x140F62D8),
                ),
              ),
            ),
            Positioned(
              top: 120,
              left: -90,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isLight
                          ? const Color(0x1F0F62D8)
                          : const Color(0x140F62D8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
