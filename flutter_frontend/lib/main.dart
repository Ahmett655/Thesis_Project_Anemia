import 'package:flutter/material.dart';
import 'services/theme_service.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/create_password_screen.dart';
import 'screens/auth/password_changed_screen.dart';
import 'screens/assessment/start_assessment_screen.dart';
import 'screens/assessment/category_screen.dart';
import 'screens/assessment/questions/q_age_adults_screen.dart';
import 'screens/assessment/questions/q_age_child_screen.dart';
import 'screens/assessment/questions/q_residence_screen.dart';
import 'screens/assessment/questions/q_education_screen.dart';
import 'screens/assessment/questions/q_wealth_screen.dart';
import 'screens/assessment/questions/q_smoking_screen.dart';
import 'screens/assessment/questions/q_mosquito_screen.dart';
import 'screens/assessment/questions/q_birth_history_screen.dart';
import 'screens/assessment/questions/q_first_birth_age_screen.dart';
import 'screens/assessment/questions/q_married_screen.dart';
import 'screens/assessment/questions/q_husband_screen.dart';
import 'screens/assessment/questions/q_child_weak_screen.dart';
import 'screens/assessment/questions/q_child_tired_screen.dart';
import 'screens/assessment/questions/q_child_pale_screen.dart';
import 'screens/assessment/questions/q_child_food_screen.dart';
import 'screens/assessment/questions/q_men_tired_screen.dart';
import 'screens/assessment/questions/q_men_dizzy_screen.dart';
import 'screens/assessment/questions/q_hemoglobin_screen.dart';
import 'screens/assessment/submit_screen.dart';
import 'screens/assessment/loading_screen.dart';
import 'screens/assessment/result_screen.dart';
import 'screens/assessment/recommendations_screen.dart';
import 'screens/assessment/iron_foods_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/history_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'models/assessment_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance,
      builder: (context, mode, _) => MaterialApp(
        title: 'Anemia Risk Assessment',
        debugShowCheckedModeBanner: false,
        themeMode: mode,
        theme: ThemeService.lightTheme,
        darkTheme: ThemeService.darkTheme,
        initialRoute: '/',
        routes: _routes(),
      ),
    );
  }

  Map<String, WidgetBuilder> _routes() {
    return {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/otp': (context) => const OtpScreen(),
        '/create-password': (context) => const CreatePasswordScreen(),
        '/password-changed': (context) => const PasswordChangedScreen(),
        '/start-assessment': (context) => const StartAssessmentScreen(),
        '/category': (context) => const CategoryScreen(),
        '/q-age-adults': (context) => const QAgeAdultsScreen(),
        '/q-age-child': (context) => const QAgeChildScreen(),
        '/q-residence': (context) => const QResidenceScreen(),
        '/q-education': (context) => const QEducationScreen(),
        '/q-wealth': (context) => const QWealthScreen(),
        '/q-smoking': (context) => const QSmokingScreen(),
        '/q-mosquito': (context) => const QMosquitoScreen(),
        '/q-birth-history': (context) => const QBirthHistoryScreen(),
        '/q-first-birth-age': (context) => const QFirstBirthAgeScreen(),
        '/q-married': (context) => const QMarriedScreen(),
        '/q-husband': (context) => const QHusbandScreen(),
        '/q-child-weak': (context) => const QChildWeakScreen(),
        '/q-child-tired': (context) => const QChildTiredScreen(),
        '/q-child-pale': (context) => const QChildPaleScreen(),
        '/q-child-food': (context) => const QChildFoodScreen(),
        '/q-men-tired': (context) => const QMenTiredScreen(),
        '/q-men-dizzy': (context) => const QMenDizzyScreen(),
        '/q-hemoglobin': (context) => const QHemoglobinScreen(),
        '/submit': (context) => const SubmitScreen(),
        '/loading': (context) => const LoadingScreen(),
        '/result': (context) => const ResultScreen(),
        '/recommendations': (context) => const RecommendationsScreen(),
        '/iron-foods': (context) => const IronFoodsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/history': (context) => const HistoryScreen(),
        '/admin': (context) => const AdminDashboardScreen(),
    };
  }
}