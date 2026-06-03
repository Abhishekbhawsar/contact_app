import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/contact_remote_datasource.dart';
import 'data/repositories/contact_repository.dart';
import 'firebase_options.dart';
import 'providers/contact_provider.dart';
import 'providers/internet_provider.dart';
import 'screens/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  var firebaseConfigured = false;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
        .timeout(const Duration(seconds: 10));
    firebaseConfigured = true;
  } on Object {
    firebaseConfigured = false;
  }

  runApp(
    MyApp(
      repository: firebaseConfigured
          ? FirestoreContactRepository(ContactRemoteDataSource())
          : null,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.repository, this.internetProvider});

  final ContactRepository? repository;
  final InternetProvider? internetProvider;

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
      home: repository == null ? const FirebaseSetupScreen() : const HomeScreen(),
    );

    if (repository == null) return app;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = internetProvider ?? InternetProvider();
            provider.startMonitoring();
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => ContactProvider(repository!)..fetchContacts(),
        ),
      ],
      child: app,
    );
  }
}

class FirebaseSetupScreen extends StatelessWidget {
  const FirebaseSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appName)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off_outlined,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  AppStrings.firebaseNotConfiguredTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text(
                  AppStrings.firebaseNotConfiguredMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
