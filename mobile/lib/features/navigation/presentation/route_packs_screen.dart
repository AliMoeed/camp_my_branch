// ═══════════════════════════════════════════════════════════════════════════
// CAMP — Route Packs screen
// ═══════════════════════════════════════════════════════════════════════════
//
//

//
// Per your instruction: uses the SAME back button and SAME "CAMP" logo
// style as Ride History (not the hamburger menu from the screenshot), and
// the SAME floating nav bar — with the navigation-arrow tab active here.
//
// Layout:
//   1. Header: back button, CAMP logo, "GPS LIVE" pill
//   2. "Telemetry Hub" label + "Route Packs" title + "Topo V4.8" pill
//   3. Storage Allocation card (segmented bar + legend + Wi-Fi toggle)
//   4. "Offline Telemetry & Topo Packs" section header + "5 Regions Available"
//   5. Pack cards: saved / downloading / available-to-download states
//   6. Floating nav bar
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

void main() => runApp(const CampApp());

// ───────────────────────────────────────────────────────────────────────────
// 1. THEME
// ───────────────────────────────────────────────────────────────────────────
class AppColors {
  static const bg = Color(0xFFEFECE6);
  static const surface = Color.fromARGB(255, 255, 255, 255);
  static const navy = Color(0xFF1B2130);
  static const label = Color(0xFF8A8F9C);
  static const subtitle = Color(0xFF6B7385);
  static const grey = Color(0xFF6B7385);
  static const orange = Color(0xFFFF6A00);
  static const green = Color(0xFF1E9E6A);
  static const navBar = Color(0xFF1C2331);
  static const navIcon = Color(0xFF8B93A7);
  static const teal = Color(0xFF3D8D8A); // description text in pack cards
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

class CampApp extends StatelessWidget {
  const CampApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CAMP',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.orange),
      ),
      home: const RoutePacksScreen(),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// 2. MODELS
// ───────────────────────────────────────────────────────────────────────────
enum PackStatus { saved, downloading, available }

class RoutePack {
  final String title;
  final String sizeLabel; // e.g. "840 MB"
  final String typeLabel; // e.g. "Full Topo & Satellite"
  final String description;
  final PackStatus status;

  // saved-only
  final String? updateNote; // e.g. "Pack update available (42 MB)"

  // downloading-only
  final double? progress; // 0.0–1.0
  final String? progressLabel; // "312 MB of 460 MB"
  final String? speedLabel; // "4.2 MB/s"

  // available-only
  final IconData? noteIcon;
  final String? note; // e.g. "Zero-cell desert sector"
  final String? downloadLabel; // e.g. "Download Pack (380 MB)"

  const RoutePack({
    required this.title,
    required this.sizeLabel,
    required this.typeLabel,
    required this.description,
    required this.status,
    this.updateNote,
    this.progress,
    this.progressLabel,
    this.speedLabel,
    this.noteIcon,
    this.note,
    this.downloadLabel,
  });
}

/// One segment of the storage allocation bar / legend, e.g. "Routes (2.2 GB)".
class StorageSegment {
  final String label;
  final String sizeLabel; // e.g. "2.2 GB"
  final double fraction; // 0.0–1.0 share of the total bar
  final Color color;

  const StorageSegment({
    required this.label,
    required this.sizeLabel,
    required this.fraction,
    required this.color,
  });
}

// ───────────────────────────────────────────────────────────────────────────
// 3. SCREEN
// ───────────────────────────────────────────────────────────────────────────
class RoutePacksScreen extends StatefulWidget {
  const RoutePacksScreen({super.key});

  @override
  State<RoutePacksScreen> createState() => _RoutePacksScreenState();
}

class _RoutePacksScreenState extends State<RoutePacksScreen> {
  int _tab = 2; // navigation-arrow tab active on this screen
  bool _autoUpdate = true;

  final List<StorageSegment> _storage = const [
    StorageSegment(
      label: 'Routes',
      sizeLabel: '2.2 GB',
      fraction: 0.2,
      color: AppColors.orange,
    ),
    StorageSegment(
      label: 'Topo Base',
      sizeLabel: '1.2 GB',
      fraction: 0.1,
      color: AppColors.navy,
    ),
    StorageSegment(
      label: 'Free',
      sizeLabel: '28.6 GB',
      fraction: 0.7,
      color: Color(0xFFD8D4CB),
    ),
  ];

