import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/security_service.dart';
import '../settings/app_settings.dart';
import '../theme/app_icons.dart';
import '../widgets/brand.dart';
import '../widgets/common.dart';

/// Gates a module's screen behind biometrics or the device PIN while the
/// module appears in `settings.lockedModules`. The gate re-arms every time
/// the route is entered and whenever the app returns from the background.
class ModuleLockGate extends ConsumerStatefulWidget {
  final AppModule module;
  final Widget child;

  const ModuleLockGate({super.key, required this.module, required this.child});

  @override
  ConsumerState<ModuleLockGate> createState() => _ModuleLockGateState();
}

class _ModuleLockGateState extends ConsumerState<ModuleLockGate>
    with WidgetsBindingObserver {
  bool _unlocked = false;
  bool _prompting = false;
  bool _backgrounded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _evaluate());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _backgrounded = true;
      return;
    }
    if (state == AppLifecycleState.resumed && _backgrounded) {
      _backgrounded = false;
      if (_isLocked) {
        setState(() => _unlocked = false);
        _evaluate();
      }
    }
  }

  bool get _isLocked =>
      ref.read(settingsProvider).lockedModules.contains(widget.module);

  Future<void> _evaluate() async {
    if (_unlocked || _prompting) return;
    if (!_isLocked) {
      if (mounted) setState(() => _unlocked = true);
      return;
    }

    _prompting = true;
    final ok = await ref
        .read(securityServiceProvider)
        .authenticate(reason: 'Unlock ${widget.module.label}');
    _prompting = false;
    if (!mounted) return;
    if (ok) {
      setState(() => _unlocked = true);
    } else {
      await _unlockWithPin();
    }
  }

  Future<void> _unlockWithPin() async {
    final security = ref.read(securityServiceProvider);
    if (!security.hasPin) {
      brandToast(context, 'No PIN is set on this device.');
      return;
    }

    final ok = await promptForPin(
      context,
      security.verifyPin,
      title: 'Unlock ${widget.module.label}',
    );
    if (ok && mounted) setState(() => _unlocked = true);
  }

  @override
  Widget build(BuildContext context) {
    final locked = ref
        .watch(settingsProvider)
        .lockedModules
        .contains(widget.module);
    if (!locked || _unlocked) return widget.child;

    return BrandScaffold(
      header: BrandTopBar(
        title: widget.module.label,
        leadingIcon: AppIcons.back,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppIcon(AppIcons.lock, size: 56),
              const SizedBox(height: 20),
              Text(
                '${widget.module.label} is locked',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Authenticate to continue.',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
              const SizedBox(height: 28),
              BrandButton(
                label: 'Unlock',
                icon: AppIcons.biometric,
                expand: false,
                onPressed: _evaluate,
              ),
              const SizedBox(height: 8),
              BrandButton(
                label: 'Use PIN instead',
                kind: BrandButtonKind.ghost,
                expand: false,
                onPressed: _unlockWithPin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
