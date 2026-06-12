import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../services/theme_service.dart';
import '../../widgets/home_button.dart';

/// Admin view of a single user: profile info, all their assessments,
/// and management actions (delete user/assessment, reset password).
class AdminUserDetailScreen extends StatefulWidget {
  final String userId;
  const AdminUserDetailScreen({super.key, required this.userId});

  @override
  State<AdminUserDetailScreen> createState() =>
      _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  bool _loading = true;
  AdminUserDetail? _detail;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final d = await AdminService.fetchUserDetail(widget.userId);
    if (!mounted) return;
    setState(() {
      _detail = d;
      _loading = false;
    });
  }

  Color _riskColor(int p) => switch (p) {
        0 => const Color(0xFF26A69A),
        1 => const Color(0xFFFFA726),
        2 => const Color(0xFFE53935),
        _ => const Color(0xFF9E9E9E),
      };

  Future<void> _confirmDeleteUser() async {
    final u = _detail!.user;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tirtir User?'),
        content: Text(
            'Ma hubtaa inaad tirtirto "${u.name}" iyo dhammaan qiimeynihiisa? Tan lama soo celin karo.'),
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
    final success = await AdminService.deleteUser(u.id);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tirtiristii way fashilantay')),
      );
    }
  }

  Future<void> _confirmDeleteAssessment(AdminAssessment a) async {
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
      _changed = true;
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tirtiristii way fashilantay')),
      );
    }
  }

  Future<void> _resetPassword() async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Password Cusub'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Ugu yaraan 6 xaraf',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Ka noqo')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Beddel')),
        ],
      ),
    );
    if (ok != true) return;
    final pwd = controller.text.trim();
    if (pwd.length < 6) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password-ku waa inuu ugu yaraan 6 xaraf yahay')),
      );
      return;
    }
    final success =
        await AdminService.resetUserPassword(widget.userId, pwd);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(success
              ? 'Password-ka waa la beddelay'
              : 'Beddelkii wuu fashilmay')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgPage,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _detail == null
                    ? Center(
                        child: Text('User lama helin',
                            style:
                                TextStyle(color: context.textSecondary)),
                      )
                    : _body(context),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final u = _detail!.user;
    final assessments = _detail!.assessments;
    final d = u.createdAt.toLocal();
    final joined =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    return Column(
      children: [
        // App bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context, _changed),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.borderSubtle),
                  ),
                  child: Icon(Icons.arrow_back_ios_new,
                      color: context.textPrimary, size: 18),
                ),
              ),
              const SizedBox(width: 6),
              const HomeButton(),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'User Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              // User card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.borderSubtle),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          u.name.isNotEmpty
                              ? u.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(u.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: context.textPrimary,
                              )),
                          const SizedBox(height: 2),
                          Text(u.email,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: context.textSecondary)),
                          const SizedBox(height: 2),
                          Text('Joined: $joined',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: context.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Admin actions
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: _resetPassword,
                        icon: const Icon(Icons.lock_reset, size: 18),
                        label: const Text('Reset Password',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1565C0),
                          side: const BorderSide(
                              color: Color(0xFF1565C0), width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: _confirmDeleteUser,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Tirtir User',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE53935),
                          side: const BorderSide(
                              color: Color(0xFFE53935), width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Text(
                'Qiimeynaha (${assessments.length})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              if (assessments.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: Text('Qiimeyn ma jirto',
                        style:
                            TextStyle(color: context.textSecondary)),
                  ),
                ),

              ...assessments.map((a) {
                final color = _riskColor(a.predictionNumber);
                final ad = a.createdAt.toLocal();
                final dateStr =
                    '${ad.day.toString().padLeft(2, '0')}/${ad.month.toString().padLeft(2, '0')}/${ad.year} ${ad.hour.toString().padLeft(2, '0')}:${ad.minute.toString().padLeft(2, '0')}';
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
                            Text(
                              '${a.predictionLabel} · ${a.confidence.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${a.category} · $dateStr',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: context.textMuted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _confirmDeleteAssessment(a),
                        icon: const Icon(Icons.delete_outline,
                            color: Color(0xFFE53935), size: 20),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
