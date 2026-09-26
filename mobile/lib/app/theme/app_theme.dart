import 'package:flutter/material.dart';

// ───────────────────────────────────────────────────────────────────────────
// APP THEME & DESIGN SYSTEM
// ───────────────────────────────────────────────────────────────────────────
class AppColors {
  static const clay = Color(0xFFEBE8DF);
  static const clayDark = Color(0xFFDAD5CB);
  static const clayLight = Color(0xFFF6F4EE);
  static const bg = Color(0xFFE9E6E0);
  static const surface = Color.fromARGB(255, 255, 255, 255);
  static const navy = Color(0xFF1B2130);
  static const label = Color(0xFF8A8F9C);
  static const subtitle = Color(0xFF6B7385);
  static const grey = Color(0xFF6B7385);
  static const orange = Color(0xFFFF6A00);
  static const green = Color(0xFF1E9E6A);
  static const navBar = Color(0xFF1C2331);
  static const navIcon = Color(0xFF8B93A7);
  static const teal = Color(0xFF3D8D8A);

  // Dark hero card
  static const heroDarkTop = Color(0xFF3A2418);
  static const heroDarkBottom = Color(0xFF201410);
  static const heroDarkTile = Color(0x1AFFFFFF);
}

/// Soft-UI (neumorphic) double shadow: light top-left, dark bottom-right.
List<BoxShadow> neuShadows({double d = 6, double blur = 12}) => [
  BoxShadow(
    color: const Color(0xCCFFFFFF),
    offset: Offset(-d, -d),
    blurRadius: blur,
  ),
  BoxShadow(
    color: const Color(0xB3C8C3BA),
    offset: Offset(d, d),
    blurRadius: blur,
  ),
];

class SectionEyebrow extends StatelessWidget {
  final String text;
  const SectionEyebrow({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
        color: AppColors.label,
      ),
    );
  }
}

class FloatingNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const FloatingNavBar({super.key, required this.index, required this.onTap});

  static const _icons = <IconData>[
    Icons.explore_outlined, // compass
    Icons.qr_code_scanner, // QR / scan
    Icons.navigation_outlined, // navigation arrow
    Icons.build_outlined, // wrench
    Icons.tune, // sliders
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.navBar,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            offset: Offset(0, 10),
            blurRadius: 24,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 0; i < _icons.length; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == index ? AppColors.orange : Colors.transparent,
                  boxShadow: i == index
                      ? const [
                          BoxShadow(
                            color: Color(0x66FF6A00),
                            offset: Offset(0, 4),
                            blurRadius: 16,
                          ),
                        ]
                      : const [],
                ),
                child: Icon(
                  _icons[i],
                  size: 22,
                  color: i == index ? Colors.white : AppColors.navIcon,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// SKEUOMORPHIC 3D COMPONENTS
// ───────────────────────────────────────────────────────────────────────────

/// Convex 3D tactile container with dual soft-UI drop shadows and bevel edge.
class SkeuomorphicContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;
  final VoidCallback? onTap;

  const SkeuomorphicContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? AppColors.clay;
    Widget container = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.7),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xCCFFFFFF),
            offset: Offset(-4, -4),
            blurRadius: 9,
          ),
          BoxShadow(
            color: Color(0x389E9689),
            offset: Offset(5, 5),
            blurRadius: 11,
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: container,
      );
    }
    return container;
  }
}

/// Concave debossed/sunken container with inner shadow effect.
class SkeuomorphicInsetContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;
  final VoidCallback? onTap;

  const SkeuomorphicInsetContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? const Color(0xFFE2DDD2);
    Widget container = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: const Color(0xFFD2CDC0),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x28000000),
            offset: Offset(2, 2),
            blurRadius: 4,
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Color(0xE6FFFFFF),
            offset: Offset(-2, -2),
            blurRadius: 4,
            spreadRadius: -1,
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: container,
      );
    }
    return container;
  }
}

/// Tactile 3D orange action button with subtle highlight and warm drop shadow.
class SkeuomorphicOrangeButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isLoading;

  const SkeuomorphicOrangeButton({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF7A1A), Color(0xFFEE5E00)],
          ),
          border: Border.all(
            color: const Color(0xFFFFB17A),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66FF6A00),
              offset: Offset(0, 6),
              blurRadius: 16,
            ),
            BoxShadow(
              color: Color(0x2E000000),
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              else ...[
                if (icon != null) ...[
                  Icon(icon, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

