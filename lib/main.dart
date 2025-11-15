import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hidaya_app/UI/BottomNavLogicImplementation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "apikey.env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(hidaya());
}

class hidaya extends StatefulWidget {
  const hidaya({super.key});

  @override
  State<hidaya> createState() => _hidayaState();

  // Static method to change locale from anywhere in the app
  static void setLocale(BuildContext context, Locale locale) {
    _hidayaState? state = context.findAncestorStateOfType<_hidayaState>();
    state?.setLocale(locale);
  }
}

class _hidayaState extends State<hidaya> {
  final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();
  Locale _locale = const Locale('en'); // Default locale

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  // Load saved locale from SharedPreferences
  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('locale') ?? 'en';
    setState(() {
      _locale = Locale(savedLocale);
    });
  }

  // Change locale and save to SharedPreferences
  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      navigatorObservers: [routeObserver],
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ur'), // Urdu
        Locale('ar'), // Arabic
      ],
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => homescreen(),
      },
    );
  }
}