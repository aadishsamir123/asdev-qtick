import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'dart:async';

class BatteryWidget extends StatefulWidget {
  const BatteryWidget({super.key});

  @override
  State<BatteryWidget> createState() => _BatteryWidgetState();
}

class _BatteryWidgetState extends State<BatteryWidget>
    with SingleTickerProviderStateMixin {
  final Battery _battery = Battery();
  int _batteryLevel = 0;
  BatteryState? _batteryState;
  StreamSubscription<BatteryState>? _batteryStateSubscription;
  Timer? _batteryLevelTimer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Initialize battery info following the example pattern
    _battery.batteryState.then(_updateBatteryState);
    _battery.batteryLevel.then(_updateBatteryLevel);

    // Set up listeners
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen(
      _updateBatteryState,
    );

    // Update battery level periodically
    _batteryLevelTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _battery.batteryLevel.then(_updateBatteryLevel);
      }
    });
  }

  void _updateBatteryState(BatteryState state) {
    if (_batteryState == state) return;
    setState(() {
      _batteryState = state;
    });

    // Start/stop animation based on charging state
    if (state == BatteryState.charging) {
      _animationController.repeat(reverse: true);
    } else {
      _animationController.stop();
      _animationController.reset();
    }
  }

  void _updateBatteryLevel(int level) {
    if (_batteryLevel == level) return;
    setState(() {
      _batteryLevel = level;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (_batteryStateSubscription != null) {
      _batteryStateSubscription!.cancel();
    }
    _batteryLevelTimer?.cancel();
    super.dispose();
  }

  IconData _getBatteryIcon() {
    bool isCharging = _batteryState == BatteryState.charging;

    if (isCharging) {
      return Icons.battery_charging_full;
    }

    if (_batteryLevel >= 90) return Icons.battery_full;
    if (_batteryLevel >= 60) return Icons.battery_5_bar;
    if (_batteryLevel >= 40) return Icons.battery_4_bar;
    if (_batteryLevel >= 20) return Icons.battery_3_bar;
    if (_batteryLevel >= 10) return Icons.battery_2_bar;
    return Icons.battery_1_bar;
  }

  Color _getBatteryColor() {
    bool isCharging = _batteryState == BatteryState.charging;

    if (isCharging) {
      return Colors.green;
    }

    if (_batteryLevel <= 20) return Colors.red;
    if (_batteryLevel <= 40) return Colors.orange;
    return Colors.grey[600]!;
  }

  @override
  Widget build(BuildContext context) {
    bool isCharging = _batteryState == BatteryState.charging;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: isCharging ? _fadeAnimation.value : 1.0,
                child: Icon(
                  _getBatteryIcon(),
                  color: _getBatteryColor(),
                  size: 20,
                ),
              );
            },
          ),
          const SizedBox(width: 4),
          Text(
            '$_batteryLevel%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _getBatteryColor(),
            ),
          ),
        ],
      ),
    );
  }
}
