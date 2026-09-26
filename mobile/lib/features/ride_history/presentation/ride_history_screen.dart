// ═══════════════════════════════════════════════════════════════════════════
// CAMP — Ride History screen
// ═══════════════════════════════════════════════════════════════════════════
//
// Matches the Stitch design:
//   1. Top header: back button, "CAMP" logo, "LOGS" pill
//   2. "Expedition Telemetry Archive" label + "Ride History" title + count
//   3. Filter chips row (All Rides / Passes / Rally Tracks / + one more)
//   4. Season 2024 Summary card (4 stat tiles)
//   5. Dark "Latest Expedition" hero card with route + elevation chart
//   6. The 3 expedition cards (unchanged from before)
//   7. "Load 20 Earlier..." button
//   8. Floating nav bar (unchanged from before)
//
// HOW TO USE: replace everything in lib/main.dart with this file. No extra
// packages needed — the elevation chart is hand-drawn with CustomPainter.
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

void main() => runApp(const CampApp());

// ───────────────────────────────────────────────────────────────────────────
// 1. THEME
// ───────────────────────────────────────────────────────────────────────────
class AppColors {
  static const bg = Color(0xFFE9E6E0);
  static const surface = Color(0xFFEFECE6);
  static const navy = Color(0xFF1B2130);
  static const label = Color(0xFF8A8F9C);
  static const subtitle = Color(0xFF6B7385);
  static const orange = Color(0xFFFF6A00);
  static const green = Color(0xFF1E9E6A);
  static const navBar = Color(0xFF1C2331);
  static const navIcon = Color(0xFF8B93A7);

  // Dark hero card (Latest Expedition)
  static const heroDarkTop = Color(0xFF3A2418);
  static const heroDarkBottom = Color(0xFF201410);
  static const heroDarkTile = Color(0x1AFFFFFF); // translucent white on dark
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
      home: const RideHistoryScreen(),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// 2. MODELS
// ───────────────────────────────────────────────────────────────────────────
enum TagKind { verified, warning, plain }

class Stat {
  final String label;
  final String value;
  final String? unit;
  final Color valueColor;
  final Color unitColor;
  final Color labelColor;

  const Stat(
    this.label,
    this.value, {
    this.unit,
    this.valueColor = AppColors.navy,
    this.unitColor = AppColors.orange,
    this.labelColor = AppColors.label,
  });
}

class ExpeditionLog {
  final String date;
  final String tag;
  final TagKind tagKind;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String route;
  final String bike;
  final List<Stat> stats;
  final List<String> chips;
  final String? note;
  final String link;

  const ExpeditionLog({
    required this.date,
    required this.tag,
    required this.tagKind,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.route,
    required this.bike,
    required this.stats,
    this.chips = const [],
    this.note,
    required this.link,
  });
}

/// One point on the elevation chart: how far along the ride (0.0–1.0) and
/// the elevation in meters at that point.
class ElevationPoint {
  final double progress; // 0.0 = start, 1.0 = end
  final double elevationM;
  const ElevationPoint(this.progress, this.elevationM);
}

/// Data for the "Carb Tuning" tile in the dark hero card.
class CarbTuningInfo {
  final String value; // e.g. "Leaned 0.5 Turns"
  final String note; // e.g. "61kPa at Summit • Nominal"
  const CarbTuningInfo({required this.value, required this.note});
}

/// Data for the "Fuel Spent" tile in the dark hero card.
class FuelSpentInfo {
  final String value; // e.g. "$38.40 • 13.8L"
  final String note; // e.g. "$3.60 under budget"
  const FuelSpentInfo({required this.value, required this.note});
}

// ───────────────────────────────────────────────────────────────────────────
// 3. SCREEN
// ───────────────────────────────────────────────────────────────────────────
class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  int _tab = 0; // compass tab active by default in the floating nav bar
  int _filter = 0; // which filter chip is selected

  final List<String> _filters = const ['All Rides', 'Passes', 'Rally Tracks'];
  final List<int> _filterCounts = const [
    24,
    0,
    0,
  ]; // only "All Rides" has a count badge

