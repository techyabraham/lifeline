// lib/ui/results/results_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/api_service.dart';
import '../../services/call_service.dart';
import '../../models/emergency_contact.dart';
import '../../config/design_system.dart';
import '../widgets/design_widgets.dart';
import '../calling/calling_screen.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final ApiService _api = ApiService();

  bool _loading = true;
  String? _error;

  List<EmergencyContact> _contacts = [];
  final Map<int, double> _distanceKm = {};

  bool _notifyContacts = false;

  int? categoryId;
  String? categoryName;
  int? lgaId;
  String? lgaName;
  int? stateId;
  String? stateName;
  double? userLat;
  double? userLng;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
  }

  Future<void> _loadInitial() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {};

    categoryId = args['categoryId'];
    categoryName = args['categoryName'];

    lgaId = args['lgaId'];
    lgaName = args['lgaName'];
    stateId = args['stateId'];
    stateName = args['stateName'];

    userLat = args['latitude'];
    userLng = args['longitude'];

    if (userLat == null || userLng == null) {
      try {
        final pos = await Geolocator.getLastKnownPosition();
        if (pos != null) {
          userLat = pos.latitude;
          userLng = pos.longitude;
        }
      } catch (_) {}
    }

    await _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _loading = true;
      _error = null;
      _distanceKm.clear();
    });

    try {
      final fetched = await _api.fetchContacts(
        serviceCategoryId: categoryId,
        stateId: stateId,
        lgaId: lgaId,
      );

      for (final c in fetched) {
        double dist = double.infinity;

        if (userLat != null &&
            userLng != null &&
            c.latitude != null &&
            c.longitude != null) {
          dist = Geolocator.distanceBetween(
                userLat!,
                userLng!,
                c.latitude!,
                c.longitude!,
              ) /
              1000;
        }

        _distanceKm[c.id] = dist;
      }

      fetched.sort((a, b) => (_distanceKm[a.id] ?? double.infinity)
          .compareTo(_distanceKm[b.id] ?? double.infinity));

      setState(() {
        _contacts = fetched;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load emergency providers';
        _loading = false;
      });
    }
  }

  Future<void> _dial(EmergencyContact c) async {
    if (_notifyContacts) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifying your contacts...')),
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallingScreen(providerName: c.name, phone: c.phoneNumber),
      ),
    );
    await CallService.call(context, c.phoneNumber);
  }

  Future<void> _openMaps(EmergencyContact c) async {
    if (c.latitude != null && c.longitude != null) {
      final geo = Uri.parse(
          'geo:${c.latitude},${c.longitude}?q=${Uri.encodeComponent(c.name)}');

      if (await canLaunchUrl(geo)) {
        await launchUrl(geo);
        return;
      }
    }

    final query = Uri.encodeComponent('${c.name} ${c.address}');
    final web =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    if (await canLaunchUrl(web)) {
      await launchUrl(web);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = categoryName ?? 'Emergency';
    final locationText = lgaName ?? stateName ?? 'Unknown location';

    return Scaffold(
      backgroundColor: AppDesignColors.gray50,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
            decoration: BoxDecoration(
              gradient: AppGradients.service(AppDesignColors.primary),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Nearest • $title',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(locationText, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(color: AppDesignColors.gray200),
                      boxShadow: AppShadows.subtle,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications, color: AppDesignColors.primary),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('Notify emergency contacts', style: AppTextStyles.body),
                        ),
                        Switch(
                          value: _notifyContacts,
                          onChanged: (v) => setState(() => _notifyContacts = v),
                          activeColor: AppDesignColors.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_loading)
                    const Expanded(
                      child: LoadingState(message: 'Loading providers...'),
                    )
                  else if (_error != null)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 8),
                            PrimaryButton(
                              label: 'Retry',
                              onPressed: _loadContacts,
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_contacts.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text('No emergency providers found'),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _contacts.length,
                        itemBuilder: (_, index) {
                          final c = _contacts[index];
                          final dist = _distanceKm[c.id];

                          return _ProviderCard(
                            contact: c,
                            distanceKm: dist,
                            rank: index + 1,
                            onCall: () => _dial(c),
                            onMap: () => _openMaps(c),
                          );
                        },
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

class _ProviderCard extends StatelessWidget {
  final EmergencyContact contact;
  final double? distanceKm;
  final int rank;
  final VoidCallback onCall;
  final VoidCallback onMap;

  const _ProviderCard({
    required this.contact,
    required this.distanceKm,
    required this.rank,
    required this.onCall,
    required this.onMap,
  });

  @override
  Widget build(BuildContext context) {
    final etaMinutes = distanceKm != null
        ? (distanceKm! / 30 * 60).round()
        : null;
    final badge = rank == 1 ? '??' : rank == 2 ? '??' : rank == 3 ? '??' : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (badge != null)
                          Text(badge, style: const TextStyle(fontSize: 18)),
                        if (badge != null) const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            contact.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                        ),
                        if (contact.isVerified) const VerifiedBadge(),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(contact.phoneNumber,
                        style: const TextStyle(
                            fontSize: 12, color: AppDesignColors.gray500)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.navigation,
                            size: 14, color: AppDesignColors.success),
                        const SizedBox(width: 6),
                        Text(
                          distanceKm != null
                              ? '${distanceKm!.toStringAsFixed(1)} km'
                              : '—',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time,
                            size: 14, color: AppDesignColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          etaMinutes != null ? '$etaMinutes min' : '—',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Call Now',
                  icon: Icons.call,
                  color: AppDesignColors.success,
                  onPressed: onCall,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: onMap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppDesignColors.gray700,
                  side: const BorderSide(color: AppDesignColors.gray200),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                ),
                child: const Icon(Icons.navigation),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
