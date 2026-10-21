import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/appearance_controllers.dart';
import '../domain/auth_state.dart';
import 'session_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _pinController = TextEditingController();
  bool _submitting = false;
  bool _obscurePin = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    try {
      final result = await ref.read(sessionControllerProvider.notifier).login(
            username: _usernameController.text,
            pin: _pinController.text,
          );
      if (!mounted) return;
      if (result is LoginSuccess) {
        if (result.mustChangePin) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.mustChangePin)),
          );
        }
        return;
      }
      final failure = result as LoginFailure;
      String message;
      switch (failure.error) {
        case LoginError.inactive:
          message = l10n.accountDisabled;
        case LoginError.locked:
          final minutes = ((failure.retryAfter?.inSeconds ?? 0) / 60).ceil();
          message = '${l10n.errorAuth} (${minutes}m)';
        case LoginError.invalidCredentials:
          message = l10n.invalidCredentials;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.storefront_rounded,
                    size: 72,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.appTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 28),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.username],
                          decoration: InputDecoration(
                            labelText: l10n.username,
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.usernameRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _pinController,
                          obscureText: _obscurePin,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          maxLength: AppConstants.pinMaxLength,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            labelText: l10n.pin,
                            prefixIcon: const Icon(Icons.lock_outline),
                            counterText: '',
                            suffixIcon: IconButton(
                              tooltip: l10n.pin,
                              icon: Icon(
                                _obscurePin
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePin = !_obscurePin),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.pinRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _submitting ? null : _submit,
                          child: _submitting
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                )
                              : Text(l10n.signIn),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _LocalePicker(),
                      _ThemePicker(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.appTagline,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LocalePicker extends ConsumerWidget {
  const _LocalePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = ref.watch(localeProvider);
    final code = current?.languageCode ?? 'en';

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: code,
        isDense: true,
        items: [
          DropdownMenuItem(value: 'en', child: Text(l10n.langEnglish)),
          DropdownMenuItem(value: 'ar', child: Text(l10n.langArabic)),
          DropdownMenuItem(value: 'ur', child: Text(l10n.langUrdu)),
        ],
        onChanged: (value) {
          if (value != null) {
            ref.read(localeProvider.notifier).set(Locale(value));
          }
        },
      ),
    );
  }
}

class _ThemePicker extends ConsumerWidget {
  const _ThemePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final mode = ref.watch(themeModeProvider);

    return DropdownButtonHideUnderline(
      child: DropdownButton<ThemeMode>(
        value: mode,
        isDense: true,
        items: [
          DropdownMenuItem(
            value: ThemeMode.system,
            child: Text(l10n.themeSystem),
          ),
          DropdownMenuItem(
            value: ThemeMode.light,
            child: Text(l10n.themeLight),
          ),
          DropdownMenuItem(value: ThemeMode.dark, child: Text(l10n.themeDark)),
        ],
        onChanged: (value) {
          if (value != null) {
            ref.read(themeModeProvider.notifier).set(value);
          }
        },
      ),
    );
  }
}
