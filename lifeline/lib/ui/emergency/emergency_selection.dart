// lib/ui/emergency/emergency_selection.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class EmergencySelection extends StatefulWidget {
  const EmergencySelection({super.key});

  @override
  State<EmergencySelection> createState() => _EmergencySelectionState();
}

class _EmergencySelectionState extends State<EmergencySelection>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();

  List<Map<String, dynamic>> _categories = [];
  bool _loading = true;
  String? _error;

  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _loadCategories();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// --------------------------------------------------
  /// FETCH SERVICE CATEGORIES (taxonomy: service_category)
  /// --------------------------------------------------
  Future<void> _loadCategories() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Direct REST call (taxonomy endpoint)
      final cats = await _api.fetchServiceCategories();

      _categories = cats
          .map<Map<String, dynamic>>((c) => {
                'id': c['id'],
                'name': c['name'],
                'slug': c['slug'],
              })
          .toList();

      setState(() => _loading = false);
      _ctrl.forward();
    } catch (e) {
      setState(() {
        _error = 'Unable to load emergency categories';
        _loading = false;
      });
    }
  }

  void _openCategory(
    Map<String, dynamic> category,
    Map<String, dynamic> locationArgs,
  ) {
    Navigator.pushNamed(
      context,
      '/emergency/results',
      arguments: {
        'categoryId': category['id'],
        'categoryName': category['name'],

        // Location
        'lgaId': locationArgs['lgaId'],
        'lgaName': locationArgs['lgaName'],
        'stateId': locationArgs['stateId'],
        'stateName': locationArgs['stateName'],
        'latitude': locationArgs['latitude'],
        'longitude': locationArgs['longitude'],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    final Map<String, dynamic> locationArgs =
        rawArgs is Map<String, dynamic> ? rawArgs : {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('What do you need?'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              // LOCATION CARD
              if ((locationArgs['lgaName'] ?? '').toString().isNotEmpty)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.place),
                    title: Text(
                      'Location: ${locationArgs['lgaName'] ?? locationArgs['stateName']}',
                    ),
                    trailing: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Change'),
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // LOADING
              if (_loading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )

              // ERROR
              else if (_error != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!,
                            style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadCategories,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )

              // GRID
              else
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: _categories.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.05,
                    ),
                    itemBuilder: (context, i) {
                      final cat = _categories[i];
                      final color = _pickColor(i);
                      final icon = _pickIcon(cat['name']);

                      return AnimatedBuilder(
                        animation: _ctrl,
                        builder: (context, child) {
                          final t = Curves.easeOut.transform(
                            (_ctrl.value - (i * 0.06)).clamp(0.0, 1.0),
                          );
                          return Opacity(
                            opacity: t,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - t)),
                              child: child,
                            ),
                          );
                        },
                        child: _CategoryCard(
                          title: cat['name'],
                          icon: icon,
                          color: color,
                          onTap: () => _openCategory(cat, locationArgs),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _pickColor(int i) {
    const palette = [
      Color(0xFFEF4444),
      Color(0xFF3B82F6),
      Color(0xFFFB923C),
      Color(0xFF16A34A),
      Color(0xFFFBBF24),
      Color(0xFF8B5CF6),
      Color(0xFF06B6D4),
    ];
    return palette[i % palette.length];
  }

  IconData _pickIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('hospital') || n.contains('health')) {
      return Icons.local_hospital;
    }
    if (n.contains('police')) return Icons.local_police;
    if (n.contains('fire')) return Icons.local_fire_department;
    if (n.contains('road') || n.contains('frsc')) return Icons.traffic;
    if (n.contains('amotekun')) return Icons.shield;
    return Icons.emergency;
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: color.withOpacity(0.12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 46, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
