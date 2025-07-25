import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart' as app_auth;//aliased name 
import 'providers/health_data_provider.dart';
import 'screens/splash_login_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();//intialises flutter bindings 
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ); //Initializes Firebase for authentication and cloud storage
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HealthDataProvider()),//health data provider 
        ChangeNotifierProxyProvider<HealthDataProvider, app_auth.AuthProvider>(
          create: (context) {
            final authProvider = app_auth.AuthProvider();
            final healthDataProvider =
                Provider.of<HealthDataProvider>(context, listen: false);
            authProvider.setHealthDataProvider(healthDataProvider);
            // Initialize the auth provider
            authProvider.initialize();
            return authProvider;
          },
          //update the method here 
          update: (context, healthDataProvider, authProvider) {
            authProvider?.setHealthDataProvider(healthDataProvider);
            return authProvider!;
          },
        ),
      ],//main app widget 
      child: MaterialApp(
        title: 'HealthTrack360',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(                      //listening to authstate changes
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        }

        // If user is logged in, initialize auth provider and go to main app
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;//get user data 
          // Initialize auth provider with current user
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final authProvider =
                Provider.of<app_auth.AuthProvider>(context, listen: false);
            authProvider.initializeFromFirebaseUser(user);//intialise with user 
          });
          return const MainNavigationScreen();
        }

        // If not logged in, show login screen
        return const SplashLoginScreen();
      },
    );
  }
}
