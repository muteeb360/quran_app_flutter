import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hidaya_app/UI/BottomNavLogicImplementation.dart';
import 'package:flutter/rendering.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(hidaya());
}

class hidaya extends StatelessWidget {
  hidaya({super.key});
  final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme, // Applies Poppins to default text theme
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/', // Starting route
      routes: {
        '/': (context) => homescreen(),        // Home route
      },
    );
  }
}
