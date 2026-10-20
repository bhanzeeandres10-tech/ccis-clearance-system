import 'dart:ui';

import 'package:flutter/material.dart';

import 'screens/app_shell.dart';
import 'screens/login_screen.dart';
import 'state/clearance_controller.dart';
import 'theme/ccis_theme.dart';

void main() {
  runApp(const CcisClearanceApp());
}

/// CCIS CLEARANCE runs as one responsive Flutter interface on the web and on
/// mobile. The controller is injectable so it can later be backed by real
/// authentication and CCIS records without changing presentation code.
class CcisClearanceApp extends StatefulWidget {
  const CcisClearanceApp({super.key, this.controller});

  final ClearanceController? controller;

  @override
  State<CcisClearanceApp> createState() => _CcisClearanceAppState();
}

class _CcisClearanceAppState extends State<CcisClearanceApp> {
  late final ClearanceController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? ClearanceController.demo();
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => MaterialApp(
        title: 'CCIS CLEARANCE',
        debugShowCheckedModeBanner: false,
        theme: CcisTheme.light(),
        darkTheme: CcisTheme.dark(),
        themeMode: _controller.themeMode,
        themeAnimationDuration: const Duration(milliseconds: 480),
        themeAnimationCurve: Curves.easeInOutCubicEmphasized,
        builder: (context, child) => ScrollConfiguration(
          behavior: const _CcisScrollBehavior(),
          child: child ?? const SizedBox.shrink(),
        ),
        // Keep the authenticated shell directly constrained by the route.
        // A root AnimatedSwitcher can receive loose web constraints while it
        // swaps the login form for the dashboard; that leaves a blank canvas
        // in release builds after a successful sign-in. Page-level motion is
        // retained inside each screen, where the constraints are stable.
        home: SizedBox.expand(
          child: _controller.isSignedIn
              ? CcisAppShell(
                  key: const ValueKey<String>('app-shell'),
                  controller: _controller,
                )
              : LoginScreen(
                  key: const ValueKey<String>('sign-in'),
                  controller: _controller,
                  onSignedIn: () => setState(() {}),
                ),
        ),
      ),
    );
  }
}

class _CcisScrollBehavior extends MaterialScrollBehavior {
  const _CcisScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
