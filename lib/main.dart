import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hidaya_app/UI/BottomNavLogicImplementation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'UI/theme_provider.dart';
import 'UI/theme.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "apikey.env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const hidaya(),
    ),
  );
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
    final themeProvider = Provider.of<ThemeProvider>(context);


    final lightColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF2BAE66),          // Islamic mint green
      onPrimary: Colors.white,
      secondary: Color(0xFFD4AF37),        // Soft gold
      onSecondary: Colors.white,
      background: Color(0xFFF7F3E9),       // Warm sand background
      onBackground: Color(0xFF1F1F1F),     // Deep charcoal text
      surface: Color(0xFFFFFFFF),          // White cards
      onSurface: Color(0xFF2C2C2C),        // Soft black text
      surfaceVariant: Colors.white,   // Subtle beige for inputs
      onSurfaceVariant: Color(0xFF555555), // Secondary text
      error: Colors.red,
      onError: Colors.white,
    );

    final darkColorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF3CCF78),          // Lighter emerald green
      onPrimary: Colors.white,
      secondary: Color(0xFFE0C15A),        // Softer gold for contrast
      onSecondary: Colors.black,
      background: Color(0xFF1A1A1A),       // Deep onyx background
      onBackground: Color(0xFFEDEDED),     // Snow white text
      surface: Color(0xFF1A1A1A),          // Dark cards
      onSurface: Color(0xFFE0E0E0),        // Light grey text
      surfaceVariant: Color(0xFF2A2A2A),   // Input/search field dark bg
      onSurfaceVariant: Color(0xFFB5B5B5), // Secondary text
      error: Colors.redAccent,
      onError: Colors.black,
    );

    return MaterialApp(
      navigatorKey: navigatorKey,
      navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ur'),
        Locale('ar'),
      ],

//Theme Section
      theme: ThemeData(
        brightness: Brightness.light,
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: lightColorScheme,
        useMaterial3: true,
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: darkColorScheme,
        useMaterial3: true,
      ),

      themeMode: themeProvider.themeMode, // 👈 works with switch

      initialRoute: '/',
      routes: {
        '/': (context) => homescreen(),
      },
    );
  }
}