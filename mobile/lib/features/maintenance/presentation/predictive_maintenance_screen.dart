// ═══════════════════════════════════════════════════════════════════════════
// CAMP — Predictive Maintenance screen (Finances & Rig Health)  — DYNAMIC
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camp/app/theme/app_theme.dart';

// ───────────────────────────────────────────────────────────────────────────
// MODELS
// ───────────────────────────────────────────────────────────────────────────
enum MaintStatus { warning, ok, diy, monitor }

class BudgetLineItem {
  IconData icon;
  Color iconColor;
  String title;
  String subtitle;
  double amount;
  BudgetLineItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.amount,
  });
}

class MaintenanceItem {
  IconData icon;
  String title;
  String subtitle;
  String statusValue;
  MaintStatus status;
  IconData rowIcon;
  String rowNote;
  Color rowNoteColor;
  String? actionLabel;
  String? trailingNote;

  MaintenanceItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.statusValue,
    required this.status,
    required this.rowIcon,
    required this.rowNote,
    required this.rowNoteColor,
    this.actionLabel,
    this.trailingNote,
  });
}

// ───────────────────────────────────────────────────────────────────────────
// SCREEN
// ───────────────────────────────────────────────────────────────────────────
class PredictiveMaintenanceScreen extends StatefulWidget {
  const PredictiveMaintenanceScreen({super.key});

  @override
  State<PredictiveMaintenanceScreen> createState() =>
      _PredictiveMaintenanceScreenState();
}