  final List<ExpeditionLog> _logs = [
    ExpeditionLog(
      date: 'OCT 11, 2024',
      tag: 'Verified Loop',
      tagKind: TagKind.verified,
      icon: Icons.explore,
      iconColor: AppColors.orange,
      title: 'Karakoram High-Altitude Corridor',
      route: 'Hasan Abdal → Khunjerab Border',
      bike: 'KTM 890 Adv R',
      stats: const [
        Stat('Distance', '412.0', unit: 'KM'),
        Stat('Time', '7h 15m'),
        Stat('Avg Speed', '56.8', unit: 'KMH'),
        Stat('Max Lean', '34°', valueColor: AppColors.orange),
      ],
      chips: const ['#KKH', 'Pass Elev 4,693m'],
      link: 'Review GPS',
    ),
    ExpeditionLog(
      date: 'SEP 28, 2024',
      tag: 'Crosswind 32kt',
      tagKind: TagKind.warning,
      icon: Icons.waves,
      iconColor: AppColors.subtitle,
      title: 'Makran Coastal Highway & Mud Volcanoes',
      route: 'Hingol National Park',
      bike: 'BMW R 1250 GS',
      stats: const [
        Stat('Distance', '340.5', unit: 'KM'),
        Stat('Time', '4h 50m'),
        Stat('Tire PSI', '32 / 36'),
        Stat(
          'Fuel Econ',
          '4.4',
          unit: 'L',
          valueColor: AppColors.green,
          unitColor: AppColors.green,
        ),
      ],
      note: 'Mechanic Pitstop: Peak Moto (12 min check)',
      link: 'Logs',
    ),
    ExpeditionLog(
      date: 'SEP 15, 2024',
      tag: 'Derawar Fort Circuit',
      tagKind: TagKind.plain,
      icon: Icons.sports_score,
      iconColor: AppColors.subtitle,
      title: 'Cholistan Desert Sand Nav Loop',
      route: 'Deep Sand Dunes',
      bike: 'KTM 890 Adv R',
      stats: const [
        Stat('Distance', '188.0', unit: 'KM'),
        Stat('Time', '3h 40m'),
        Stat('Sand PSI', '22 / 24', valueColor: AppColors.orange),
        Stat('IMU Event', '0 Fall'),
      ],
      note: 'Sand filter cleaned at 188 KM',
      link: 'Logs',
    ),
  ];

