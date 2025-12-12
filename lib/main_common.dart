import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:kpp_lab/core/repositories/workout_repository.dart';
import 'package:kpp_lab/core/repositories/progress_repository.dart';
import 'package:kpp_lab/features/auth/screens/login_screen.dart';
import 'package:kpp_lab/features/home/screens/home_screen.dart';
import 'package:kpp_lab/features/journal/cubit/workout_cubit.dart';
import 'package:kpp_lab/features/progress/cubit/progress_cubit.dart';
import 'firebase_options.dart';

// --- ОСЬ ЦЬОГО КЛАСУ НЕ ВИСТАЧАЄ BITRISE ---
class AppConfig {
  final String supabaseUrl;
  final String supabaseKey;
  final String sentryDsn;
  final String appTitle;

  AppConfig({
    required this.supabaseUrl,
    required this.supabaseKey,
    required this.sentryDsn,
    required this.appTitle,
  });
}

// --- І ЦІЄЇ ФУНКЦІЇ ---
Future<void> mainCommon(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: config.supabaseUrl,
    anonKey: config.supabaseKey,
  );

  await SentryFlutter.init(
    (options) {
      options.dsn = config.sentryDsn;
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(MyApp(title: config.appTitle)),
  );
}

class MyApp extends StatelessWidget {
  final String title;
  const MyApp({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final workoutRepository = WorkoutRepository();
    final progressRepository = ProgressRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => WorkoutCubit(workoutRepository)..subscribeToWorkouts(),
        ),
        BlocProvider(
          create: (context) => ProgressCubit(progressRepository)..subscribeToPhotos(),
        ),
      ],
      child: MaterialApp(
        title: title,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFFF4F7F6),
          useMaterial3: true,
        ),
        navigatorObservers: [SentryNavigatorObserver()],
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (snapshot.hasData) {
              return const HomeScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
