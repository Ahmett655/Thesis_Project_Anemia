import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../services/theme_service.dart';
import '../../widgets/home_button.dart';

/// Admin list of assessments, optionally filtered by risk level or
/// guest-only. Opened from the dashboard stat cards.
class AdminAssessmentsScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final int? risk; // 0/1/2 or null = all
  final bool guestOnly;

  const AdminAssessmentsScreen({
    super.key,
    required this.title,
    required this.subtitle,
    this.risk,
    this.guestOnly = false,
  });

  @override
  State<AdminAssessmentsScreen> createState() =>
      _AdminAssessmentsScreenState();
}

class _AdminAssessmentsScreenState extends State<AdminAssessmentsScreen> {
  bool _loading = true;
  List<AdminAssessment> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await AdminService.fetchAssessments(
        risk: widget.risk, guestOnly: widget.guestOnly);
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Color _riskColor(int p) => switch (p) {
        0 => const Color(0xFF26A69A),
        1 => const Color(0xFFFFA726),
        2 => const Color(0xFFE53935),
        _ => const Color(0xFF9E9E9E),
      };

  Future<void> _confirmDelete(AdminAssessment a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tirtir Qiimeyn?'),
        content: const Text('Ma hubtaa inaad tirtirto qiimeyntan?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Maya')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Haa, Tirtir',
                style: TextStyle(color: Color(0xFFE53935))),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final success = await AdminService.deleteAssessment(a.id);
    if (!mounted) return;
    if (success) {
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tirtiristii way fashilantay')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgPage,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: context.bgCard,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: context.borderSubtle),
                          ),
                          child: Icon(Icons.arrow_back_ios_new,
                              color: context.textPrimary, size: 18),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const HomeButton(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: context.textPrimary,
                              ),
                            ),
                            Text(
                              widget.subtitle,
                              style: TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: context.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _load,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: context.bgCard,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: context.borderSubtle),
                          ),
                          child: Icon(Icons.refresh,
                              color: context.textPrimary, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _items.isEmpty
                          ? Center(
                              child: Text('Wax qiimeyn ah ma jiraan',
                                  style: TextStyle(
                                      color: context.textSecondary)),
                            )
                          : RefreshIndicator(
                              onRefresh: _load,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                    20, 8, 20, 24),
                                itemCount: _items.length,
                                itemBuilder: (_, i) =>
                                    _tile(context, _items[i]),
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, AdminAssessment a) {
    final color = _riskColor(a.predictionNumber);
    final d = a.createdAt.toLocal();
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    final owner = a.userName ?? 'Guest';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              a.predictionNumber == 2
                  ? Icons.priority_high
                  : a.predictionNumber == 1
                      ? Icons.warning_amber_rounded
                      : Icons.sentiment_satisfied_alt,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${a.predictionLabel} · ${a.confidence.toStringAsFixed(0)}%',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (a.userName == null
                                ? const Color(0xFF00838F)
                                : const Color(0xFF1565C0))
                            .withOpacity(0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        owner,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: a.userName == null
                              ? const Color(0xFF00838F)
                              : const Color(0xFF1565C0),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${a.category} · $dateStr',
                  style:
                      TextStyle(fontSize: 11, color: context.textMuted),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _confirmDelete(a),
            icon: const Icon(Icons.delete_outline,
                color: Color(0xFFE53935), size: 20),
          ),
        ],
      ),
    );
  }
}