  final List<RoutePack> _packs = const [
    RoutePack(
      title: 'Karakoram Highway (KKH)',
      sizeLabel: '840 MB',
      typeLabel: 'Full Topo & Satellite',
      description:
          'Hasan Abdal to Khunjerab Pass (Elev. 4,693m). Complete trail grade '
          'telemetry, mountain fuel stops & emergency waypoints.',
      status: PackStatus.saved,
      updateNote: 'Pack update available (42 MB)',
    ),
    RoutePack(
      title: 'Babusar Pass & Kaghan',
      sizeLabel: '460 MB',
      typeLabel: 'Alpine Passes',
      description:
          'High-altitude pass data (4,173m), hairpin telemetry, seasonal snow '
          'closures & elevation oxygen compensation guidelines.',
      status: PackStatus.downloading,
      progress: 312 / 460,
      progressLabel: '312 MB of 460 MB',
      speedLabel: '4.2 MB/s',
    ),
    RoutePack(
      title: 'Makran Coastal Highway',
      sizeLabel: '380 MB',
      typeLabel: 'Desert & Coastal Trail',
      description:
          'Arabian Sea coastal route, Hingol National Park off-road tracks, '
          'sand wind hazard alerts & isolated fuel caches.',
      status: PackStatus.available,
      noteIcon: Icons.warning_amber_rounded,
      note: 'Zero-cell desert sector',
      downloadLabel: 'Download Pack (380 MB)',
    ),
    RoutePack(
      title: 'Cholistan Desert Rally Route',
      sizeLabel: '520 MB',
      typeLabel: 'Deep Sand & Navigational Grid',
      description:
          'Derawar Fort perimeter, dune waypoints, extreme heat advisories & '
          'off-grid satellite beacon checkpoints.',
      status: PackStatus.available,
      noteIcon: Icons.bolt,
      note: 'GPS Mesh verified',
      downloadLabel: 'Download Pack (520 MB)',
    ),
    RoutePack(
      title: 'Deosai Plains Plateau',
      sizeLabel: '290 MB',
      typeLabel: 'High Altitude Wilderness',
      description:
          'Second highest plateau on earth (4,114m). Stream crossings, '
          'wildlife tracking & zero-cell offline emergency mesh.',
      status: PackStatus.available,
      noteIcon: Icons.terrain,
      note: 'Contour 10m res',
      downloadLabel: 'Download Pack (290 MB)',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 110 + bottomInset),
              children: [
                // Same header style as Ride History: back button + CAMP logo,
                // with a "GPS LIVE" pill on the right instead of "LOGS".
                TopHeader(
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: neuShadows(d: 3, blur: 6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 8, color: AppColors.green),
                        SizedBox(width: 6),
                        Text(
                          'GPS LIVE',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: AppColors.navy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const SectionEyebrow(text: 'TELEMETRY HUB'),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Text(
                        'Route Packs',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sync, size: 13, color: AppColors.orange),
                          SizedBox(width: 4),
                          Text(
                            'Topo V4.8',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                StorageAllocationCard(
                  usedLabel: '3.4 GB',
                  totalLabel: 'used of 32 GB Free',
                  segments: _storage,
                  autoUpdate: _autoUpdate,
                  onAutoUpdateChanged: (v) => setState(() => _autoUpdate = v),
                ),
                const SizedBox(height: 20),

                Row(
                  children: const [
                    SectionEyebrow(text: 'OFFLINE TELEMETRY & TOPO PACKS'),
                    Spacer(),
                    Text(
                      '5 Regions Available',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                for (final pack in _packs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: PackCard(pack: pack),
                  ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16 + bottomInset,
            child: FloatingNavBar(
              index: _tab,
              onTap: (i) => setState(() => _tab = i),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// 4. HEADER (same style as Ride History's TopHeader, with a swappable
//    trailing widget so this screen can show "GPS LIVE" instead of "LOGS")
// ───────────────────────────────────────────────────────────────────────────
class TopHeader extends StatelessWidget {
  final Widget trailing;
  const TopHeader({super.key, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
            // TODO: decide behavior once more screens exist
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: neuShadows(d: 3, blur: 6),
            ),
            child: const Icon(
              Icons.arrow_back,
              size: 18,
              color: AppColors.navy,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'CAMP',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
        trailing,
      ],
    );
  }
}

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

// ───────────────────────────────────────────────────────────────────────────
// 5. STORAGE ALLOCATION CARD
// ───────────────────────────────────────────────────────────────────────────
class StorageAllocationCard extends StatelessWidget {
  final String usedLabel;
  final String totalLabel;
  final List<StorageSegment> segments;
  final bool autoUpdate;
  final ValueChanged<bool> onAutoUpdateChanged;

  const StorageAllocationCard({
    super.key,
    required this.usedLabel,
    required this.totalLabel,
    required this.segments,
    required this.autoUpdate,
    required this.onAutoUpdateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: neuShadows(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'STORAGE ALLOCATION',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.label,
                  ),
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.pie_chart_outline,
                  size: 16,
                  color: AppColors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                usedLabel,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                totalLabel,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.subtitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Segmented storage bar
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  for (final s in segments)
                    Expanded(
                      flex: (s.fraction * 1000).round(),
                      child: Container(color: s.color),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              for (final s in segments)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: s.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${s.label} (${s.sizeLabel})',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.subtitle,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0x14000000)),
          const SizedBox(height: 12),

          // Auto-update toggle
          Row(
            children: [
              const Icon(Icons.wifi, size: 16, color: AppColors.subtitle),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Auto-update topo via Wi-Fi',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                ),
              ),
              Switch(
                value: autoUpdate,
                onChanged: onAutoUpdateChanged,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// 6. PACK CARD (saved / downloading / available)
// ───────────────────────────────────────────────────────────────────────────
class PackCard extends StatelessWidget {
  final RoutePack pack;
  const PackCard({super.key, required this.pack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: neuShadows(),
        border: pack.status == PackStatus.downloading
            ? Border.all(
                color: AppColors.orange.withValues(alpha: 0.4),
                width: 1.5,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pack.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: pack.sizeLabel,
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const TextSpan(
                            text: '  •  ',
                            style: TextStyle(color: AppColors.label),
                          ),
                          TextSpan(
                            text: pack.typeLabel,
                            style: const TextStyle(color: AppColors.subtitle),
                          ),
                        ],
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (pack.status == PackStatus.saved) const _SavedTag(),
              if (pack.status == PackStatus.downloading)
                _DownloadingTag(progress: pack.progress ?? 0),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            pack.description,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: AppColors.teal,
            ),
          ),
          const SizedBox(height: 12),

          if (pack.status == PackStatus.saved) ...[
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 6,
                        color: AppColors.orange,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          pack.updateNote ?? '',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.subtitle,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _DarkPillButton(
                  label: 'Sync Update',
                  onTap: () {
                    // TODO: sync pack update
                  },
                ),
              ],
            ),
          ],

          if (pack.status == PackStatus.downloading) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  pack.progressLabel ?? '',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.subtitle,
                  ),
                ),
                Text(
                  pack.speedLabel ?? '',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: pack.progress,
                minHeight: 6,
                backgroundColor: const Color(0xFFDFDBD2),
                valueColor: const AlwaysStoppedAnimation(AppColors.orange),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  // TODO: pause download
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pause, size: 14, color: AppColors.navy),
                      SizedBox(width: 5),
                      Text(
                        'Pause',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          if (pack.status == PackStatus.available) ...[
            Row(
              children: [
                if (pack.noteIcon != null) ...[
                  Icon(pack.noteIcon, size: 13, color: AppColors.subtitle),
                  const SizedBox(width: 5),
                ],
                Expanded(
                  child: Text(
                    pack.note ?? '',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.subtitle,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  // TODO: start pack download
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.download, size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        pack.downloadLabel ?? 'Download Pack',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SavedTag extends StatelessWidget {
  const _SavedTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, size: 12, color: AppColors.green),
          SizedBox(width: 4),
          Text(
            'Saved',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadingTag extends StatelessWidget {
  final double progress; // 0.0–1.0
  const _DownloadingTag({required this.progress});

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$pct%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.orange,
            ),
          ),
          const Text(
            'DOWNLOADING',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: AppColors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkPillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DarkPillButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// 7. FLOATING NAV BAR (same as Ride History — navigation-arrow tab active)
// ───────────────────────────────────────────────────────────────────────────
class FloatingNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const FloatingNavBar({super.key, required this.index, required this.onTap});

  static const _icons = <IconData>[
    Icons.explore_outlined, // compass
    Icons.qr_code_scanner, // QR / scan
    Icons.navigation_outlined, // navigation arrow — active on this screen
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
