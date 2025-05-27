import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Utils/colors.dart';

class SupplicationScreen extends StatefulWidget {
  const SupplicationScreen({super.key});

  @override
  State<SupplicationScreen> createState() => _SupplicationScreenState();
}

class _SupplicationScreenState extends State<SupplicationScreen> {
  // List of dummy data for 9 cards
  final List<Map<String, dynamic>> supplications = List.generate(
    9,
        (index) => {
      'number': (index + 1).toString().padLeft(2, '0'), // Format as 01, 02, ..., 09
      'text1': 'توبہ و استغفار',
      'text2': '6 دعائیں',
    },
  );

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Supplication',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF44C17B), // Start color
                Color(0xFF205B3A), // End color
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: AppColors.background,
      body: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02, horizontal: screenWidth * 0.04),
        itemCount: supplications.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            margin: EdgeInsets.only(bottom: screenHeight * 0.02),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      //image
                      ClipRRect(
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(15)),
                        child: Image.asset(
                          'assets/images/prayer_bg.png',
                          width: screenWidth * 0.7,
                          height: screenHeight * 0.15,
                          fit: BoxFit.cover,
                        ),
                      ),
                      //texts
                      Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.only(right: screenWidth*0.03),
                          child: Column(
                            mainAxisAlignment:MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                supplications[index]['text1'],
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                supplications[index]['text2'],
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        supplications[index]['number'],
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF44C17B), // Green color matching your app theme
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}