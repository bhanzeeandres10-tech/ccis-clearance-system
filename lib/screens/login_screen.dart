import 'package:flutter/material.dart';

import '../models/clearance_models.dart';
import '../state/clearance_controller.dart';
import '../theme/ccis_theme.dart';

/// The first screen for both student and authorized CCIS personnel access.
///
/// It deliberately stays independent of routing so the app shell can decide
/// where to send a successfully signed-in user.
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.controller,
    required this.onSignedIn,
  });

  final ClearanceController controller;
  final VoidCallback onSignedIn;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _role = UserRole.student;
  bool _obscurePassword = true;
  String? _signInError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _selectRole(UserRole role) {
    if (_role == role) return;
    setState(() {
      _role = role;
      _signInError = null;
    });
  }

  void _submit() {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid) {
      setState(() {
        _signInError = 'Enter both your username and password.';
      });
      return;
    }

    final signedIn = widget.controller.signIn(
      role: _role,
      username: _usernameController.text,
      password: _passwordController.text,
    );

    if (!signedIn) {
      setState(() {
        _signInError = widget.controller.lastSignInError;
      });
      return;
    }

    widget.onSignedIn();
  }

  String? _requiredValue(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          body: SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final isWide = constraints.maxWidth >= 960;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: isWide
                      ? _DesktopLogin(
                          key: const ValueKey<String>('desktop-login'),
                          brandPanel: _BrandPanel(
                            isWide: true,
                            role: _role,
                          ),
                          formCard: _LoginCard(
                            role: _role,
                            usernameController: _usernameController,
                            passwordController: _passwordController,
                            formKey: _formKey,
                            signInError: _signInError,
                            obscurePassword: _obscurePassword,
                            onRoleChanged: _selectRole,
                            onPasswordVisibilityChanged: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            onFieldChanged: () {
                              if (_signInError != null) {
                                setState(() => _signInError = null);
                              }
                            },
                            onSubmit: _submit,
                            requiredValue: _requiredValue,
                            controller: widget.controller,
                          ),
                        )
                      : _MobileLogin(
                          key: const ValueKey<String>('mobile-login'),
                          brandPanel: _BrandPanel(
                            isWide: false,
                            role: _role,
                          ),
                          formCard: _LoginCard(
                            role: _role,
                            usernameController: _usernameController,
                            passwordController: _passwordController,
                            formKey: _formKey,
                            signInError: _signInError,
                            obscurePassword: _obscurePassword,
                            onRoleChanged: _selectRole,
                            onPasswordVisibilityChanged: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            onFieldChanged: () {
                              if (_signInError != null) {
                                setState(() => _signInError = null);
                              }
                            },
                            onSubmit: _submit,
                            requiredValue: _requiredValue,
                            controller: widget.controller,
                          ),
                        ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _DesktopLogin extends StatelessWidget {
  const _DesktopLogin({
    super.key,
    required this.brandPanel,
    required this.formCard,
  });

  final Widget brandPanel;
  final Widget formCard;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(flex: 10, child: brandPanel),
        Expanded(
          flex: 11,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 470),
                child: formCard,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MobileLogin extends StatelessWidget {
  const _MobileLogin({
    super.key,
    required this.brandPanel,
    required this.formCard,
  });

  final Widget brandPanel;
  final Widget formCard;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              brandPanel,
              const SizedBox(height: 26),
              formCard,
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({
    required this.isWide,
    required this.role,
  });

  final bool isWide;
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    if (!isWide) {
      return Row(
        children: <Widget>[
          const _BrandMark(size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  'CCIS CLEARANCE',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                SizedBox(height: 2),
                Text(
                  'RMMC-MI · CCIS student services',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 64),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[CcisTheme.navy, Color(0xFF092741)],
        ),
      ),
      child: Stack(
        children: <Widget>[
          const Positioned(
            right: -120,
            top: -80,
            child: _GlowOrb(diameter: 330, opacity: 0.12),
          ),
          const Positioned(
            left: -100,
            bottom: -150,
            child: _GlowOrb(diameter: 310, opacity: 0.10),
          ),
          Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 470),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Row(
                    children: <Widget>[
                      _BrandMark(size: 58, reverse: true),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'CCIS CLEARANCE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'RMMC-MI · CCIS student services',
                            style: TextStyle(
                              color: Color(0xFFD8E8FA),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 72),
                  Text(
                    switch (role) {
                      UserRole.student => 'Your clearance,\nmade clearer.',
                      UserRole.personnel =>
                        'A clearer view\nfor CCIS personnel.',
                      UserRole.admin => 'Manage access\nand activity.',
                    },
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      height: 1.06,
                      letterSpacing: -1.2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Track event attendance, resolve CCIS requirements, and receive timely updates in one protected place.',
                    style: TextStyle(
                      color: Color(0xFFD8E8FA),
                      fontSize: 16,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 34),
                  const _BenefitRow(
                    icon: Icons.calendar_month_outlined,
                    label: 'Track every required event day',
                  ),
                  const SizedBox(height: 14),
                  const _BenefitRow(
                    icon: Icons.verified_user_outlined,
                    label: 'Review verification and clearance progress',
                  ),
                  const SizedBox(height: 14),
                  const _BenefitRow(
                    icon: Icons.notifications_none_rounded,
                    label: 'Receive protected status updates',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.diameter, required this.opacity});

  final double diameter;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white.withValues(alpha: 0.14),
          ),
          child: Icon(icon, color: Colors.white, size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.size, this.reverse = false});

  final double size;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    final fill =
        reverse ? Colors.white.withValues(alpha: 0.15) : CcisTheme.navy;
    final foreground = reverse ? Colors.white : Colors.white;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: reverse
              ? Colors.white.withValues(alpha: 0.34)
              : const Color(0xFF6684A4),
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.school_rounded,
        color: foreground,
        size: size * 0.52,
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.role,
    required this.usernameController,
    required this.passwordController,
    required this.formKey,
    required this.signInError,
    required this.obscurePassword,
    required this.onRoleChanged,
    required this.onPasswordVisibilityChanged,
    required this.onFieldChanged,
    required this.onSubmit,
    required this.requiredValue,
    required this.controller,
  });

  final UserRole role;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;
  final String? signInError;
  final bool obscurePassword;
  final ValueChanged<UserRole> onRoleChanged;
  final VoidCallback onPasswordVisibilityChanged;
  final VoidCallback onFieldChanged;
  final VoidCallback onSubmit;
  final String? Function(String? value, String label) requiredValue;
  final ClearanceController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF121E2B) : Colors.white;
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.12)
        : CcisTheme.navy.withValues(alpha: 0.10);

    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: shadowColor,
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Welcome back',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Sign in to access your CCIS clearance.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: isDark ? 'Use light mode' : 'Use dark mode',
                    onPressed: () => controller.setThemeMode(
                      isDark ? ThemeMode.light : ThemeMode.dark,
                    ),
                    icon: Icon(
                      isDark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'CONTINUE AS',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 0.9,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 9),
              _RoleSelector(role: role, onChanged: onRoleChanged),
              const SizedBox(height: 24),
              Text(
                'Username',
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: usernameController,
                onChanged: (_) => onFieldChanged(),
                autofillHints: const <String>[AutofillHints.username],
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (String? value) => requiredValue(value, 'Username'),
                decoration: const InputDecoration(
                  hintText: 'Enter your username',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Password',
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: passwordController,
                onChanged: (_) => onFieldChanged(),
                autofillHints: const <String>[AutofillHints.password],
                obscureText: obscurePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => onSubmit(),
                validator: (String? value) => requiredValue(value, 'Password'),
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip:
                        obscurePassword ? 'Show password' : 'Hide password',
                    onPressed: onPasswordVisibilityChanged,
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Please contact authorized CCIS personnel for account help.'),
                      ),
                    );
                  },
                  child: const Text('Need account help?'),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child: signInError == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _SignInError(message: signInError!),
                      ),
              ),
              FilledButton.icon(
                onPressed: onSubmit,
                icon: Icon(
                  switch (role) {
                    UserRole.student => Icons.login_rounded,
                    UserRole.personnel => Icons.verified_user_outlined,
                    UserRole.admin => Icons.admin_panel_settings_outlined,
                  },
                ),
                label: Text('Sign in as ${role.label}'),
              ),
              const SizedBox(height: 17),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B2C40) : CcisTheme.paleBlue,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.info_outline_rounded,
                      color: theme.colorScheme.primary,
                      size: 19,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Demo access: choose a role, then enter any username and password.',
                        style:
                            theme.textTheme.bodySmall?.copyWith(height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'CCIS records are protected. Use only your assigned account.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      theme.textTheme.bodySmall?.color?.withValues(alpha: 0.76),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({required this.role, required this.onChanged});

  final UserRole role;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF192535)
            : const Color(0xFFF0F4F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _RoleSegment(
              role: UserRole.admin,
              selected: role == UserRole.admin,
              onPressed: () => onChanged(UserRole.admin),
            ),
          ),
          Expanded(
            child: _RoleSegment(
              role: UserRole.personnel,
              selected: role == UserRole.personnel,
              onPressed: () => onChanged(UserRole.personnel),
            ),
          ),
          Expanded(
            child: _RoleSegment(
              role: UserRole.student,
              selected: role == UserRole.student,
              onPressed: () => onChanged(UserRole.student),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleSegment extends StatelessWidget {
  const _RoleSegment({
    required this.role,
    required this.selected,
    required this.onPressed,
  });

  final UserRole role;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = selected
        ? theme.colorScheme.onPrimary
        : theme.textTheme.bodyMedium?.color;
    final icon = switch (role) {
      UserRole.student => Icons.school_outlined,
      UserRole.personnel => Icons.verified_user_outlined,
      UserRole.admin => Icons.admin_panel_settings_outlined,
    };

    return Semantics(
      button: true,
      selected: selected,
      label: 'Continue as ${role.label}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
            decoration: BoxDecoration(
              color: selected ? theme.colorScheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: selected
                  ? <BoxShadow>[
                      BoxShadow(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.22),
                        blurRadius: 9,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, color: foreground, size: 17),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    role.shortLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignInError extends StatelessWidget {
  const _SignInError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.error_outline_rounded,
            color: theme.colorScheme.error,
            size: 19,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
