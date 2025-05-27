import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Utils/colors.dart';
import 'package:hidaya_app/Utils/DatabaseHelper.dart';

class Supplicationmainscreen extends StatefulWidget {
  final String subcategory;

  const Supplicationmainscreen({super.key, required this.subcategory});

  @override
  State<Supplicationmainscreen> createState() => _SupplicationmainscreenState();
}

class _SupplicationmainscreenState extends State<Supplicationmainscreen> {

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.subcategory,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.getSupplicationsBySubCategory(widget.subcategory),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No supplications found for this subcategory'));
          }

          final supplications = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.02,
              horizontal: screenWidth * 0.04,
            ),
            itemCount: supplications.length,
            itemBuilder: (context, index) {
              final supplication = supplications[index];
              return Card(
                elevation: 4,
                margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch to allow centering
                    children: [
                      Text(
                        supplication['arabic'],
                        style: GoogleFonts.amiri(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        supplication['urdu'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                      ),
                        SizedBox(height: screenHeight * 0.01),
                      //   Text(
                      //     supplication['english'],
                      //     style: GoogleFonts.poppins(
                      //       fontSize: 16,
                      //       fontWeight: FontWeight.w400,
                      //       color: Colors.black,
                      //     ),
                      //     textDirection: TextDirection.ltr,
                      //     textAlign: TextAlign.left,
                      //   ),
                      // SizedBox(height: screenHeight * 0.01),
                      Text(
                        '${supplication['source']}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.center, // Center the source
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}