class _PredictiveMaintenanceScreenState
    extends State<PredictiveMaintenanceScreen> {
  int _tab = 4;

  // ── Bike / hero ──────────────────────────────────────────────────────────
  String _bikeLabel = 'KTM 890 Adventure R';
  String _vinLabel = 'VIN ●●9482';

  // ── Trip / budget ────────────────────────────────────────────────────────
  String _tripTag = 'Alpine Ridge Tour';
  double _budgetCap = 300.0;

  final List<BudgetLineItem> _budgetItems = [
    BudgetLineItem(
      icon: Icons.local_gas_station,
      iconColor: AppColors.orange,
      title: 'Fuel Cost',
      subtitle: '32.4 gal est. @ \$3.46/gal',
      amount: 112.30,
    ),
    BudgetLineItem(
      icon: Icons.confirmation_number_outlined,
      iconColor: AppColors.subtitle,
      title: 'Park Permits & Passes',
      subtitle: 'National Backcountry Pass',
      amount: 35.00,
    ),
    BudgetLineItem(
      icon: Icons.cabin_outlined,
      iconColor: AppColors.subtitle,
      title: 'Camp Lodging / Fees',
      subtitle: '2 Nights Primitive Sites',
      amount: 37.20,
    ),
  ];

  double get _totalSpent => _budgetItems.fold(0.0, (s, i) => s + i.amount);
  double get _allocationPct =>
      _budgetCap > 0 ? (_totalSpent / _budgetCap).clamp(0.0, 1.0) : 0.0;
  double get _underBudget => _budgetCap - _totalSpent;

  final List<MaintenanceItem> _maintenance = [
    MaintenanceItem(
      icon: Icons.album_outlined,
      title: 'Rear Brake Pad Replacement',
      subtitle: 'Sintered Compound • Brembo Rear',
      statusValue: '\$85',
      status: MaintStatus.warning,
      rowIcon: Icons.warning_amber_rounded,
      rowNote: 'Due in 350 mi',
      rowNoteColor: AppColors.orange,
      actionLabel: 'View Guide',
    ),
    MaintenanceItem(
      icon: Icons.water_drop_outlined,
      title: 'Engine Oil & Filter',
      subtitle: 'Synthetic 15W-50 • Motorex Cross Power',
      statusValue: 'OK',
      status: MaintStatus.ok,
      rowIcon: Icons.check_circle_outline,
      rowNote: 'Good • 2,180 mi left',
      rowNoteColor: AppColors.green,
      trailingNote: 'Changed Jun 04',
    ),
    MaintenanceItem(
      icon: Icons.settings_outlined,
      title: 'Chain / Final Drive Shaft',
      subtitle: 'Tension Slack: 32mm (Spec: 30mm)',
      statusValue: 'DIY',
      status: MaintStatus.diy,
      rowIcon: Icons.build_outlined,
      rowNote: 'Recommended before pass',
      rowNoteColor: AppColors.orange,
      actionLabel: 'View Guide',
    ),
    MaintenanceItem(
      icon: Icons.circle_outlined,
      title: 'Tire Tread Depth',
      subtitle: 'Front: 4.2mm • Rear: 2.8mm',
      statusValue: 'T-45%',
      status: MaintStatus.monitor,
      rowIcon: Icons.visibility_outlined,
      rowNote: 'Monitor rear',
      rowNoteColor: AppColors.orange,
      trailingNote: 'Motoz Tractionator',
    ),
  ];

  // ── Pitstop ───────────────────────────────────────────────────────────────
  String _pitstopStatus = 'Confirmed';
  String _pitstopDateTime = 'Oct 18, 10:00 AM';
  String _pitstopPlace = 'Peak Moto Dealership & Prep';
  String _pitstopLocation = 'Denver, CO';
  String _pitstopDistance = '42 mi';

  // ── Sync clock ────────────────────────────────────────────────────────────
  DateTime _lastSync = DateTime.now();
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    _syncTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  String get _syncLabel {
    final diff = DateTime.now().difference(_lastSync);
    if (diff.inSeconds < 60) return 'SYNCD JUST NOW';
    if (diff.inMinutes < 60) return 'SYNCD \${diff.inMinutes}M AGO';
    return 'SYNCD \${diff.inHours}H AGO';
  }

  // ── Generic form dialog ───────────────────────────────────────────────────
  void _showFormDialog({
    required String title,
    required List<_FieldDef> fields,
    required VoidCallback onSave,
    bool showDelete = false,
    VoidCallback? onDelete,
    Widget? extraContent,
  }) {
    showDialog(
      context: context,
      builder: (_) => _FormDialog(
        title: title,
        fields: fields,
        onSave: onSave,
        showDelete: showDelete,
        onDelete: onDelete,
        extraContent: extraContent,
      ),
    );
  }

  void _editBikeInfo() {
    final bike = TextEditingController(text: _bikeLabel);
    final vin = TextEditingController(text: _vinLabel);
    _showFormDialog(
      title: 'Edit Bike Info',
      fields: [
        _FieldDef(label: 'Bike Model', controller: bike),
        _FieldDef(label: 'VIN', controller: vin),
      ],
      onSave: () => setState(() {
        _bikeLabel = bike.text.trim().isEmpty ? _bikeLabel : bike.text.trim();
        _vinLabel = vin.text.trim().isEmpty ? _vinLabel : vin.text.trim();
      }),
    );
  }

  void _editTripBudget() {
    final tag = TextEditingController(text: _tripTag);
    final cap = TextEditingController(text: _budgetCap.toStringAsFixed(2));
    _showFormDialog(
      title: 'Edit Trip & Budget',
      fields: [
        _FieldDef(label: 'Trip Name', controller: tag),
        _FieldDef(
          label: 'Budget Cap (\$)',
          controller: cap,
          keyboardType: TextInputType.number,
        ),
      ],
      onSave: () => setState(() {
        _tripTag = tag.text.trim().isEmpty ? _tripTag : tag.text.trim();
        _budgetCap =
            double.tryParse(cap.text.replaceAll(',', '')) ?? _budgetCap;
      }),
    );
  }

  void _addBudgetItem() {
    final titleC = TextEditingController();
    final subtitleC = TextEditingController();
    final amountC = TextEditingController();
    _showFormDialog(
      title: 'Add Budget Item',
      fields: [
        _FieldDef(label: 'Title', controller: titleC),
        _FieldDef(label: 'Subtitle', controller: subtitleC),
        _FieldDef(
          label: 'Amount (\$)',
          controller: amountC,
          keyboardType: TextInputType.number,
        ),
      ],
      onSave: () {
        final amt = double.tryParse(amountC.text.replaceAll(',', '')) ?? 0;
        setState(() {
          _budgetItems.add(
            BudgetLineItem(
              icon: Icons.attach_money,
              iconColor: AppColors.orange,
              title: titleC.text.trim(),
              subtitle: subtitleC.text.trim(),
              amount: amt,
            ),
          );
        });
      },
    );
  }

  void _editBudgetItemDialog(BudgetLineItem item) {
    final titleC = TextEditingController(text: item.title);
    final subtitleC = TextEditingController(text: item.subtitle);
    final amountC = TextEditingController(text: item.amount.toStringAsFixed(2));
    _showFormDialog(
      title: 'Edit Budget Item',
      fields: [
        _FieldDef(label: 'Title', controller: titleC),
        _FieldDef(label: 'Subtitle', controller: subtitleC),
        _FieldDef(
          label: 'Amount (\$)',
          controller: amountC,
          keyboardType: TextInputType.number,
        ),
      ],
      onSave: () {
        final amt =
            double.tryParse(amountC.text.replaceAll(',', '')) ?? item.amount;
        setState(() {
          item.title = titleC.text.trim();
          item.subtitle = subtitleC.text.trim();
          item.amount = amt;
        });
      },
      showDelete: true,
      onDelete: () => setState(() => _budgetItems.remove(item)),
    );
  }

  void _addMaintenanceItem() {
    _editMaintenanceDialog(null);
  }

  void _editMaintenanceDialog(MaintenanceItem? existing) {
    final titleC = TextEditingController(text: existing?.title ?? '');
    final subtitleC = TextEditingController(text: existing?.subtitle ?? '');
    final statusVC = TextEditingController(text: existing?.statusValue ?? '');
    final noteC = TextEditingController(text: existing?.rowNote ?? '');
    final actionC = TextEditingController(text: existing?.actionLabel ?? '');
    MaintStatus selectedStatus = existing?.status ?? MaintStatus.ok;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) => _FormDialog(
          title: existing == null ? 'Add Maintenance Item' : 'Edit Maintenance',
          fields: [
            _FieldDef(label: 'Title', controller: titleC),
            _FieldDef(label: 'Subtitle / Details', controller: subtitleC),
            _FieldDef(
              label: 'Status Value (e.g. OK, \$85, DIY)',
              controller: statusVC,
            ),
            _FieldDef(
              label: 'Row Note (e.g. Due in 350 mi)',
              controller: noteC,
            ),
            _FieldDef(
              label: 'Action Button Label (optional)',
              controller: actionC,
            ),
          ],
          extraContent: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Status',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: MaintStatus.values.map((s) {
                  final selected = s == selectedStatus;
                  return GestureDetector(
                    onTap: () => setInner(() => selectedStatus = s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.orange : AppColors.bg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        s.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : AppColors.subtitle,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          onSave: () {
            setState(() {
              Color noteColor;
              IconData rowIcon;
              switch (selectedStatus) {
                case MaintStatus.ok:
                  noteColor = AppColors.green;
                  rowIcon = Icons.check_circle_outline;
                  break;
                case MaintStatus.warning:
                  noteColor = AppColors.orange;
                  rowIcon = Icons.warning_amber_rounded;
                  break;
                case MaintStatus.diy:
                  noteColor = AppColors.subtitle;
                  rowIcon = Icons.build_outlined;
                  break;
                case MaintStatus.monitor:
                  noteColor = AppColors.orange;
                  rowIcon = Icons.visibility_outlined;
                  break;
              }
              if (existing == null) {
                _maintenance.add(
                  MaintenanceItem(
                    icon: Icons.build_circle_outlined,
                    title: titleC.text.trim(),
                    subtitle: subtitleC.text.trim(),
                    statusValue: statusVC.text.trim(),
                    status: selectedStatus,
                    rowIcon: rowIcon,
                    rowNote: noteC.text.trim(),
                    rowNoteColor: noteColor,
                    actionLabel: actionC.text.trim().isEmpty
                        ? null
                        : actionC.text.trim(),
                  ),
                );
              } else {
                existing.title = titleC.text.trim();
                existing.subtitle = subtitleC.text.trim();
                existing.statusValue = statusVC.text.trim();
                existing.status = selectedStatus;
                existing.rowNote = noteC.text.trim();
                existing.rowNoteColor = noteColor;
                existing.rowIcon = rowIcon;
                existing.actionLabel = actionC.text.trim().isEmpty
                    ? null
                    : actionC.text.trim();
              }
            });
          },
          showDelete: existing != null,
          onDelete: existing == null
              ? null
              : () => setState(() => _maintenance.remove(existing)),
        ),
      ),
    );
  }

  void _editPitstop() {
    final status = TextEditingController(text: _pitstopStatus);
    final dt = TextEditingController(text: _pitstopDateTime);
    final place = TextEditingController(text: _pitstopPlace);
    final loc = TextEditingController(text: _pitstopLocation);
    final dist = TextEditingController(text: _pitstopDistance);
    _showFormDialog(
      title: 'Edit Pitstop',
      fields: [
        _FieldDef(label: 'Status', controller: status),
        _FieldDef(label: 'Date & Time', controller: dt),
        _FieldDef(label: 'Place', controller: place),
        _FieldDef(label: 'Location / City', controller: loc),
        _FieldDef(label: 'Distance (e.g. 42 mi)', controller: dist),
      ],
      onSave: () => setState(() {
        _pitstopStatus = status.text.trim();
        _pitstopDateTime = dt.text.trim();
        _pitstopPlace = place.text.trim();
        _pitstopLocation = loc.text.trim();
        _pitstopDistance = dist.text.trim();
      }),
    );
  }

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
                const _Header(),
                const SizedBox(height: 20),

                const SectionEyebrow(text: 'EXPEDITION TELEMETRY'),
                const SizedBox(height: 6),
                _TitleRow(
                  title: 'Finances & Rig Health',
                  trailing: GestureDetector(
                    onTap: () => setState(() => _lastSync = DateTime.now()),
                    child: _SyncPill(text: _syncLabel),
                  ),
                ),
                const SizedBox(height: 16),

                // Tap hero to edit bike info
                GestureDetector(
                  onTap: _editBikeInfo,
                  child: _HeroPhoto(bikeLabel: _bikeLabel, vinLabel: _vinLabel),
                ),
                const SizedBox(height: 16),

                BudgetCard(
                  tag: _tripTag,
                  title: 'Trip Budget & Fuel Economics',
                  spent: '\$${_totalSpent.toStringAsFixed(2)}',
                  cap: '/ \$${_budgetCap.toStringAsFixed(0)} Est. Cap',
                  underBudgetNote: _underBudget >= 0
                      ? '\$${_underBudget.toStringAsFixed(2)} under target budget'
                      : '\$${(-_underBudget).toStringAsFixed(2)} over budget',
                  underBudgetPositive: _underBudget >= 0,
                  allocationLabel: 'Allocation Spent',
                  allocationPct: _allocationPct,
                  items: _budgetItems,
                  onEditTrip: _editTripBudget,
                  onAddItem: _addBudgetItem,
                  onEditItem: _editBudgetItemDialog,
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    const Expanded(
                      child: SectionEyebrow(text: 'CONDITION TELEMETRY'),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _addMaintenanceItem,
                      child: const _RoundIconButton(icon: Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Upcoming & Required\nMaintenance',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 14),

                for (final item in _maintenance)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onLongPress: () => _editMaintenanceDialog(item),
                      child: MaintenanceCard(item: item),
                    ),
                  ),

                if (_maintenance.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'No maintenance items.\nTap + to add one.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.subtitle,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                DownloadReportButton(
                  title: 'Download Full Report (PDF)',
                  subtitle: 'Receipts, telemetry logs & schedule',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Generating PDF report…')),
                    );
                  },
                ),
                const SizedBox(height: 12),

                OutlinedPillButton(
                  label: 'Order Parts',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening parts store…')),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Tap pitstop card to edit
                GestureDetector(
                  onTap: _editPitstop,
                  child: PitstopCard(
                    eyebrow: 'UPCOMING PITSTOP',
                    status: _pitstopStatus,
                    dateTime: _pitstopDateTime,
                    place: _pitstopPlace,
                    location: _pitstopLocation,
                    onCallDealer: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Calling dealer…')),
                      );
                    },
                    onDirections: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening maps…')),
                      );
                    },
                    directionsDistance: _pitstopDistance,
                  ),
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
// FORM DIALOG HELPERS
// ───────────────────────────────────────────────────────────────────────────
class _FieldDef {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  _FieldDef({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });
}

