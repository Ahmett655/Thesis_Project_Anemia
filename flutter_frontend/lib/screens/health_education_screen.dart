import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../theme/app_design.dart';
import '../widgets/home_button.dart';
import '../widgets/theme_toggle_button.dart';

/// Static, fully-offline health education about anemia (Somali).
/// No API or internet needed — always available.
class HealthEducationScreen extends StatelessWidget {
  const HealthEducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgPage,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: [
                // Header row
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.borderSubtle),
                        ),
                        child: Icon(Icons.arrow_back_ios_new,
                            color: context.textPrimary, size: 16),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const HomeButton(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Barashada Anemia',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                    const ThemeToggleButton(),
                  ],
                ),
                const SizedBox(height: 16),

                // Hero banner
                FadeSlideIn(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppDesign.brandGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppDesign.glow(AppDesign.rose, opacity: 0.3),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.menu_book_rounded,
                            color: Colors.white, size: 40),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Baro Anemia (Yaraanta Dhiigga)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Aqoontu waa difaaca koowaad — wax walba halkan waa bilaash, internet-na uma baahna.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                FadeSlideIn(
                  delayMs: 120,
                  child: _EduCard(
                    icon: Icons.help_outline,
                    color: AppDesign.rose,
                    title: 'Waa maxay Anemia?',
                    titleEn: 'What is anemia?',
                    body:
                        'Anemia (yaraanta dhiigga) waxay dhacdaa marka jirkaagu uusan lahayn unugyo dhiig cas oo caafimaad qaba oo ku filan, ama hemoglobin-ka uu hooseeyo. Hemoglobin-ku waa borotiinka qaada oksijiinta — markuu yaraado, xubnaha jirku oksijiin kuma filna, taas oo keenta daal, wareer iyo tabar-darro.',
                  ),
                ),
                const SizedBox(height: 12),

                FadeSlideIn(
                  delayMs: 180,
                  child: _EduCard(
                    icon: Icons.sick_outlined,
                    color: AppDesign.amber,
                    title: 'Calaamadaha',
                    titleEn: 'Symptoms',
                    bullets: const [
                      'Daal joogto ah iyo tabar-darro',
                      'Madax wareer iyo madax xanuun',
                      'Maqaarka, cadaadka indhaha ama ciddiyaha oo cirroobay',
                      'Wadne-garaac degdeg ah ama neefta oo kugu yaraata',
                      'Gacmaha iyo cagaha oo qabowga dareema',
                      'Carruurta: cunto-diid, koritaan gaabis ah, ciyaari la\'aan',
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                FadeSlideIn(
                  delayMs: 240,
                  child: _EduCard(
                    icon: Icons.search_outlined,
                    color: AppDesign.indigo,
                    title: 'Sababaha ugu badan',
                    titleEn: 'Common causes',
                    bullets: const [
                      'Bir-yaraan (iron deficiency) — sababta ugu badan',
                      'Nafaqo-darro iyo cunto aan kala duwanayn',
                      'Uur iyo dhiig-bax badan (haweenka)',
                      'Duumada (malaria) iyo gooryaanka mindhicirka',
                      'Fitamiin B12 ama Folate yaraan',
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                FadeSlideIn(
                  delayMs: 300,
                  child: _EduCard(
                    icon: Icons.restaurant_outlined,
                    color: AppDesign.emerald,
                    title: 'Cuntooyinka birta leh',
                    titleEn: 'Iron-rich foods',
                    bullets: const [
                      'Hilib cas, beerka (beer/liver) iyo kalluun',
                      'Digir, misir iyo salbuko',
                      'Isbinaaj iyo khudaar caleen cagaaran leh',
                      'Ukun (xabka jaalaha ah)',
                      'Timir, xabbad iyo lawska',
                      'TALO: Fitamiin C (liin, canjeelo/tufaax) la cun — wuxuu kordhiyaa nuugista birta. Shaaha cuntada ha la qadin — wuxuu yareeyaa nuugista birta.',
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                FadeSlideIn(
                  delayMs: 360,
                  child: _EduCard(
                    icon: Icons.shield_outlined,
                    color: AppDesign.teal,
                    title: 'Ka-hortagga',
                    titleEn: 'Prevention',
                    bullets: const [
                      'Cun cunto kala duwan oo birta leh maalin kasta',
                      'Isticmaal shabag kaneeco (duumada ka hortag)',
                      'Haweenka uurka leh: kaniiniga birta iyo folic acid qaado',
                      'Carruurta: naas-nuujin lix bilood oo buuxda, kadibna cunto nafaqo leh',
                      'Baadhitaan dhiig sannad walba samee haddii ay suurtagal tahay',
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                FadeSlideIn(
                  delayMs: 420,
                  child: _MythsCard(),
                ),
                const SizedBox(height: 12),

                FadeSlideIn(
                  delayMs: 480,
                  child: _EduCard(
                    icon: Icons.local_hospital_outlined,
                    color: AppDesign.rose,
                    title: 'Goorma dhakhtar u tag?',
                    titleEn: 'When to see a doctor',
                    bullets: const [
                      'Daal daran oo aan dhammaanayn iyo wareer joogto ah',
                      'Neefta oo si weyn kugu yaraata',
                      'Wadne-garaac aan caadi ahayn',
                      'Cunug cirroobay oo aan cunin ama daallan',
                      'Natiijada app-kan haddii ay tahay "Khatar Sare" — isla maanta xarun caafimaad aad',
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // CTA: start assessment
                FadeSlideIn(
                  delayMs: 540,
                  child: Pressable(
                    onTap: () =>
                        Navigator.pushNamed(context, '/start-assessment'),
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: AppDesign.brandGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow:
                            AppDesign.glow(AppDesign.rose, opacity: 0.3),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_circle_fill_rounded,
                              color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Hadda is-qiimee',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
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
}

class _EduCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String titleEn;
  final String? body;
  final List<String>? bullets;

  const _EduCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.titleEn,
    this.body,
    this.bullets,
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
        boxShadow: AppDesign.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                      ),
                    ),
                    Text(
                      titleEn,
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: context.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (body != null)
            Text(
              body!,
              style: TextStyle(
                fontSize: 13,
                color: context.textSecondary,
                height: 1.6,
              ),
            ),
          if (bullets != null)
            Column(
              children: [
                for (final b in bullets!)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            b,
                            style: TextStyle(
                              fontSize: 13,
                              color: context.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MythsCard extends StatelessWidget {
  static const List<(String, String)> _myths = [
    (
      'Anemia waxaa keena shaydaan ama isha (il).',
      'Anemia waa xaalad caafimaad oo la baadhi karo lana daweyn karo — sababaheeda waa nafaqo-darro, duumo, gooryaan iyo dhiig-bax.'
    ),
    (
      'Shaah badan oo sonkor leh ayaa dhiigga kordhiya.',
      'Shaahu XATAA wuu yareeyaa nuugista birta. Waxa dhiigga kordhiya waa cunto birta leh (hilib, beer, digir, isbinaaj).'
    ),
    (
      'Anemia waa cudur haweenka keliya ku dhaca.',
      'Ragga iyo carruurtuba way qaadi karaan — carruurta yaryar waxay ka mid yihiin kooxaha ugu khatarta badan.'
    ),
  ];

  const _MythsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderSubtle),
        boxShadow: AppDesign.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppDesign.indigo.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.fact_check_outlined,
                    color: AppDesign.indigo, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Khuraafaad iyo Xaqiiqo',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                      ),
                    ),
                    Text(
                      'Myths vs facts',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: context.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final (myth, fact) in _myths) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppDesign.rose.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppDesign.rose.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.close_rounded,
                          color: AppDesign.rose, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'KHURAAFAAD: $myth',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_rounded,
                          color: AppDesign.emerald, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'XAQIIQO: $fact',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
