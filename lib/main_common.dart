import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:kpp_lab/core/repositories/workout_repository.dart';
import 'package:kpp_lab/features/auth/screens/login_screen.dart';
import 'package:kpp_lab/features/home/screens/home_screen.dart';
import 'package:kpp_lab/features/journal/cubit/workout_cubit.dart';
import 'firebase_options.dart';
import 'package:kpp_lab/core/repositories/progress_repository.dart'; 
import 'package:kpp_lab/features/progress/cubit/progress_cubit.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

await Supabase.initialize(
    url: 'https://wempucsqrvtfboigmcer.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndlbXB1Y3NxcnZ0ZmJvaWdtY2VyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU0NzU1MTUsImV4cCI6MjA4MTA1MTUxNX0.MECLdBYhmK2CZPvti2rYwDCYVfCUYqRFa4C4O7SF8c0',
  );

  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://5f76c7d4ea0302fe7336959762d9b6b2@o4510438545096704.ingest.de.sentry.io/4510438548373584';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        title: 'FitTrack',
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