import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../../models/assessment_data.dart';
import '../../services/theme_service.dart';
import '../../widgets/theme_toggle_button.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int prediction = AssessmentData.predictionNumber;
    final double confidence = AssessmentData.confidence;
    final String label = AssessmentData.predictionLabel;
    final String method = AssessmentData.method;
    final double hbValue = AssessmentData.hemoglobinValue;
    final String category = AssessmentData.category;

    debugPrint(
        '[Result] prediction=$prediction, label=$label, confidence=$confidence, method=$method, hb=$hbValue');

    final config = _getConfig(prediction);

    return Scaffold(
      backgroundColor: context.bgPage,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: CustomScrollView(
              slivers: [
                // App bar with back button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        _IconButton(
                          icon: Icons.arrow_back_ios_new,
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Natiijada Qiimeynta',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: context.textPrimary,
                            ),
                          ),
                        ),
                        const ThemeToggleButton(),
                        _IconButton(
                          icon: Icons.refresh,
                          onTap: () {
                            AssessmentData.reset();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/start-assessment',
                              (route) => false,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Hero section: Big severity badge
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 32, horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            config.heroColor,
                            config.heroColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: config.heroColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Big circle icon
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 76,
                                height: 76,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  config.icon,
                                  size: 42,
                                  color: config.heroColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Risk level label
                          Text(
                            config.riskLabelSomali,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${label.toUpperCase()} ANEMIA RISK',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.85),
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Confidence ring/bar
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'Kalsoonida: ${confidence.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Detail cards
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Confidence card with progress bar
                      _DetailCard(
                        title: 'Kalsoonida (Confidence)',
                        titleEng: 'How certain the system is',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${confidence.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: config.heroColor,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: config.heroColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _confidenceLevel(confidence),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: config.heroColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: (confidence / 100).clamp(0.0, 1.0),
                                minHeight: 10,
                                backgroundColor: const Color(0xFFEDEFF3),
                                valueColor:
                                    AlwaysStoppedAnimation(config.heroColor),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Method + Hemoglobin info row
                      Row(
                        children: [
                          Expanded(
                            child: _MiniStat(
                              icon: Icons.science_outlined,
                              label: 'Habka',
                              value: _methodShort(method),
                              valueColor: const Color(0xFF1565C0),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MiniStat(
                              icon: Icons.bloodtype_outlined,
                              label: 'Hemoglobin',
                              value: hbValue > 0
                                  ? '${hbValue.toStringAsFixed(1)} g/dL'
                                  : 'Lama bixin',
                              valueColor: hbValue > 0
                                  ? const Color(0xFFE53935)
                                  : const Color(0xFF9E9E9E),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Category info
                      _MiniStat(
                        icon: Icons.person_outline,
                        label: 'Qaybta',
                        value: _categoryLabel(category),
                        valueColor: const Color(0xFF6A1B9A),
                        fullWidth: true,
                      ),

                      const SizedBox(height: 16),

                      // Detailed explanation card
                      _DetailCard(
                        title: 'Sharaxaad',
                        titleEng: 'Explanation',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Somali description
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: config.heroColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: config.heroColor.withOpacity(0.2)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.info_outline,
                                      color: config.heroColor, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          config.descSomali,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: context.textPrimary,
                                            height: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          config.descEnglish,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            color: context.textSecondary,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            // What this means
                            Text(
                              config.meaningSomali,
                              style: TextStyle(
                                fontSize: 13,
                                color: context.textSecondary,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // WHO reference card (if WHO method used)
                      if (method.contains('WHO'))
                        _DetailCard(
                          title: 'Tixraac (Reference)',
                          titleEng: 'Clinical Standard',
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1565C0)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.public,
                                    color: Color(0xFF1565C0), size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'World Health Organization (WHO)',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: context.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Qiimayntan waxay raacaysaa heerarka caalamiga ah ee WHO ee qiimeynta anemia.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF455A64),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Action buttons
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/recommendations');
                          },
                          icon: const Icon(Icons.tips_and_updates_outlined,
                              size: 20),
                          label: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Eeg Talooyinka',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'View Recommendations',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: config.heroColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            AssessmentData.reset();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/start-assessment',
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.refresh, size: 20),
                          label: const Text(
                            'Ku celi Qiimeynta',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF455A64),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Disclaimer
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFFFD54F).withOpacity(0.5)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                size: 18, color: Color(0xFFFF8F00)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tani waa qiimeyn awoodda u leh kaaliso oo aan beddeli karin baadhitaan caafimaad ee dhakhtarka. La tasho dhakhtar haddii aad qabto qatar sare.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF7C5800),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _confidenceLevel(double c) {
    if (c >= 90) return 'AAD U SAREEYO';
    if (c >= 70) return 'SARE';
    if (c >= 50) return 'DHEX DHEXAAD';
    return 'HOOSEEYO';
  }

  String _methodShort(String method) {
    if (method.contains('WHO')) return 'WHO Clinical';
    if (method.contains('Machine')) return 'ML Model';
    return method.isEmpty ? 'Unknown' : method;
  }

  String _categoryLabel(String c) {
    if (c == 'women') return 'Haweenka (Women)';
    if (c == 'men') return 'Ragga (Men)';
    if (c == 'children') return 'Carruurta (Children)';
    return c.isEmpty ? 'Unknown' : c;
  }

  _ResultConfig _getConfig(int prediction) {
    switch (prediction) {
      case 0: // Mild / Low Risk
        return _ResultConfig(
          heroColor: const Color(0xFF26A69A),
          icon: Icons.sentiment_satisfied_alt,
          riskLabelSomali: 'Khatar Hooseyso',
          descSomali: 'Waxaad leedahay khatar yaraanta dhiigga oo hooseysa.',
          descEnglish: 'You have a Mild (low) risk of anemia.',
          meaningSomali:
              'Macnaheedu waa in jirkaagu uu leeyahay heerar caafimaad oo wanaagsan oo ku saabsan unugyada dhiigga cas. Sii wad nafaqo wanaagsan oo cunto ah birta leh.',
        );
      case 1: // Moderate
        return _ResultConfig(
          heroColor: const Color(0xFFFFA726),
          icon: Icons.warning_amber_rounded,
          riskLabelSomali: 'Khatar Dhex Dhexaad',
          descSomali:
              'Waxaad leedahay khatar yaraanta dhiigga oo dhexdhexaad ah.',
          descEnglish: 'You have a Moderate risk of anemia.',
          meaningSomali:
              'Macnaheedu waa in heerarka unugyada dhiigga cas ay ka hooseeyaan caadiga. Waxaa fiican in aad la tashato dhakhtar si aad u hesho talo iyo daawayn ku habboon.',
        );
      case 2: // Severe
        return _ResultConfig(
          heroColor: const Color(0xFFE53935),
          icon: Icons.priority_high,
          riskLabelSomali: 'Khatar Sare',
          descSomali:
              'Waxaad leedahay khatar yaraanta dhiigga oo aad u sareeysa.',
          descEnglish: 'You have a Severe (high) risk of anemia.',
          meaningSomali:
              'Macnaheedu waa in heerarka unugyada dhiigga cas ay aad uga hooseeyaan caadiga. Si dhakhso ah u aad caafimaadka oo daawayn ka hel — tani waxay u baahan tahay daryeel caafimaad oo degdeg ah.',
        );
      default: // Error / Unknown
        return _ResultConfig(
          heroColor: const Color(0xFF9E9E9E),
          icon: Icons.help_outline,
          riskLabelSomali: 'Cilad Soo Gashay',
          descSomali: 'Lama heli karin natiijo. Fadlan isku day mar kale.',
          descEnglish: 'No result available. Please try again.',
          meaningSomali:
              'Server-ka lama gaarin. Hubi internetkaaga oo isku day inaad qaado qiimeynta mar kale.',
        );
    }
  }
}

class _ResultConfig {
  final Color heroColor;
  final IconData icon;
  final String riskLabelSomali;
  final String descSomali;
  final String descEnglish;
  final String meaningSomali;

  _ResultConfig({
    required this.heroColor,
    required this.icon,
    required this.riskLabelSomali,
    required this.descSomali,
    required this.descEnglish,
    required this.meaningSomali,
  });
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: context.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: context.textPrimary, size: 18),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final String titleEng;
  final Widget child;

  const _DetailCard({
    required this.title,
    required this.titleEng,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            titleEng,
            style: TextStyle(
              fontSize: 11,
              color: context.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;
  final bool fullWidth;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: valueColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: valueColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: context.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
