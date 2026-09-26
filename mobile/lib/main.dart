import 'package:flutter/material.dart';

import 'features/maintenance/presentation/predictive_maintenance_screen.dart'
    as maintenance;
import 'features/navigation/presentation/route_packs_screen.dart' as route_pack;
import 'features/ride_history/presentation/ride_history_screen.dart' as history;

void main() {
  runApp(const CampApp());
}

class CampApp extends StatelessWidget {
  const CampApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CAMP',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFEBE8DF),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6A00)),
      ),
      home: const maintenance.PredictiveMaintenanceScreen(),
      routes: {
        '/history': (context) => const history.RideHistoryScreen(),
        '/packs': (context) => const route_pack.RoutePacksScreen(),
        '/maintenance': (context) =>
            const maintenance.PredictiveMaintenanceScreen(),
      },
    );
  }
}