  // Mock elevation profile for the "Babusar Pass" hero card chart.
  // progress 0.0 → 1.0 across the ride, elevation in meters.
  final List<ElevationPoint> _elevationProfile = const [
    ElevationPoint(0.00, 2100),
    ElevationPoint(0.15, 2400),
    ElevationPoint(0.30, 3100),
    ElevationPoint(0.45, 3700),
    ElevationPoint(0.55, 4173), // peak — the summit
    ElevationPoint(0.70, 3500),
    ElevationPoint(0.85, 2100),
    ElevationPoint(1.00, 1266),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // ── LAYER 1: the scrolling content ──
          SafeArea(
            bottom: false,
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 110 + bottomInset),
              children: [
                const TopHeader(),
                const SizedBox(height: 20),

                const SectionEyebrow(text: 'EXPEDITION TELEMETRY ARCHIVE'),
                const SizedBox(height: 6),
                const RideHistoryTitleRow(count: 24),
                const SizedBox(height: 16),

                FilterChipsRow(
                  filters: _filters,
                  counts: _filterCounts,
                  selected: _filter,
                  onSelect: (i) => setState(() => _filter = i),
                ),
                const SizedBox(height: 16),

                const SeasonSummaryCard(
                  bikes: 'BMW GS #441 • KTM 890',
                  synced: true,
                  stats: [
                    Stat('Distance', '14,820', unit: 'KM'),
                    Stat('Saddle', '418', unit: 'HRS'),
                    Stat('Total Elev', '+142.5', unit: 'K'),
                    Stat('Avg Fuel', '4.8', unit: 'L/100km'),
                  ],
                ),
                const SizedBox(height: 16),

                DarkHeroCard(
                  badge: 'LATEST EXPEDITION',
                  dateLabel: 'Yesterday • Oct 14',
                  title: 'Babusar Pass Summit & Alpine Ridge',
                  bike: 'BMW R 1250 GS Adventure',
                  tuning: 'Tuned Dual CV',
                  stats: const [
                    Stat(
                      'Distance',
                      '286.4',
                      unit: 'KM',
                      valueColor: Colors.white,
                    ),
                    Stat('Duration', '5h 42m', valueColor: Colors.white),
                    Stat(
                      'Max Alt',
                      '4,173',
                      unit: 'M',
                      valueColor: Colors.white,
                    ),
                  ],
                  routeStart: 'Kaghan Valley',
                  routePeak: 'Summit (4,173m)',
                  routeEnd: 'Chilas Jct',
                  maxGrade: '14.2%',
                  baseLabel: '2,100m Base',
                  midLabel: 'Hairpins Section (18 Turns)',
                  endLabel: '1,266m Descent',
                  peakLabel: '4,173m',
                  profile: _elevationProfile,
                  carbTuning: const CarbTuningInfo(
                    value: 'Leaned 0.5 Turns',
                    note: '61kPa at Summit • Nominal',
                  ),
                  fuelSpent: const FuelSpentInfo(
                    value: '\$38.40 • 13.8L',
                    note: '\$3.60 under budget',
                  ),
                ),
                const SizedBox(height: 20),

                for (final log in _logs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ExpeditionCard(log: log),
                  ),

                NeuButton(
                  icon: Icons.history,
                  iconColor: AppColors.subtitle,
                  label: 'Load 20 Earlier Expedition Logs (2023–2024)',
                  onTap: () {
                    // TODO: fetch and append older logs here
                  },
                ),
              ],
            ),
          ),

          // ── LAYER 2: the floating nav bar ──
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
// 4. TOP HEADER (back button, CAMP logo, LOGS pill)
// ───────────────────────────────────────────────────────────────────────────
class TopHeader extends StatelessWidget {
  const TopHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Back button
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
        // "CAMP" logo, centered in the remaining space
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
        // "LOGS" pill
        GestureDetector(
          onTap: () {
            // TODO: navigate to logs (already here, could no-op)
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(999),
              boxShadow: neuShadows(d: 3, blur: 6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: AppColors.orange),
                SizedBox(width: 6),
                Text(
                  'LOGS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: AppColors.navy,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Small uppercase muted label used above section titles.
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

/// "Ride History" title + "N Logged" badge + download icon button.
class RideHistoryTitleRow extends StatelessWidget {
  final int count;
  const RideHistoryTitleRow({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              const Text(
                'Ride History',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              Text(
                '$count Logged',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.subtitle,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            // TODO: export / download ride history
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: neuShadows(d: 3, blur: 6),
            ),
            child: const Icon(
              Icons.file_download_outlined,
              size: 18,
              color: AppColors.navy,
            ),
          ),
        ),
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// 5. FILTER CHIPS
// ───────────────────────────────────────────────────────────────────────────
class FilterChipsRow extends StatelessWidget {
  final List<String> filters;
  final List<int> counts; // 0 = no count badge shown
  final int selected;
  final ValueChanged<int> onSelect;

  const FilterChipsRow({
    super.key,
    required this.filters,
    required this.counts,
    required this.selected,
    required this.onSelect,
  });

  static const _icons = [Icons.motorcycle, Icons.terrain, Icons.route];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < filters.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            _FilterChip(
              label: filters[i],
              count: counts[i] > 0 ? counts[i] : null,
              icon: _icons[i % _icons.length],
              active: i == selected,
              onTap: () => onSelect(i),
            ),
          ],
          const SizedBox(width: 10),
          // A trailing icon-only chip (e.g. "nearby" / compass), matching the
          // partially-cut-off 4th chip in the design.
          GestureDetector(
            onTap: () {
              // TODO: wire up the 4th filter
            },
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: neuShadows(d: 3, blur: 6),
              ),
              child: const Icon(
                Icons.near_me_outlined,
                size: 18,
                color: AppColors.subtitle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int? count;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.orange : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          boxShadow: active ? null : neuShadows(d: 3, blur: 6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: active ? Colors.white : AppColors.subtitle,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : AppColors.navy,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: active ? Colors.white24 : AppColors.bg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: active ? Colors.white : AppColors.navy,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// 6. SEASON SUMMARY CARD
// ───────────────────────────────────────────────────────────────────────────
class SeasonSummaryCard extends StatelessWidget {
  final String bikes;
  final bool synced;
  final List<Stat> stats;

  const SeasonSummaryCard({
    super.key,
    required this.bikes,
    required this.synced,
    required this.stats,
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
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SEASON 2024 SUMMARY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.label,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bikes,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
              ),
              if (synced)
                const Row(
                  children: [
                    Icon(Icons.check_circle, size: 14, color: AppColors.green),
                    SizedBox(width: 4),
                    Text(
                      '100% Synced',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (int i = 0; i < stats.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: StatTile(stat: stats[i])),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// 7. DARK HERO CARD (Latest Expedition) + elevation chart
// ───────────────────────────────────────────────────────────────────────────
class DarkHeroCard extends StatelessWidget {
  final String badge;
  final String dateLabel;
  final String title;
  final String bike;
  final String tuning;
  final List<Stat> stats;
  final String routeStart;
  final String routePeak;
  final String routeEnd;
  final String maxGrade;
  final String baseLabel;
  final String midLabel;
  final String endLabel;
  final String peakLabel;
  final List<ElevationPoint> profile;
  final CarbTuningInfo carbTuning;
  final FuelSpentInfo fuelSpent;

  const DarkHeroCard({
    super.key,
    required this.badge,
    required this.dateLabel,
    required this.title,
    required this.bike,
    required this.tuning,
    required this.stats,
    required this.routeStart,
    required this.routePeak,
    required this.routeEnd,
    required this.maxGrade,
    required this.baseLabel,
    required this.midLabel,
    required this.endLabel,
    required this.peakLabel,
    required this.profile,
    required this.carbTuning,
    required this.fuelSpent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.heroDarkTop, AppColors.heroDarkBottom],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            offset: Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Badge row ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dateLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.terrain,
                  size: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Title ──
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),

          // ── Bike • tuning ──
          Row(
            children: [
              const Icon(Icons.two_wheeler, size: 14, color: Colors.white54),
              const SizedBox(width: 6),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: bike,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const TextSpan(
                        text: '  •  ',
                        style: TextStyle(color: Colors.white38),
                      ),
                      TextSpan(
                        text: tuning,
                        style: const TextStyle(
                          color: AppColors.orange,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  style: const TextStyle(fontSize: 12.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Stat tiles (dark variant) ──
          Row(
            children: [
              for (int i = 0; i < stats.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: DarkStatTile(stat: stats[i])),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // ── Route line: start → peak → end ──
          Row(
            children: [
              const Icon(Icons.circle, size: 8, color: AppColors.green),
              const SizedBox(width: 6),
              Text(
                routeStart,
                style: const TextStyle(fontSize: 11.5, color: Colors.white70),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Divider(color: Colors.white24, height: 1),
                ),
              ),
              const Icon(Icons.landscape, size: 13, color: AppColors.orange),
              const SizedBox(width: 4),
              Text(
                routePeak,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.orange,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Divider(color: Colors.white24, height: 1),
                ),
              ),
              const Icon(Icons.circle, size: 8, color: AppColors.orange),
              const SizedBox(width: 6),
              Text(
                routeEnd,
                style: const TextStyle(fontSize: 11.5, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── Elevation & incline profile ──
          Row(
            children: [
              const Text(
                'ELEVATION & INCLINE PROFILE',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: Colors.white54,
                ),
              ),
              const Spacer(),
              Text(
                'MAX GRADE $maxGrade',
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                  color: AppColors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            width: double.infinity,
            child: CustomPaint(
              painter: ElevationChartPainter(
                profile: profile,
                peakLabel: peakLabel,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                baseLabel,
                style: const TextStyle(fontSize: 9.5, color: Colors.white38),
              ),
              Text(
                midLabel,
                style: const TextStyle(fontSize: 9.5, color: Colors.white38),
              ),
              Text(
                endLabel,
                style: const TextStyle(fontSize: 9.5, color: Colors.white38),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Carb Tuning / Fuel Spent tiles ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DarkInfoTile(
                  icon: Icons.settings_input_component,
                  label: 'CARB TUNING',
                  value: carbTuning.value,
                  note: carbTuning.note,
                  noteColor: Colors.white38,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DarkInfoTile(
                  icon: Icons.local_gas_station,
                  label: 'FUEL SPENT',
                  value: fuelSpent.value,
                  note: fuelSpent.note,
                  noteColor: AppColors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Replay Telemetry / Details buttons ──
          Row(
            children: [
              Expanded(
                child: DarkButton(
                  icon: Icons.play_circle_outline,
                  iconColor: AppColors.orange,
                  label: 'Replay Telemetry',
                  onTap: () {
                    // TODO: open telemetry replay
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DarkButton(
                  icon: Icons.visibility_outlined,
                  iconColor: Colors.white70,
                  label: 'Details',
                  onTap: () {
                    // TODO: open details
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A dark translucent tile with an icon, label, value and small note —
/// used for "Carb Tuning" and "Fuel Spent" in the hero card.
class DarkInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String note;
  final Color noteColor;

  const DarkInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.note,
    required this.noteColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.heroDarkTile,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: Colors.white54),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: Colors.white54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            note,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: noteColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Pill button styled for the dark hero card (translucent instead of the
/// light neumorphic surface used by NeuButton elsewhere).
class DarkButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback? onTap;

  const DarkButton({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.heroDarkTile,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: iconColor),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stat tile styled for the dark hero card (translucent white background
/// instead of the light neumorphic surface).
class DarkStatTile extends StatelessWidget {
  final Stat stat;
  const DarkStatTile({super.key, required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.heroDarkTile,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              stat.label.toUpperCase(),
              style: const TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: Colors.white54,
              ),
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: stat.value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  if (stat.unit != null)
                    TextSpan(
                      text: ' ${stat.unit}',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.orange,
                      ),
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

/// Hand-drawn elevation/incline line chart with a filled gradient under the
/// line and a small marker + label at the highest point (the summit).
class ElevationChartPainter extends CustomPainter {
  final List<ElevationPoint> profile;
  final String peakLabel;

  ElevationChartPainter({required this.profile, required this.peakLabel});

  @override
  void paint(Canvas canvas, Size size) {
    if (profile.isEmpty) return;

    final minElev = profile
        .map((p) => p.elevationM)
        .reduce((a, b) => a < b ? a : b);
    final maxElev = profile
        .map((p) => p.elevationM)
        .reduce((a, b) => a > b ? a : b);
    final range = (maxElev - minElev).clamp(1, double.infinity);

    // Leave headroom at the top for the peak marker + label.
    const topPadding = 22.0;
    final chartHeight = size.height - topPadding;

    Offset toPoint(ElevationPoint p) {
      final x = p.progress * size.width;
      final normalized = (p.elevationM - minElev) / range; // 0..1
      final y = topPadding + chartHeight * (1 - normalized);
      return Offset(x, y);
    }

    final points = profile.map(toPoint).toList();

    // ── Filled area under the line ──
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.orange.withValues(alpha: 0.35),
          AppColors.orange.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // ── The line itself ──
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      linePath.lineTo(p.dx, p.dy);
    }
    final linePaint = Paint()
      ..color = AppColors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    // ── Peak marker + label ──
    final peakPoint = points.reduce(
      (a, b) => a.dy < b.dy ? a : b,
    ); // smallest y = highest point
    canvas.drawCircle(peakPoint, 4, Paint()..color = Colors.white);
    canvas.drawCircle(
      peakPoint,
      4,
      Paint()
        ..color = AppColors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: peakLabel,
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Draw a small dark pill behind the label so it stays readable.
    final labelOffset = Offset(
      (peakPoint.dx - textPainter.width / 2).clamp(
        0,
        size.width - textPainter.width,
      ),
      (peakPoint.dy - textPainter.height - 10).clamp(0, size.height),
    );
    final labelRect = Rect.fromLTWH(
      labelOffset.dx - 6,
      labelOffset.dy - 3,
      textPainter.width + 12,
      textPainter.height + 6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, const Radius.circular(8)),
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );
    textPainter.paint(canvas, labelOffset);
  }

  @override
  bool shouldRepaint(covariant ElevationChartPainter oldDelegate) {
    return oldDelegate.profile != profile || oldDelegate.peakLabel != peakLabel;
  }
}

// ───────────────────────────────────────────────────────────────────────────
// 8. EXPEDITION CARD (unchanged from before)
// ───────────────────────────────────────────────────────────────────────────
class ExpeditionCard extends StatelessWidget {
  final ExpeditionLog log;
  const ExpeditionCard({super.key, required this.log});

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
            children: [
              DateChip(text: log.date),
              const SizedBox(width: 8),
              Flexible(
                child: TagLabel(text: log.tag, kind: log.tagKind),
              ),
              const Spacer(),
              IconBtn(icon: log.icon, color: log.iconColor),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            log.title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              height: 1.15,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: log.route,
                  style: const TextStyle(color: AppColors.subtitle),
                ),
                const TextSpan(
                  text: '  •  ',
                  style: TextStyle(color: AppColors.label),
                ),
                TextSpan(
                  text: log.bike,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (int i = 0; i < log.stats.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: StatTile(stat: log.stats[i])),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: log.chips.isNotEmpty
                    ? Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          for (final c in log.chips) InfoChip(text: c),
                        ],
                      )
                    : Text(
                        log.note ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.subtitle,
                        ),
                      ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  // TODO: navigate to the GPS review / logs page
                },
                child: Text(
                  '${log.link} →',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.orange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// 9. SMALL WIDGETS
// ───────────────────────────────────────────────────────────────────────────
class StatTile extends StatelessWidget {
  final Stat stat;
  const StatTile({super.key, required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: neuShadows(d: 3, blur: 6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              stat.label.toUpperCase(),
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: stat.labelColor,
              ),
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: stat.value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: stat.valueColor,
                    ),
                  ),
                  if (stat.unit != null)
                    TextSpan(
                      text: ' ${stat.unit}',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: stat.unitColor,
                      ),
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

class DateChip extends StatelessWidget {
  final String text;
  const DateChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: neuShadows(d: 2, blur: 4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          color: AppColors.navy,
        ),
      ),
    );
  }
}

class TagLabel extends StatelessWidget {
  final String text;
  final TagKind kind;
  const TagLabel({super.key, required this.text, required this.kind});

  @override
  Widget build(BuildContext context) {
    late final Color color;
    IconData? icon;
    switch (kind) {
      case TagKind.verified:
        color = AppColors.green;
        icon = Icons.check_circle_outline;
        break;
      case TagKind.warning:
        color = AppColors.orange;
        icon = Icons.warning_amber_rounded;
        break;
      case TagKind.plain:
        color = AppColors.subtitle;
        icon = null;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  const IconBtn({super.key, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: neuShadows(d: 3, blur: 6),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}

class InfoChip extends StatelessWidget {
  final String text;
  const InfoChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5F0),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x1A000000)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.navy,
        ),
      ),
    );
  }
}

class NeuButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback? onTap;

  const NeuButton({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          boxShadow: neuShadows(d: 4, blur: 8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// 10. FLOATING NAV BAR (unchanged from before)
// ───────────────────────────────────────────────────────────────────────────
class FloatingNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const FloatingNavBar({super.key, required this.index, required this.onTap});

  static const _icons = <IconData>[
    Icons.explore_outlined, // compass — active by default
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
