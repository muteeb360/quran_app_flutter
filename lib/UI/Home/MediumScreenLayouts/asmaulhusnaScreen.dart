import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AsmaUlHusnaScreenMedium extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Asma-ul-Husna',
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
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.only(top: screenHeight * 0.0),
        color: Theme.of(context).colorScheme.background,
        child: Column(
          children: [
            // Swipeable horizontal list of cards
            Expanded(
              child: PageView.builder(
                reverse: true,
                itemCount: asmaUlHusna.length,
                itemBuilder: (context, index) {
                  final name = asmaUlHusna[index];
                  return Center(
                    child: Container(
                      width: screenWidth * 0.85,
                      height: screenHeight * 0.74,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF44C17B), // Start color
                            Color(0xFF205B3A), // End color
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Top-left floral corner
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Transform.rotate(
                              angle: -math.pi / 2, // -90 degrees
                              child: Image.asset(
                                'assets/images/floral_corner.png',
                                width: screenWidth * 0.15,
                                height: screenWidth * 0.15,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          // Top-right floral corner
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Transform.rotate(
                              angle: 0, // No rotation
                              child: Image.asset(
                                'assets/images/floral_corner.png',
                                width: screenWidth * 0.15,
                                height: screenWidth * 0.15,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          // Bottom-left floral corner
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Transform.rotate(
                              angle: math.pi, // 180 degrees
                              child: Image.asset(
                                'assets/images/floral_corner.png',
                                width: screenWidth * 0.15,
                                height: screenWidth * 0.15,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          // Bottom-right floral corner
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Transform.rotate(
                              angle: math.pi / 2, // 90 degrees
                              child: Image.asset(
                                'assets/images/floral_corner.png',
                                width: screenWidth * 0.15,
                                height: screenWidth * 0.15,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          // Center content
                          Column(
                            children: [
                              // Numbering of names
                              Padding(
                                padding: EdgeInsets.only(top: screenHeight * 0.02),
                                child: Text(
                                  '﴾${name["number"]}﴿',
                                  style: TextStyle(
                                    fontFamily: 'NotoSansArabic',
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              // Arabic text and transliteration
                              Expanded(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Arabic text
                                      Text(
                                        name["arabic"]!,
                                        style: TextStyle(
                                          fontFamily: 'NotoSansArabic',
                                          fontSize: 64,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      // English transliteration
                                      Text(
                                        name["transliteration"]!,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Urdu and English meanings
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: screenHeight * 0.05),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Urdu meaning
                                      Text(
                                        name["urdu"]!,
                                        style: TextStyle(
                                          fontFamily: 'NotoSansArabic',
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      // English meaning
                                      Text(
                                        name["english"]!,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  // List of 99 Names of Allah with transliteration, Urdu, and English meanings
  final List<Map<String, String>> asmaUlHusna = [
    {
      "number": "1",
      "arabic": "الرَّحْمَنُ",
      "transliteration": "AR-RAHMAAN",
      "urdu": "نہایت رحم کرنے والا",
      "english": "The Most Gracious"
    },
    {
      "number": "2",
      "arabic": "الرَّحِيمُ",
      "transliteration": "AR-RAHEEM",
      "urdu": "بے حد رحم کرنے والا",
      "english": "The Most Merciful"
    },
    {
      "number": "3",
      "arabic": "الْمَلِكُ",
      "transliteration": "AL-MALIK",
      "urdu": "بادشاہ",
      "english": "The King"
    },
    {
      "number": "4",
      "arabic": "الْقُدُّوسُ",
      "transliteration": "AL-QUDDUS",
      "urdu": "پاکیزہ",
      "english": "The Most Holy"
    },
    {
      "number": "5",
      "arabic": "السَّلَامُ",
      "transliteration": "AS-SALAM",
      "urdu": "سلامتی دینے والا",
      "english": "The Source of Peace"
    },
    {
      "number": "6",
      "arabic": "الْمُؤْمِنُ",
      "transliteration": "AL-MU'MIN",
      "urdu": "امن دینے والا",
      "english": "The Giver of Security"
    },
    {
      "number": "7",
      "arabic": "الْمُهَيْمِنُ",
      "transliteration": "AL-MUHAYMIN",
      "urdu": "نگہبان",
      "english": "The Protector"
    },
    {
      "number": "8",
      "arabic": "الْعَزِيزُ",
      "transliteration": "AL-AZIZ",
      "urdu": "غالب",
      "english": "The Almighty"
    },
    {
      "number": "9",
      "arabic": "الْجَبَّارُ",
      "transliteration": "AL-JABBAR",
      "urdu": "زبردست",
      "english": "The Compeller"
    },
    {
      "number": "10",
      "arabic": "الْمُتَكَبِّرُ",
      "transliteration": "AL-MUTAKABBIR",
      "urdu": "تکبر کرنے والا",
      "english": "The Supreme"
    },
    {
      "number": "11",
      "arabic": "الْخَالِقُ",
      "transliteration": "AL-KHALIQ",
      "urdu": "پیدا کرنے والا",
      "english": "The Creator"
    },
    {
      "number": "12",
      "arabic": "الْبَارِئُ",
      "transliteration": "AL-BARI",
      "urdu": "وجود بخشنے والا",
      "english": "The Maker"
    },
    {
      "number": "13",
      "arabic": "الْمُصَوِّرُ",
      "transliteration": "AL-MUSAWWIR",
      "urdu": "صورت گر",
      "english": "The Fashioner"
    },
    {
      "number": "14",
      "arabic": "الْغَفَّارُ",
      "transliteration": "AL-GHAFFAR",
      "urdu": "بخشنے والا",
      "english": "The Forgiver"
    },
    {
      "number": "15",
      "arabic": "الْقَهَّارُ",
      "transliteration": "AL-QAHHAR",
      "urdu": "قابو کرنے والا",
      "english": "The Subduer"
    },
    {
      "number": "16",
      "arabic": "الْوَهَّابُ",
      "transliteration": "AL-WAHHAB",
      "urdu": "عطا کرنے والا",
      "english": "The Giver"
    },
    {
      "number": "17",
      "arabic": "الرَّزَّاقُ",
      "transliteration": "AR-RAZZAQ",
      "urdu": "رزق دینے والا",
      "english": "The Provider"
    },
    {
      "number": "18",
      "arabic": "الْفَتَّاحُ",
      "transliteration": "AL-FATTAH",
      "urdu": "کھولنے والا",
      "english": "The Opener"
    },
    {
      "number": "19",
      "arabic": "الْعَلِيمُ",
      "transliteration": "AL-ALIM",
      "urdu": "جاننے والا",
      "english": "The All-Knowing"
    },
    {
      "number": "20",
      "arabic": "الْقَابِضُ",
      "transliteration": "AL-QABID",
      "urdu": "تنگ کرنے والا",
      "english": "The Restrainer"
    },
    {
      "number": "21",
      "arabic": "الْبَاسِطُ",
      "transliteration": "AL-BASIT",
      "urdu": "کشادگی دینے والا",
      "english": "The Expander"
    },
    {
      "number": "22",
      "arabic": "الْخَافِضُ",
      "transliteration": "AL-KHAFID",
      "urdu": "پست کرنے والا",
      "english": "The Abaser"
    },
    {
      "number": "23",
      "arabic": "الرَّافِعُ",
      "transliteration": "AR-RAFI",
      "urdu": "بلند کرنے والا",
      "english": "The Exalter"
    },
    {
      "number": "24",
      "arabic": "الْمُعِزُّ",
      "transliteration": "AL-MU'IZZ",
      "urdu": "عزت دینے والا",
      "english": "The Honorer"
    },
    {
      "number": "25",
      "arabic": "الْمُذِلُّ",
      "transliteration": "AL-MUZILL",
      "urdu": "ذلیل کرنے والا",
      "english": "The Humiliator"
    },
    {
      "number": "26",
      "arabic": "السَّمِيعُ",
      "transliteration": "AS-SAMI",
      "urdu": "سننے والا",
      "english": "The All-Hearing"
    },
    {
      "number": "27",
      "arabic": "الْبَصِيرُ",
      "transliteration": "AL-BASIR",
      "urdu": "دیکھنے والا",
      "english": "The All-Seeing"
    },
    {
      "number": "28",
      "arabic": "الْحَكَمُ",
      "transliteration": "AL-HAKAM",
      "urdu": "فیصلہ کرنے والا",
      "english": "The Judge"
    },
    {
      "number": "29",
      "arabic": "الْعَدْلُ",
      "transliteration": "AL-ADL",
      "urdu": "انصاف کرنے والا",
      "english": "The Just"
    },
    {
      "number": "30",
      "arabic": "اللَّطِيفُ",
      "transliteration": "AL-LATIF",
      "urdu": "باریک بین",
      "english": "The Subtle"
    },
    {
      "number": "31",
      "arabic": "الْخَبِيرُ",
      "transliteration": "AL-KHABIR",
      "urdu": "باخبر",
      "english": "The All-Aware"
    },
    {
      "number": "32",
      "arabic": "الْحَلِيمُ",
      "transliteration": "AL-HALIM",
      "urdu": "بردبار",
      "english": "The Forbearing"
    },
    {
      "number": "33",
      "arabic": "الْعَظِيمُ",
      "transliteration": "AL-AZIM",
      "urdu": "عظیم",
      "english": "The Magnificent"
    },
    {
      "number": "34",
      "arabic": "الْغَفُورُ",
      "transliteration": "AL-GHAFUR",
      "urdu": "بخشنے والا",
      "english": "The Forgiving"
    },
    {
      "number": "35",
      "arabic": "الشَّكُورُ",
      "transliteration": "ASH-SHAKUR",
      "urdu": "شکر کرنے والا",
      "english": "The Grateful"
    },
    {
      "number": "36",
      "arabic": "الْعَلِيُّ",
      "transliteration": "AL-ALI",
      "urdu": "بلند",
      "english": "The Most High"
    },
    {
      "number": "37",
      "arabic": "الْكَبِيرُ",
      "transliteration": "AL-KABIR",
      "urdu": "بڑا",
      "english": "The Great"
    },
    {
      "number": "38",
      "arabic": "الْحَفِيظُ",
      "transliteration": "AL-HAFIZ",
      "urdu": "محافظ",
      "english": "The Preserver"
    },
    {
      "number": "39",
      "arabic": "الْمُقِيتُ",
      "transliteration": "AL-MUQIT",
      "urdu": "روزی دینے والا",
      "english": "The Sustainer"
    },
    {
      "number": "40",
      "arabic": "الْحَسِيبُ",
      "transliteration": "AL-HASIB",
      "urdu": "حساب لینے والا",
      "english": "The Reckoner"
    },
    {
      "number": "41",
      "arabic": "الْجَلِيلُ",
      "transliteration": "AL-JALIL",
      "urdu": "جلال والا",
      "english": "The Majestic"
    },
    {
      "number": "42",
      "arabic": "الْكَرِيمُ",
      "transliteration": "AL-KARIM",
      "urdu": "کریم",
      "english": "The Generous"
    },
    {
      "number": "43",
      "arabic": "الرَّقِيبُ",
      "transliteration": "AR-RAQIB",
      "urdu": "نگران",
      "english": "The Watchful"
    },
    {
      "number": "44",
      "arabic": "الْمُجِيبُ",
      "transliteration": "AL-MUJIB",
      "urdu": "دعا قبول کرنے والا",
      "english": "The Responsive"
    },
    {
      "number": "45",
      "arabic": "الْوَاسِعُ",
      "transliteration": "AL-WASI",
      "urdu": "وسیع",
      "english": "The Vast"
    },
    {
      "number": "46",
      "arabic": "الْحَكِيمُ",
      "transliteration": "AL-HAKIM",
      "urdu": "حکمت والا",
      "english": "The Wise"
    },
    {
      "number": "47",
      "arabic": "الْوَدُودُ",
      "transliteration": "AL-WADUD",
      "urdu": "محبت کرنے والا",
      "english": "The Loving"
    },
    {
      "number": "48",
      "arabic": "الْمَجِيدُ",
      "transliteration": "AL-MAJID",
      "urdu": "بزرگی والا",
      "english": "The Glorious"
    },
    {
      "number": "49",
      "arabic": "الْبَاعِثُ",
      "transliteration": "AL-BA'ITH",
      "urdu": "زندہ کرنے والا",
      "english": "The Resurrector"
    },
    {
      "number": "50",
      "arabic": "الشَّهِيدُ",
      "transliteration": "ASH-SHAHID",
      "urdu": "گواہ",
      "english": "The Witness"
    },
    {
      "number": "51",
      "arabic": "الْحَقُّ",
      "transliteration": "AL-HAQQ",
      "urdu": "حق",
      "english": "The Truth"
    },
    {
      "number": "52",
      "arabic": "الْوَكِيلُ",
      "transliteration": "AL-WAKIL",
      "urdu": "کارساز",
      "english": "The Trustee"
    },
    {
      "number": "53",
      "arabic": "الْقَوِيُّ",
      "transliteration": "AL-QAWI",
      "urdu": "طاقتور",
      "english": "The Strong"
    },
    {
      "number": "54",
      "arabic": "الْمَتِينُ",
      "transliteration": "AL-MATIN",
      "urdu": "مضبوط",
      "english": "The Firm"
    },
    {
      "number": "55",
      "arabic": "الْوَلِيُّ",
      "transliteration": "AL-WALI",
      "urdu": "دوست",
      "english": "The Protector"
    },
    {
      "number": "56",
      "arabic": "الْحَمِيدُ",
      "transliteration": "AL-HAMID",
      "urdu": "قابل تعریف",
      "english": "The Praiseworthy"
    },
    {
      "number": "57",
      "arabic": "الْمُحْصِيُ",
      "transliteration": "AL-MUHSI",
      "urdu": "شمار کرنے والا",
      "english": "The Accounter"
    },
    {
      "number": "58",
      "arabic": "الْمُبْدِئُ",
      "transliteration": "AL-MUBDI",
      "urdu": "شروع کرنے والا",
      "english": "The Originator"
    },
    {
      "number": "59",
      "arabic": "الْمُعِيدُ",
      "transliteration": "AL-MU'ID",
      "urdu": "لوٹانے والا",
      "english": "The Restorer"
    },
    {
      "number": "60",
      "arabic": "الْمُحْيِي",
      "transliteration": "AL-MUHYI",
      "urdu": "زندہ کرنے والا",
      "english": "The Giver of Life"
    },
    {
      "number": "61",
      "arabic": "الْمُمِيتُ",
      "transliteration": "AL-MUMIT",
      "urdu": "موت دینے والا",
      "english": "The Taker of Life"
    },
    {
      "number": "62",
      "arabic": "الْحَيُّ",
      "transliteration": "AL-HAYY",
      "urdu": "زندہ",
      "english": "The Ever-Living"
    },
    {
      "number": "63",
      "arabic": "الْقَيُّومُ",
      "transliteration": "AL-QAYYUM",
      "urdu": "قائم رکھنے والا",
      "english": "The Sustainer"
    },
    {
      "number": "64",
      "arabic": "الْوَاجِدُ",
      "transliteration": "AL-WAJID",
      "urdu": "پانے والا",
      "english": "The Finder"
    },
    {
      "number": "65",
      "arabic": "الْمَاجِدُ",
      "transliteration": "AL-MAJID",
      "urdu": "بزرگی والا",
      "english": "The Noble"
    },
    {
      "number": "66",
      "arabic": "الْوَاحِدُ",
      "transliteration": "AL-WAHID",
      "urdu": "ایک",
      "english": "The One"
    },
    {
      "number": "67",
      "arabic": "الْأَحَدُ",
      "transliteration": "AL-AHAD",
      "urdu": "واحد",
      "english": "The Unique"
    },
    {
      "number": "68",
      "arabic": "الصَّمَدُ",
      "transliteration": "AS-SAMAD",
      "urdu": "بے نیاز",
      "english": "The Eternal"
    },
    {
      "number": "69",
      "arabic": "الْقَادِرُ",
      "transliteration": "AL-QADIR",
      "urdu": "قادر",
      "english": "The Powerful"
    },
    {
      "number": "70",
      "arabic": "الْمُقْتَدِرُ",
      "transliteration": "AL-MUQTADIR",
      "urdu": "کامل قدرت والا",
      "english": "The Omnipotent"
    },
    {
      "number": "71",
      "arabic": "الْمُقَدِّمُ",
      "transliteration": "AL-MUQADDIM",
      "urdu": "آگے کرنے والا",
      "english": "The Expediter"
    },
    {
      "number": "72",
      "arabic": "الْمُؤَخِّرُ",
      "transliteration": "AL-MU'AKHKHIR",
      "urdu": "پیچھے کرنے والا",
      "english": "The Delayer"
    },
    {
      "number": "73",
      "arabic": "الأَوَّلُ",
      "transliteration": "AL-AWWAL",
      "urdu": "پہلا",
      "english": "The First"
    },
    {
      "number": "74",
      "arabic": "الآخِرُ",
      "transliteration": "AL-AKHIR",
      "urdu": "آخری",
      "english": "The Last"
    },
    {
      "number": "75",
      "arabic": "الظَّاهِرُ",
      "transliteration": "AZ-ZAHIR",
      "urdu": "ظاہر",
      "english": "The Manifest"
    },
    {
      "number": "76",
      "arabic": "الْبَاطِنُ",
      "transliteration": "AL-BATIN",
      "urdu": "پوشیدہ",
      "english": "The Hidden"
    },
    {
      "number": "77",
      "arabic": "الْوَالِي",
      "transliteration": "AL-WALI",
      "urdu": "کارساز",
      "english": "The Governor"
    },
    {
      "number": "78",
      "arabic": "الْمُتَعَالِي",
      "transliteration": "AL-MUTA'ALI",
      "urdu": "بلند",
      "english": "The Supreme"
    },
    {
      "number": "79",
      "arabic": "الْبَرُّ",
      "transliteration": "AL-BARR",
      "urdu": "نیکی کرنے والا",
      "english": "The Doer of Good"
    },
    {
      "number": "80",
      "arabic": "التَّوَّابُ",
      "transliteration": "AT-TAWWAB",
      "urdu": "توبہ قبول کرنے والا",
      "english": "The Acceptor of Repentance"
    },
    {
      "number": "81",
      "arabic": "الْمُنْتَقِمُ",
      "transliteration": "AL-MUNTAQIM",
      "urdu": "بدلہ لینے والا",
      "english": "The Avenger"
    },
    {
      "number": "82",
      "arabic": "الْعَفُوُّ",
      "transliteration": "AL-AFUW",
      "urdu": "معاف کرنے والا",
      "english": "The Pardoner"
    },
    {
      "number": "83",
      "arabic": "الرَّءُوفُ",
      "transliteration": "AR-RA'UF",
      "urdu": "مہربان",
      "english": "The Kind"
    },
    {
      "number": "84",
      "arabic": "مَالِكُ الْمُلْكِ",
      "transliteration": "MALIK-UL-MULK",
      "urdu": "بادشاہی کا مالک",
      "english": "The Owner of Sovereignty"
    },
    {
      "number": "85",
      "arabic": "ذُو الْجَلَالِ وَالْإِكْرَامِ",
      "transliteration": "DHU-L-JALALI WA-L-IKRAM",
      "urdu": "جلال اور اکرام والا",
      "english": "The Lord of Majesty and Generosity"
    },
    {
      "number": "86",
      "arabic": "الْمُقْسِطُ",
      "transliteration": "AL-MUQSIT",
      "urdu": "انصاف کرنے والا",
      "english": "The Equitable"
    },
    {
      "number": "87",
      "arabic": "الْجَامِعُ",
      "transliteration": "AL-JAMI",
      "urdu": "جمع کرنے والا",
      "english": "The Gatherer"
    },
    {
      "number": "88",
      "arabic": "الْغَنِيُّ",
      "transliteration": "AL-GHANI",
      "urdu": "بے نیاز",
      "english": "The Self-Sufficient"
    },
    {
      "number": "89",
      "arabic": "الْمُغْنِي",
      "transliteration": "AL-MUGHNI",
      "urdu": "غنی کرنے والا",
      "english": "The Enricher"
    },
    {
      "number": "90",
      "arabic": "الْمَانِعُ",
      "transliteration": "AL-MANI",
      "urdu": "روکنے والا",
      "english": "The Preventer"
    },
    {
      "number": "91",
      "arabic": "الضَّارُّ",
      "transliteration": "AD-DARR",
      "urdu": "نقصان پہنچانے والا",
      "english": "The Afflicter"
    },
    {
      "number": "92",
      "arabic": "النَّافِعُ",
      "transliteration": "AN-NAFI",
      "urdu": "فائدہ پہنچانے والا",
      "english": "The Benefiter"
    },
    {
      "number": "93",
      "arabic": "النُّورُ",
      "transliteration": "AN-NUR",
      "urdu": "روشنی",
      "english": "The Light"
    },
    {
      "number": "94",
      "arabic": "الْهَادِي",
      "transliteration": "AL-HADI",
      "urdu": "ہدایت دینے والا",
      "english": "The Guide"
    },
    {
      "number": "95",
      "arabic": "الْبَدِيعُ",
      "transliteration": "AL-BADI",
      "urdu": "بے مثال",
      "english": "The Originator"
    },
    {
      "number": "96",
      "arabic": "الْبَاقِي",
      "transliteration": "AL-BAQI",
      "urdu": "باقی رہنے والا",
      "english": "The Everlasting"
    },
    {
      "number": "97",
      "arabic": "الْوَارِثُ",
      "transliteration": "AL-WARITH",
      "urdu": "وارث",
      "english": "The Inheritor"
    },
    {
      "number": "98",
      "arabic": "الرَّشِيدُ",
      "transliteration": "AR-RASHID",
      "urdu": "ہدایت دینے والا",
      "english": "The Righteous Teacher"
    },
    {
      "number": "99",
      "arabic": "الصَّبُورُ",
      "transliteration": "AS-SABUR",
      "urdu": "صبر کرنے والا",
      "english": "The Patient"
    },
  ];
}