class _FormDialog extends StatelessWidget {
  final String title;
  final List<_FieldDef> fields;
  final VoidCallback onSave;
  final bool showDelete;
  final VoidCallback? onDelete;
  final Widget? extraContent;

  const _FormDialog({
    required this.title,
    required this.fields,
    required this.onSave,
    this.showDelete = false,
    this.onDelete,
    this.extraContent,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 16),
            for (final f in fields) ...[
              Text(
                f.label,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.subtitle,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: f.controller,
                keyboardType: f.keyboardType,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.bg,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            ?extraContent,
            const SizedBox(height: 8),
            Row(
              children: [
                if (showDelete && onDelete != null)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        onDelete!();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (showDelete) const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      onSave();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// HEADER (hamburger menu + mini CAMP logo + section pill)
// ───────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            // TODO: open the app drawer / navigation menu
          },
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: neuShadows(d: 3, blur: 6),
            ),
            child: const Icon(Icons.menu, size: 18, color: AppColors.navy),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'CAMP',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Flexible so a longer section name never overflows off-screen.
        Flexible(
          child: Container(
            // Fixed height matches the 40px hamburger button so both sit
            // on the same visual center line — padding alone gave this a
            // different height and made it look off-center.
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'FINANCES & RIG HEALTH',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: AppColors.subtitle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TitleRow extends StatelessWidget {
  final String title;
  final Widget trailing;
  const _TitleRow({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
        ),
        const SizedBox(width: 8),
        trailing,
      ],
    );
  }
}

class _SyncPill extends StatelessWidget {
  final String text;
  const _SyncPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        boxShadow: neuShadows(d: 3, blur: 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sync, size: 12, color: AppColors.orange),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// HERO PHOTO
// ───────────────────────────────────────────────────────────────────────────
/// NOTE: no real photo asset available, so this is a placeholder gradient
/// with an icon. Swap the `child`/decoration for Image.asset or a cached
/// network image once you have the real trail photo.
class _HeroPhoto extends StatelessWidget {
  final String bikeLabel;
  final String vinLabel;
  const _HeroPhoto({required this.bikeLabel, required this.vinLabel});

  @override
  Widget build(BuildContext context) {
    // AspectRatio makes the photo scale with screen width instead of using
    // a fixed height — stays proportional on any device.
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7A8B6F), Color(0xFF3D4A38)],
                ),
              ),
              child: const Center(
                child: Icon(Icons.terrain, size: 48, color: Colors.white38),
              ),
            ),
            // Darken the bottom so the overlay text stays readable over any
            // photo, regardless of its own brightness.
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.two_wheeler,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            bikeLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    vinLabel,
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// BUDGET CARD
// ───────────────────────────────────────────────────────────────────────────
class BudgetCard extends StatelessWidget {
  final String tag;
  final String title;
  final String spent;
  final String cap;
  final String underBudgetNote;
  final bool underBudgetPositive;
  final String allocationLabel;
  final double allocationPct;
  final List<BudgetLineItem> items;
  final VoidCallback onEditTrip;
  final VoidCallback onAddItem;
  final void Function(BudgetLineItem) onEditItem;

  const BudgetCard({
    super.key,
    required this.tag,
    required this.title,
    required this.spent,
    required this.cap,
    required this.underBudgetNote,
    required this.underBudgetPositive,
    required this.allocationLabel,
    required this.allocationPct,
    required this.items,
    required this.onEditTrip,
    required this.onAddItem,
    required this.onEditItem,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.terrain, size: 12, color: AppColors.orange),
                const SizedBox(width: 5),
                Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.orange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 8),
          // Wrap lets "$184.50" and "/ $300 Est. Cap" drop to a new line on
          // very narrow screens instead of overflowing.
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 6,
            children: [
              Text(
                spent,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  cap,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.subtitle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.trending_down, size: 14, color: AppColors.green),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  underBudgetNote,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  allocationLabel,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.subtitle,
                  ),
                ),
              ),
              Text(
                '${(allocationPct * 100).round()}% used',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: allocationPct,
              minHeight: 6,
              backgroundColor: const Color(0xFFDFDBD2),
              valueColor: const AlwaysStoppedAnimation(AppColors.orange),
            ),
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 20, color: Color(0x14000000)),
            _BudgetLineRow(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _BudgetLineRow extends StatelessWidget {
  final BudgetLineItem item;
  const _BudgetLineRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: item.iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(item.icon, size: 17, color: item.iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              Text(
                item.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: AppColors.subtitle),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '\$${item.amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
          ),
        ),
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// MAINTENANCE CARD
// ───────────────────────────────────────────────────────────────────────────
class MaintenanceCard extends StatelessWidget {
  final MaintenanceItem item;
  const MaintenanceCard({super.key, required this.item});

  Color get _statusColor {
    switch (item.status) {
      case MaintStatus.warning:
        return AppColors.orange;
      case MaintStatus.ok:
        return AppColors.green;
      case MaintStatus.diy:
        return AppColors.subtitle;
      case MaintStatus.monitor:
        return AppColors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: neuShadows(d: 4, blur: 9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, size: 17, color: AppColors.navy),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.subtitle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.statusValue,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: _statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(item.rowIcon, size: 13, color: item.rowNoteColor),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  item.rowNote,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: item.rowNoteColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (item.actionLabel != null)
                GestureDetector(
                  onTap: () {
                    // TODO: open maintenance guide
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item.actionLabel!,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.orange,
                      ),
                    ),
                  ),
                )
              else if (item.trailingNote != null)
                Text(
                  item.trailingNote!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.subtitle,
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
// DOWNLOAD REPORT BUTTON (dark full-width card)
// ───────────────────────────────────────────────────────────────────────────
class DownloadReportButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const DownloadReportButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.navBar,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.download, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.white54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// OUTLINED PILL BUTTON ("Order Parts")
// ───────────────────────────────────────────────────────────────────────────
class OutlinedPillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const OutlinedPillButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.orange, width: 1.3),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.orange,
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// PITSTOP CARD
// ───────────────────────────────────────────────────────────────────────────
class PitstopCard extends StatelessWidget {
  final String eyebrow;
  final String status;
  final String dateTime;
  final String place;
  final String location;
  final String directionsDistance;
  final VoidCallback onCallDealer;
  final VoidCallback onDirections;

  const PitstopCard({
    super.key,
    required this.eyebrow,
    required this.status,
    required this.dateTime,
    required this.place,
    required this.location,
    required this.directionsDistance,
    required this.onCallDealer,
    required this.onDirections,
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
                child: Text(
                  eyebrow,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.subtitle,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  size: 15,
                  color: AppColors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  dateTime,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Wrap so "Place • Location" reflows onto a second line on
          // narrow screens instead of clipping.
          Wrap(
            children: [
              Text(
                place,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.teal,
                ),
              ),
              const Text(
                '  •  ',
                style: TextStyle(fontSize: 12.5, color: AppColors.label),
              ),
              Text(
                location,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _PitstopAction(
                  icon: Icons.call,
                  label: 'Call Dealer',
                  onTap: onCallDealer,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PitstopAction(
                  icon: Icons.map_outlined,
                  label: 'Directions ($directionsDistance)',
                  onTap: onDirections,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PitstopAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PitstopAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.teal),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// SMALL SHARED WIDGET (round icon button)
// ───────────────────────────────────────────────────────────────────────────
class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  const _RoundIconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        boxShadow: neuShadows(d: 3, blur: 6),
      ),
      child: Icon(icon, size: 15, color: AppColors.navy),
    );
  }
}
