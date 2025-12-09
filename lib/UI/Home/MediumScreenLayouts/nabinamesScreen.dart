import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Utils/colors.dart';

class NabiNamesScreenMedium extends StatelessWidget {
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
                itemCount: asmaMuhammad.length,
                itemBuilder: (context, index) {
                  final name = asmaMuhammad[index];
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
  final List<Map<String,String>> asmaMuhammad = [
    {
      "number": "1",
      "arabic": "مُحَمَّد",
      "transliteration": "Muhammad",
      "urdu": "بہت زیادہ تعریف کیا گیا",
      "english": "Oft-Praised"
    },
    {
      "number": "2",
      "arabic": "أَحْمَد",
      "transliteration": "Ahmad",
      "urdu": "زیادہ تعریف کیا گیا",
      "english": "Most Praised"
    },
    {
      "number": "3",
      "arabic": "حَامِد",
      "transliteration": "Hamid",
      "urdu": "تعریف کرنے والا",
      "english": "Praiser"
    },
    {
      "number": "4",
      "arabic": "مَحْمُود",
      "transliteration": "Mahmood",
      "urdu": "قابل تعریف",
      "english": "Praiseworthy"
    },
    {
      "number": "5",
      "arabic": "قَاسِم",
      "transliteration": "Qasim",
      "urdu": "بانٹنے والا",
      "english": "Distributor"
    },
    {
      "number": "6",
      "arabic": "عَاقِب",
      "transliteration": "Aaqib",
      "urdu": "آخری آنے والا",
      "english": "The Last"
    },
    {
      "number": "7",
      "arabic": "فَاتِح",
      "transliteration": "Fatih",
      "urdu": "فتح دینے والا",
      "english": "Opener"
    },
    {
      "number": "8",
      "arabic": "شَاهِد",
      "transliteration": "Shahid",
      "urdu": "گواہ",
      "english": "Witness"
    },
    {
      "number": "9",
      "arabic": "مَشْهُود",
      "transliteration": "Mashhood",
      "urdu": "جس کی گواہی دی گئی",
      "english": "Witnessed"
    },
    {
      "number": "10",
      "arabic": "بَشِير",
      "transliteration": "Basheer",
      "urdu": "خوشخبری دینے والا",
      "english": "Bearer of Good News"
    },
    {
      "number": "11",
      "arabic": "نَذِير",
      "transliteration": "Nazeer",
      "urdu": "ڈرانے والا",
      "english": "Warner"
    },
    {
      "number": "12",
      "arabic": "دَاعِي",
      "transliteration": "Da'i",
      "urdu": "بلانے والا",
      "english": "Caller"
    },
    {
      "number": "13",
      "arabic": "مَهْدِي",
      "transliteration": "Mahdi",
      "urdu": "ہدایت یافتہ",
      "english": "Guided One"
    },
    {
      "number": "14",
      "arabic": "شَافِع",
      "transliteration": "Shafi'",
      "urdu": "شفاعت کرنے والا",
      "english": "Intercessor"
    },
    {
      "number": "15",
      "arabic": "مُشَفَّع",
      "transliteration": "Mushaffa'",
      "urdu": "جس کی شفاعت قبول کی جائے",
      "english": "One Whose Intercession is Accepted"
    },
    {
      "number": "16",
      "arabic": "كَامِل",
      "transliteration": "Kamil",
      "urdu": "مکمل",
      "english": "Perfect"
    },
    {
      "number": "17",
      "arabic": "حَبِيب",
      "transliteration": "Habib",
      "urdu": "محبوب",
      "english": "Beloved"
    },
    {
      "number": "18",
      "arabic": "صَادِق",
      "transliteration": "Sadiq",
      "urdu": "سچا",
      "english": "Truthful"
    },
    {
      "number": "19",
      "arabic": "أَمِين",
      "transliteration": "Ameen",
      "urdu": "امانت دار",
      "english": "Trustworthy"
    },
    {
      "number": "20",
      "arabic": "رَءُوف",
      "transliteration": "Ra'uf",
      "urdu": "نہایت مہربان",
      "english": "Most Kind"
    },
    {
      "number": "21",
      "arabic": "رَحِيم",
      "transliteration": "Rahim",
      "urdu": "رحم کرنے والا",
      "english": "Merciful"
    },
    {
      "number": "22",
      "arabic": "مُجْتَبَى",
      "transliteration": "Mujtaba",
      "urdu": "منتخب کیا گیا",
      "english": "Chosen One"
    },
    {
      "number": "23",
      "arabic": "طَه",
      "transliteration": "Taha",
      "urdu": "طہٰ (قرآنی نام)",
      "english": "Taha (Quranic Name)"
    },
    {
      "number": "24",
      "arabic": "يَس",
      "transliteration": "Yaseen",
      "urdu": "یٰسین (قرآنی نام)",
      "english": "Yaseen (Quranic Name)"
    },
    {
      "number": "25",
      "arabic": "مُزَّمِّل",
      "transliteration": "Muzzammil",
      "urdu": "کپڑوں میں لپٹا ہوا",
      "english": "The Enwrapped"
    },
    {
      "number": "26",
      "arabic": "مُدَّثِّر",
      "transliteration": "Mudathir",
      "urdu": "چادر اوڑھنے والا",
      "english": "The Enshrouded"
    },
    {
      "number": "27",
      "arabic": "عَبْدُ اللَّه",
      "transliteration": "Abdullah",
      "urdu": "اللہ کا بندہ",
      "english": "Servant of Allah"
    },
    {
      "number": "28",
      "arabic": "كَفِيل",
      "transliteration": "Kafeel",
      "urdu": "ضامن",
      "english": "Guarantor"
    },
    {
      "number": "29",
      "arabic": "سَيِّد",
      "transliteration": "Sayyid",
      "urdu": "سردار",
      "english": "Leader"
    },
    {
      "number": "30",
      "arabic": "مُبَشِّر",
      "transliteration": "Mubashir",
      "urdu": "خوشخبری سنانے والا",
      "english": "Bringer of Glad Tidings"
    },
    {
      "number": "31",
      "arabic": "نَاصِر",
      "transliteration": "Nasir",
      "urdu": "مددگار",
      "english": "Helper"
    },
    {
      "number": "32",
      "arabic": "مَنْصُور",
      "transliteration": "Mansoor",
      "urdu": "مدد کیا گیا",
      "english": "Victorious"
    },
    {
      "number": "33",
      "arabic": "نَبِيُّ الرَّحْمَة",
      "transliteration": "Nabiyyur Rahmah",
      "urdu": "رحمت کا نبی",
      "english": "Prophet of Mercy"
    },
    {
      "number": "34",
      "arabic": "نَبِيُّ التَّوْبَة",
      "transliteration": "Nabiyyut Taubah",
      "urdu": "توبہ کا نبی",
      "english": "Prophet of Repentance"
    },
    {
      "number": "35",
      "arabic": "حَرِيصٌ عَلَيْكُم",
      "transliteration": "Harisun Alaikum",
      "urdu": "تمہارے لئے فکر مند",
      "english": "Anxious Over You"
    },
    {
      "number": "36",
      "arabic": "رَسُولُ اللَّه",
      "transliteration": "Rasoolullah",
      "urdu": "اللہ کا رسول",
      "english": "Messenger of Allah"
    },
    {
      "number": "37",
      "arabic": "خَاتَمُ النَّبِيِّين",
      "transliteration": "Khatamun Nabiyyin",
      "urdu": "آخری نبی",
      "english": "Seal of the Prophets"
    },
    {
      "number": "38",
      "arabic": "أَبُو الْقَاسِم",
      "transliteration": "Abul Qasim",
      "urdu": "قاسم کا باپ",
      "english": "Father of Qasim"
    },
    {
      "number": "39",
      "arabic": "أَبُو الطَّاهِر",
      "transliteration": "Abut Tahir",
      "urdu": "طاہر کا باپ",
      "english": "Father of Tahir"
    },
    {
      "number": "40",
      "arabic": "أَبُو إِبْرَاهِيم",
      "transliteration": "Abu Ibrahim",
      "urdu": "ابراہیم کا باپ",
      "english": "Father of Ibrahim"
    },
    {
      "number": "41",
      "arabic": "مُقْتَفِي",
      "transliteration": "Muqtafi",
      "urdu": "پیروی کرنے والا",
      "english": "Follower"
    },
    {
      "number": "42",
      "arabic": "حَاشِر",
      "transliteration": "Hashir",
      "urdu": "اکٹھا کرنے والا",
      "english": "Gatherer"
    },
    {
      "number": "43",
      "arabic": "عَائِد",
      "transliteration": "A'id",
      "urdu": "لوٹنے والا",
      "english": "Returner"
    },
    {
      "number": "44",
      "arabic": "مُقِيمُ السُّنَّة",
      "transliteration": "Muqeemus Sunnah",
      "urdu": "سنت قائم کرنے والا",
      "english": "Establisher of the Sunnah"
    },
    {
      "number": "45",
      "arabic": "مُحْيِي",
      "transliteration": "Muhyi",
      "urdu": "زندگی دینے والا",
      "english": "Reviver"
    },
    {
      "number": "46",
      "arabic": "مُنْجِي",
      "transliteration": "Munji",
      "urdu": "نجات دینے والا",
      "english": "Savior"
    },
    {
      "number": "47",
      "arabic": "مُتَوَكِّل",
      "transliteration": "Mutawakkil",
      "urdu": "بھروسہ کرنے والا",
      "english": "One Who Relies"
    },
    {
      "number": "48",
      "arabic": "مُطِيع",
      "transliteration": "Muti'",
      "urdu": "اطاعت کرنے والا",
      "english": "Obedient"
    },
    {
      "number": "49",
      "arabic": "قَوِي",
      "transliteration": "Qawi",
      "urdu": "طاقتور",
      "english": "Strong"
    },
    {
      "number": "50",
      "arabic": "مَتِين",
      "transliteration": "Mateen",
      "urdu": "مضبوط",
      "english": "Firm"
    },
    {
      "number": "51",
      "arabic": "وَلِيُّ اللَّه",
      "transliteration": "Waliyyullah",
      "urdu": "اللہ کا دوست",
      "english": "Friend of Allah"
    },
    {
      "number": "52",
      "arabic": "صَاحِب",
      "transliteration": "Sahib",
      "urdu": "ساتھی",
      "english": "Companion"
    },
    {
      "number": "53",
      "arabic": "وَاصِل",
      "transliteration": "Wasil",
      "urdu": "ملانے والا",
      "english": "Joiner"
    },
    {
      "number": "54",
      "arabic": "مُبِين",
      "transliteration": "Mubeen",
      "urdu": "واضح کرنے والا",
      "english": "Clear"
    },
    {
      "number": "55",
      "arabic": "مُتَحَدِّث",
      "transliteration": "Mutahaddith",
      "urdu": "بات کرنے والا",
      "english": "Speaker"
    },
    {
      "number": "56",
      "arabic": "مُطَهِّر",
      "transliteration": "Mutahhir",
      "urdu": "پاک کرنے والا",
      "english": "Purifier"
    },
    {
      "number": "57",
      "arabic": "تَيِّب",
      "transliteration": "Tayyib",
      "urdu": "پاک",
      "english": "Pure"
    },
    {
      "number": "58",
      "arabic": "سَيِّدُ الْمُرْسَلِين",
      "transliteration": "Sayyidul Mursaleen",
      "urdu": "رسولوں کا سردار",
      "english": "Leader of the Messengers"
    },
    {
      "number": "59",
      "arabic": "إِمَامُ الْمُتَّقِين",
      "transliteration": "Imamul Muttaqeen",
      "urdu": "پرہیزگاروں کا امام",
      "english": "Leader of the Pious"
    },
    {
      "number": "60",
      "arabic": "حَبِيبُ اللَّه",
      "transliteration": "Habibullah",
      "urdu": "اللہ کا محبوب",
      "english": "Beloved of Allah"
    },
    {
      "number": "61",
      "arabic": "خَلِيلُ اللَّه",
      "transliteration": "Khalilullah",
      "urdu": "اللہ کا دوست",
      "english": "Friend of Allah"
    },
    {
      "number": "62",
      "arabic": "نَجِيُّ اللَّه",
      "transliteration": "Najiyyullah",
      "urdu": "اللہ کا رازدان",
      "english": "Confidant of Allah"
    },
    {
      "number": "63",
      "arabic": "كَلِيمُ اللَّه",
      "transliteration": "Kaleemullah",
      "urdu": "اللہ سے بات کرنے والا",
      "english": "One Who Speaks with Allah"
    },
    {
      "number": "64",
      "arabic": "صَفِيُّ اللَّه",
      "transliteration": "Safiyyullah",
      "urdu": "اللہ کا منتخب",
      "english": "Chosen of Allah"
    },
    {
      "number": "65",
      "arabic": "خَاتِمُ الْأَنْبِيَاء",
      "transliteration": "Khatimul Anbiya",
      "urdu": "انبیاء کا خاتمہ",
      "english": "Seal of the Prophets"
    },
    {
      "number": "66",
      "arabic": "قَائِد",
      "transliteration": "Qa'id",
      "urdu": "رہنما",
      "english": "Leader"
    },
    {
      "number": "67",
      "arabic": "مَهْدِيُّ الْأُمَم",
      "transliteration": "Mahdiyyul Umam",
      "urdu": "امتوں کا ہدایت یافتہ",
      "english": "Guided One of the Nations"
    },
    {
      "number": "68",
      "arabic": "مُؤَمَّل",
      "transliteration": "Mu'ammal",
      "urdu": "امید رکھنے والا",
      "english": "Hopeful"
    },
    {
      "number": "69",
      "arabic": "مَاحِي",
      "transliteration": "Mahi",
      "urdu": "مٹانے والا",
      "english": "Eraser (of Disbelief)"
    },
    {
      "number": "70",
      "arabic": "عَالِم",
      "transliteration": "Aalim",
      "urdu": "علم والا",
      "english": "Knower"
    },
    {
      "number": "71",
      "arabic": "عَارِف",
      "transliteration": "Aarif",
      "urdu": "جاننے والا",
      "english": "Knowledgeable"
    },
    {
      "number": "72",
      "arabic": "مُكْتَسِب",
      "transliteration": "Muktasib",
      "urdu": "حاصل کرنے والا",
      "english": "Acquirer"
    },
    {
      "number": "73",
      "arabic": "جَابِر",
      "transliteration": "Jabir",
      "urdu": "جوڑنے والا",
      "english": "Mender"
    },
    {
      "number": "74",
      "arabic": "مُعِزّ",
      "transliteration": "Mu'izz",
      "urdu": "عزت دینے والا",
      "english": "Honorer"
    },
    {
      "number": "75",
      "arabic": "مُذِلّ",
      "transliteration": "Muzill",
      "urdu": "ذلت دینے والا",
      "english": "Humbler"
    },
    {
      "number": "76",
      "arabic": "سَامِع",
      "transliteration": "Sami'",
      "urdu": "سننے والا",
      "english": "Listener"
    },
    {
      "number": "77",
      "arabic": "شَفِيعُ الْأُمَم",
      "transliteration": "Shafi'ul Umam",
      "urdu": "امتوں کا شفیع",
      "english": "Intercessor of the Nations"
    },
    {
      "number": "78",
      "arabic": "مُكَرَّم",
      "transliteration": "Mukarram",
      "urdu": "عزت دیا گیا",
      "english": "Honored"
    },
    {
      "number": "79",
      "arabic": "مَكِين",
      "transliteration": "Makeen",
      "urdu": "مستحکم",
      "english": "Established"
    },
    {
      "number": "80",
      "arabic": "مَتَاب",
      "transliteration": "Matab",
      "urdu": "لوٹنے کی جگہ",
      "english": "Place of Return"
    },
    {
      "number": "81",
      "arabic": "مُقِيم",
      "transliteration": "Muqeem",
      "urdu": "قائم رہنے والا",
      "english": "Resident"
    },
    {
      "number": "82",
      "arabic": "مُتَكَلِّم",
      "transliteration": "Mutakallim",
      "urdu": "کلام کرنے والا",
      "english": "Speaker"
    },
    {
      "number": "83",
      "arabic": "قَائِم",
      "transliteration": "Qaim",
      "urdu": "کھڑا ہونے والا",
      "english": "Standing"
    },
    {
      "number": "84",
      "arabic": "دَامِغ",
      "transliteration": "Damigh",
      "urdu": "غالب آنے والا",
      "english": "Overpowering"
    },
    {
      "number": "85",
      "arabic": "عَازِم",
      "transliteration": "Aazim",
      "urdu": "عزم والا",
      "english": "Determined"
    },
    {
      "number": "86",
      "arabic": "مُعَلِّم",
      "transliteration": "Mu'allim",
      "urdu": "سکھانے والا",
      "english": "Teacher"
    },
    {
      "number": "87",
      "arabic": "يَتِيم",
      "transliteration": "Yateem",
      "urdu": "یتیم",
      "english": "Orphan"
    },
    {
      "number": "88",
      "arabic": "مَدْعُوّ",
      "transliteration": "Mad'uww",
      "urdu": "بلایا گیا",
      "english": "Called"
    },
    {
      "number": "89",
      "arabic": "جَامِع",
      "transliteration": "Jami'",
      "urdu": "جمع کرنے والا",
      "english": "Gatherer"
    },
    {
      "number": "90",
      "arabic": "مُقْتَدِر",
      "transliteration": "Muqtadir",
      "urdu": "قدرت والا",
      "english": "Powerful"
    },
    {
      "number": "91",
      "arabic": "مُؤَخِّر",
      "transliteration": "Mu'akhir",
      "urdu": "پیچھے کرنے والا",
      "english": "Delayer"
    },
    {
      "number": "92",
      "arabic": "مُقَدِّم",
      "transliteration": "Muqaddim",
      "urdu": "آگے کرنے والا",
      "english": "Advancer"
    },
    {
      "number": "93",
      "arabic": "شَهِير",
      "transliteration": "Shaheer",
      "urdu": "مشہور",
      "english": "Famous"
    },{
      "number": "94",
      "arabic": "مَشْهُور",
      "transliteration": "Mashhoor",
      "urdu": "مشہور",
      "english": "Famous"
    },
    {
      "number": "95",
      "arabic": "رَسُولُ الرَّحْمَة",
      "transliteration": "Rasoolur Rahmah",
      "urdu": "رحمت کا رسول",
      "english": "Messenger of Mercy"
    },
    {
      "number": "96",
      "arabic": "نُورُ الْهُدَى",
      "transliteration": "Noorul Huda",
      "urdu": "ہدایت کا نور",
      "english": "Light of Guidance"
    },
    {
      "number": "97",
      "arabic": "سَيِّدُ الْبَشَر",
      "transliteration": "Sayyidul Bashar",
      "urdu": "انسانوں کا سردار",
      "english": "Leader of Humankind"
    },
    {
      "number": "98",
      "arabic": "حَبِيبُ الْعَالَمِين",
      "transliteration": "Habibul Aalameen",
      "urdu": "عالموں کا محبوب",
      "english": "Beloved of the Worlds"
    },
    {
      "number": "99",
      "arabic": "شَفِيعُ الْمُذْنِبِين",
      "transliteration": "Shafi'ul Mudhnibeen",
      "urdu": "گناہگاروں کا شفیع",
      "english": "Intercessor of the Sinners"
    },
  ];
}