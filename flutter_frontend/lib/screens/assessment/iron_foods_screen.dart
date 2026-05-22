import 'package:flutter/material.dart';
import '../../services/theme_service.dart';

/// Detail screen showing iron-rich foods with images and full info.
class IronFoodsScreen extends StatelessWidget {
  const IronFoodsScreen({super.key});

  static const _foods = <_IronFood>[
    _IronFood(
      somali: 'Beerka iyo Hilibka cas',
      english: 'Liver & Red Meat',
      ironMg: 6.5,
      ironCategory: 'Sare aad u sareeysa (Very High)',
      image:
          'https://images.unsplash.com/photo-1558030006-450675393462?w=400',
      icon: Icons.set_meal,
      benefits:
          'Beerka iyo hilibka cas waxay leeyihiin heme iron, oo ah qaab fudud loo nuugo. Wuxuu kor u qaadaa heerka hemoglobin si dhakhso ah.',
      benefitsEng:
          'Liver and red meat contain heme iron, which is easily absorbed. They quickly increase hemoglobin levels.',
      preparation:
          'Kari fiican; 2-3 jeer todobaadkii waa ku filan. Iska ilaali daawayn dheer si ilaali ku jirinaeyaha.',
      preparationEng:
          'Cook thoroughly; 2-3 times per week is sufficient. Avoid overcooking to preserve nutrients.',
      color: Color(0xFFC62828),
    ),
    _IronFood(
      somali: 'Khudaarta Cagaarka ah',
      english: 'Dark Leafy Greens (Spinach, Kale)',
      ironMg: 3.6,
      ironCategory: 'Sare (High)',
      image:
          'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400',
      icon: Icons.eco,
      benefits:
          'Spinach, kale, iyo khudaarta cagaaran kale waxay leeyihiin iron iyo folate. Sidoo kale waa ilo qani ku ah Vitamin C oo caawiya nuugida birta.',
      benefitsEng:
          'Spinach, kale, and other dark leafy greens contain iron and folate. They are also rich in Vitamin C which aids iron absorption.',
      preparation:
          'Maalin kasta cab cabbita ah ama saxan salad ka samee. Kari xoogaa qudha si aysan u khasaarin nafaqada.',
      preparationEng:
          'Have a serving daily or as a salad. Cook briefly to preserve nutrients.',
      color: Color(0xFF2E7D32),
    ),
    _IronFood(
      somali: 'Digirta iyo Bisbaaska',
      english: 'Beans & Lentils',
      ironMg: 5.0,
      ironCategory: 'Sare aad u sareeysa (Very High)',
      image:
          'https://images.unsplash.com/photo-1515543237350-b3eea1ec8082?w=400',
      icon: Icons.grain,
      benefits:
          'Digirta cas, lentils, iyo chickpeas waa ilo qani ku ah birta. Waxay sidoo kale leeyihiin borotiin iyo fiber.',
      benefitsEng:
          'Red beans, lentils, and chickpeas are excellent iron sources. They also provide protein and fiber.',
      preparation:
          'Iska qabo habeen ka hor; kari ilaa ay nuglaadaan. Ku qaado liinta liimi si aad u kordhiso nuugidda birta.',
      preparationEng:
          'Soak overnight; cook until tender. Pair with lemon for better iron absorption.',
      color: Color(0xFF6D4C41),
    ),
    _IronFood(
      somali: 'Ukunta',
      english: 'Eggs',
      ironMg: 1.2,
      ironCategory: 'Dhexdhexaad (Moderate)',
      image:
          'https://images.unsplash.com/photo-1607690424560-35d967d6ad7f?w=400',
      icon: Icons.egg_outlined,
      benefits:
          'Ukunta gaar ahaan jaalka (yolk) waxay leeyihiin bir iyo Vitamin B12, oo labadaba muhiim u ah samaynta unugyada dhiigga cas.',
      benefitsEng:
          'Eggs, especially the yolk, contain iron and Vitamin B12, both essential for red blood cell production.',
      preparation:
          '1-2 ukun maalintii. Karkarsho ama sameey "omelette" oo aad ku darto khudaarta cagaarka ah.',
      preparationEng:
          '1-2 eggs per day. Boil or make an omelette with green vegetables added.',
      color: Color(0xFFFBC02D),
    ),
    _IronFood(
      somali: 'Kalluunka',
      english: 'Fish (Tuna, Sardines)',
      ironMg: 2.7,
      ironCategory: 'Sare (High)',
      image:
          'https://images.unsplash.com/photo-1535140728325-a4d3707eee94?w=400',
      icon: Icons.set_meal_outlined,
      benefits:
          'Tuna, sardines, iyo kalluun kale waxay leeyihiin bir iyo omega-3. Sidoo kale waxay caawiyaan caafimaadka wadnaha.',
      benefitsEng:
          'Tuna, sardines, and other fish provide iron and omega-3. They also support heart health.',
      preparation:
          '2-3 jeer todobaadkii; grill ama dub. Iska ilaali huurinta xad-dhaaf ah si aanay u baabba\'in nafaqada.',
      preparationEng:
          '2-3 times per week; grill or bake. Avoid deep-frying to preserve nutrients.',
      color: Color(0xFF0277BD),
    ),
    _IronFood(
      somali: 'Khudaar Qalalan',
      english: 'Dried Fruits (Dates, Raisins, Apricots)',
      ironMg: 4.8,
      ironCategory: 'Sare (High)',
      image:
          'https://images.unsplash.com/photo-1599599810769-bcde5a160d32?w=400',
      icon: Icons.spa,
      benefits:
          'Timirta, sabiibka, iyo apricots oo qalalan waxay leeyihiin bir badan iyo tamar dabiici ah. Waxaa fiican shaqaale macaan ka dhigaal.',
      benefitsEng:
          'Dates, raisins, and dried apricots are rich in iron and natural energy. A great healthy snack option.',
      preparation:
          'Konkos yar (handful) maalintii. Sii daa biyo si laga saaro sonkorta dheeraadka ah.',
      preparationEng:
          'A small handful daily. Soak in water to reduce excess sugar.',
      color: Color(0xFFEF6C00),
    ),
    _IronFood(
      somali: 'Lawska iyo Iniinaha',
      english: 'Nuts & Seeds (Pumpkin, Sesame)',
      ironMg: 4.2,
      ironCategory: 'Sare (High)',
      image:
          'https://images.unsplash.com/photo-1599598425947-5380a86230fc?w=400',
      icon: Icons.scatter_plot,
      benefits:
          'Iniinaha bocorka, sisin, iyo lawska waxay leeyihiin bir iyo borotiin. Sidoo kale waxay caawiyaan caafimaadka maskaxda.',
      benefitsEng:
          'Pumpkin seeds, sesame, and nuts contain iron and protein. They also support brain health.',
      preparation:
          'Konkos yar (¼ kob) maalintii. Ku dar salad ama smoothies.',
      preparationEng:
          'A small handful (¼ cup) daily. Add to salads or smoothies.',
      color: Color(0xFF558B2F),
    ),
    _IronFood(
      somali: 'Hilibka digaagga',
      english: 'Chicken (Especially Thighs)',
      ironMg: 1.3,
      ironCategory: 'Dhexdhexaad (Moderate)',
      image:
          'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=400',
      icon: Icons.outdoor_grill,
      benefits:
          'Hilibka digaagga, gaar ahaan bowdooyinka, waxay leeyihiin bir iyo borotiin oo lagu nuugo si fudud.',
      benefitsEng:
          'Chicken, especially thighs, provides easily absorbed iron and protein.',
      preparation:
          '3-4 jeer todobaadkii. Grill, dub, ama maraq u sameey - HA ku dubin saliid badan.',
      preparationEng:
          '3-4 times per week. Grill, bake, or stew - avoid deep frying.',
      color: Color(0xFF795548),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgPage,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              // Gradient header
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 1),
                                ),
                                child: const Icon(Icons.arrow_back_ios_new,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 1),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.restaurant_outlined,
                                      size: 14, color: Colors.white),
                                  SizedBox(width: 6),
                                  Text(
                                    'IRON-RICH',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Cuntooyinka Birta Leh',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Iron-Rich Foods Guide',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Tip box
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFFFD54F).withOpacity(0.5)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_outline,
                          size: 20, color: Color(0xFFFF8F00)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Talo: Ku qaado Vitamin C (sida liinta, oranges) si aad u kordhiso nuugidda birta!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7C5800),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Food list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: _foods.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _FoodCard(food: _foods[index]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IronFood {
  final String somali;
  final String english;
  final double ironMg;
  final String ironCategory;
  final String image;
  final IconData icon;
  final String benefits;
  final String benefitsEng;
  final String preparation;
  final String preparationEng;
  final Color color;

  const _IronFood({
    required this.somali,
    required this.english,
    required this.ironMg,
    required this.ironCategory,
    required this.image,
    required this.icon,
    required this.benefits,
    required this.benefitsEng,
    required this.preparation,
    required this.preparationEng,
    required this.color,
  });
}

class _FoodCard extends StatefulWidget {
  final _IronFood food;
  const _FoodCard({required this.food});

  @override
  State<_FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<_FoodCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final f = widget.food;
    return Container(
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image with overlay
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Stack(
                  children: [
                    Image.network(
                      f.image,
                      width: double.infinity,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 140,
                        color: f.color.withOpacity(0.15),
                        child: Icon(f.icon,
                            size: 64, color: f.color),
                      ),
                    ),
                    // Iron content badge
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.water_drop,
                                size: 12, color: f.color),
                            const SizedBox(width: 4),
                            Text(
                              '${f.ironMg} mg Iron',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Title section
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: f.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child:
                              Icon(f.icon, color: f.color, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                f.somali,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: context.textPrimary,
                                ),
                              ),
                              Text(
                                f.english,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedRotation(
                          turns: _expanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(Icons.keyboard_arrow_down,
                              color: context.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Iron level chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: f.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        f.ironCategory,
                        style: TextStyle(
                          fontSize: 11,
                          color: f.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    // Expanded details
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 250),
                      crossFadeState: _expanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: const SizedBox.shrink(),
                      secondChild: Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _section(
                              context,
                              icon: Icons.favorite_outline,
                              title: 'Faa\'iidooyinka',
                              titleEng: 'Benefits',
                              somali: f.benefits,
                              english: f.benefitsEng,
                              color: f.color,
                            ),
                            const SizedBox(height: 12),
                            _section(
                              context,
                              icon: Icons.kitchen_outlined,
                              title: 'Sida loo Karinaayo',
                              titleEng: 'How to Prepare',
                              somali: f.preparation,
                              english: f.preparationEng,
                              color: f.color,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String titleEng,
    required String somali,
    required String english,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                '$title  ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
              Text(
                '($titleEng)',
                style: TextStyle(
                  fontSize: 11,
                  color: context.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            somali,
            style: TextStyle(
              fontSize: 12.5,
              color: context.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            english,
            style: TextStyle(
              fontSize: 11,
              color: context.textSecondary,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
