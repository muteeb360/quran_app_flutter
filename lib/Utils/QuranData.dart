class QuranData {
  static const List<Map<String, dynamic>> surahRanges = [
    {"surah_number": 1, "name": "Al-Fatihah", "arabic_name": "الْفَاتِحَة", "verse_count": 6, "start_ayah": 2, "end_ayah": 6},
    {"surah_number": 2, "name": "Al-Baqarah", "arabic_name": "الْبَقَرَة", "verse_count": 286, "start_ayah": 8, "end_ayah": 293},
    {"surah_number": 3, "name": "Aal-E-Imran", "arabic_name": "آلِ عِمْرَان", "verse_count": 200, "start_ayah": 294, "end_ayah": 493},
    {"surah_number": 4, "name": "An-Nisa", "arabic_name": "النِّسَاء", "verse_count": 176, "start_ayah": 494, "end_ayah": 669},
    {"surah_number": 5, "name": "Al-Ma'idah", "arabic_name": "المَائِدَة", "verse_count": 120, "start_ayah": 670, "end_ayah": 789},
    {"surah_number": 6, "name": "Al-An'am", "arabic_name": "الأَنْعَام", "verse_count": 165, "start_ayah": 790, "end_ayah": 954},
    {"surah_number": 7, "name": "Al-A'raf", "arabic_name": "الأَعْرَاف", "verse_count": 206, "start_ayah": 955, "end_ayah": 1160},
    {"surah_number": 8, "name": "Al-Anfal", "arabic_name": "الأَنْفَال", "verse_count": 75, "start_ayah": 1161, "end_ayah": 1235},
    {"surah_number": 9, "name": "At-Tawbah", "arabic_name": "التَّوْبَة", "verse_count": 129, "start_ayah": 1236, "end_ayah": 1364},
    {"surah_number": 10, "name": "Yunus", "arabic_name": "يُونُس", "verse_count": 109, "start_ayah": 1365, "end_ayah": 1473},
    {"surah_number": 11, "name": "Hud", "arabic_name": "هُود", "verse_count": 123, "start_ayah": 1474, "end_ayah": 1596},
    {"surah_number": 12, "name": "Yusuf", "arabic_name": "يُوسُف", "verse_count": 111, "start_ayah": 1597, "end_ayah": 1707},
    {"surah_number": 13, "name": "Ar-Ra'd", "arabic_name": "الرَّعْد", "verse_count": 43, "start_ayah": 1708, "end_ayah": 1750},
    {"surah_number": 14, "name": "Ibrahim", "arabic_name": "إِبْرَاهِيم", "verse_count": 52, "start_ayah": 1751, "end_ayah": 1802},
    {"surah_number": 15, "name": "Al-Hijr", "arabic_name": "الْحِجْر", "verse_count": 99, "start_ayah": 1803, "end_ayah": 1901},
    {"surah_number": 16, "name": "An-Nahl", "arabic_name": "النَّحْل", "verse_count": 128, "start_ayah": 1902, "end_ayah": 2029},
    {"surah_number": 17, "name": "Al-Isra", "arabic_name": "الإِسْرَاء", "verse_count": 111, "start_ayah": 2030, "end_ayah": 2140},
    {"surah_number": 18, "name": "Al-Kahf", "arabic_name": "الْكَهْف", "verse_count": 110, "start_ayah": 2141, "end_ayah": 2250},
    {"surah_number": 19, "name": "Maryam", "arabic_name": "مَرْيَم", "verse_count": 98, "start_ayah": 2251, "end_ayah": 2348},
    {"surah_number": 20, "name": "Taha", "arabic_name": "طَه", "verse_count": 135, "start_ayah": 2349, "end_ayah": 2483},
    {"surah_number": 21, "name": "Al-Anbiya", "arabic_name": "الأَنْبِيَاء", "verse_count": 112, "start_ayah": 2484, "end_ayah": 2595},
    {"surah_number": 22, "name": "Al-Hajj", "arabic_name": "الْحَجّ", "verse_count": 78, "start_ayah": 2596, "end_ayah": 2673},
    {"surah_number": 23, "name": "Al-Mu'minun", "arabic_name": "الْمُؤْمِنُون", "verse_count": 118, "start_ayah": 2674, "end_ayah": 2791},
    {"surah_number": 24, "name": "An-Nur", "arabic_name": "النُّور", "verse_count": 64, "start_ayah": 2792, "end_ayah": 2855},
    {"surah_number": 25, "name": "Al-Furqan", "arabic_name": "الْفُرْقَان", "verse_count": 77, "start_ayah": 2856, "end_ayah": 2932},
    {"surah_number": 26, "name": "Ash-Shu'ara", "arabic_name": "الشُّعَرَاء", "verse_count": 227, "start_ayah": 2933, "end_ayah": 3159},
    {"surah_number": 27, "name": "An-Naml", "arabic_name": "النَّمْل", "verse_count": 93, "start_ayah": 3160, "end_ayah": 3252},
    {"surah_number": 28, "name": "Al-Qasas", "arabic_name": "الْقَصَص", "verse_count": 88, "start_ayah": 3253, "end_ayah": 3340},
    {"surah_number": 29, "name": "Al-Ankabut", "arabic_name": "الْعَنْكَبُوت", "verse_count": 69, "start_ayah": 3341, "end_ayah": 3409},
    {"surah_number": 30, "name": "Ar-Rum", "arabic_name": "الرُّوم", "verse_count": 60, "start_ayah": 3410, "end_ayah": 3469},
    {"surah_number": 31, "name": "Luqman", "arabic_name": "لُقْمَان", "verse_count": 34, "start_ayah": 3470, "end_ayah": 3503},
    {"surah_number": 32, "name": "As-Sajdah", "arabic_name": "السَّجْدَة", "verse_count": 30, "start_ayah": 3504, "end_ayah": 3533},
    {"surah_number": 33, "name": "Al-Ahzab", "arabic_name": "الْأَحْزَاب", "verse_count": 73, "start_ayah": 3534, "end_ayah": 3606},
    {"surah_number": 34, "name": "Saba", "arabic_name": "سَبَأ", "verse_count": 54, "start_ayah": 3607, "end_ayah": 3660},
    {"surah_number": 35, "name": "Fatir", "arabic_name": "فَاطِر", "verse_count": 45, "start_ayah": 3661, "end_ayah": 3705},
    {"surah_number": 36, "name": "Ya-Sin", "arabic_name": "يَا سِين", "verse_count": 83, "start_ayah": 3706, "end_ayah": 3788},
    {"surah_number": 37, "name": "As-Saffat", "arabic_name": "الصَّافَّات", "verse_count": 182, "start_ayah": 3789, "end_ayah": 3970},
    {"surah_number": 38, "name": "Sad", "arabic_name": "ص", "verse_count": 88, "start_ayah": 3971, "end_ayah": 4058},
    {"surah_number": 39, "name": "Az-Zumar", "arabic_name": "الزُّمَر", "verse_count": 75, "start_ayah": 4059, "end_ayah": 4133},
    {"surah_number": 40, "name": "Ghafir", "arabic_name": "غَافِر", "verse_count": 85, "start_ayah": 4134, "end_ayah": 4218},
    {"surah_number": 41, "name": "Fussilat", "arabic_name": "فُصِّلَت", "verse_count": 54, "start_ayah": 4219, "end_ayah": 4272},
    {"surah_number": 42, "name": "Ash-Shura", "arabic_name": "الشُّورَىٰ", "verse_count": 53, "start_ayah": 4273, "end_ayah": 4325},
    {"surah_number": 43, "name": "Az-Zukhruf", "arabic_name": "الزُّخْرُف", "verse_count": 89, "start_ayah": 4326, "end_ayah": 4414},
    {"surah_number": 44, "name": "Ad-Dukhan", "arabic_name": "الدُّخَان", "verse_count": 59, "start_ayah": 4415, "end_ayah": 4473},
    {"surah_number": 45, "name": "Al-Jathiyah", "arabic_name": "الجَاثِيَة", "verse_count": 37, "start_ayah": 4474, "end_ayah": 4510},
    {"surah_number": 46, "name": "Al-Ahqaf", "arabic_name": "الْأَحْقَاف", "verse_count": 35, "start_ayah": 4511, "end_ayah": 4545},
    {"surah_number": 47, "name": "Muhammad", "arabic_name": "مُحَمَّد", "verse_count": 38, "start_ayah": 4546, "end_ayah": 4583},
    {"surah_number": 48, "name": "Al-Fath", "arabic_name": "الْفَتْح", "verse_count": 29, "start_ayah": 4584, "end_ayah": 4612},
    {"surah_number": 49, "name": "Al-Hujurat", "arabic_name": "الحُجُرَات", "verse_count": 18, "start_ayah": 4613, "end_ayah": 4630},
    {"surah_number": 50, "name": "Qaf", "arabic_name": "ق", "verse_count": 45, "start_ayah": 4631, "end_ayah": 4675},
    {"surah_number": 51, "name": "Adh-Dhariyat", "arabic_name": "الذَّارِيَات", "verse_count": 60, "start_ayah": 4676, "end_ayah": 4735},
    {"surah_number": 52, "name": "At-Tur", "arabic_name": "الطُّور", "verse_count": 49, "start_ayah": 4736, "end_ayah": 4784},
    {"surah_number": 53, "name": "An-Najm", "arabic_name": "النَّجْم", "verse_count": 62, "start_ayah": 4785, "end_ayah": 4846},
    {"surah_number": 54, "name": "Al-Qamar", "arabic_name": "الْقَمَر", "verse_count": 55, "start_ayah": 4847, "end_ayah": 4901},
    {"surah_number": 55, "name": "Ar-Rahman", "arabic_name": "الرَّحْمَن", "verse_count": 78, "start_ayah": 4902, "end_ayah": 4979},
    {"surah_number": 56, "name": "Al-Waqi'ah", "arabic_name": "الْوَاقِعَة", "verse_count": 96, "start_ayah": 4980, "end_ayah": 5075},
    {"surah_number": 57, "name": "Al-Hadid", "arabic_name": "الْحَدِيد", "verse_count": 29, "start_ayah": 5076, "end_ayah": 5104},
    {"surah_number": 58, "name": "Al-Mujadila", "arabic_name": "المُجَادَلَة", "verse_count": 22, "start_ayah": 5105, "end_ayah": 5126},
    {"surah_number": 59, "name": "Al-Hashr", "arabic_name": "الْحَشْر", "verse_count": 24, "start_ayah": 5127, "end_ayah": 5150},
    {"surah_number": 60, "name": "Al-Mumtahanah", "arabic_name": "الْمُمْتَحَنَة", "verse_count": 13, "start_ayah": 5151, "end_ayah": 5163},
    {"surah_number": 61, "name": "As-Saff", "arabic_name": "الصَّفّ", "verse_count": 14, "start_ayah": 5164, "end_ayah": 5177},
    {"surah_number": 62, "name": "Al-Jumu'ah", "arabic_name": "الْجُمُعَة", "verse_count": 11, "start_ayah": 5178, "end_ayah": 5188},
    {"surah_number": 63, "name": "Al-Munafiqun", "arabic_name": "الْمُنَافِقُون", "verse_count": 11, "start_ayah": 5189, "end_ayah": 5199},
    {"surah_number": 64, "name": "At-Taghabun", "arabic_name": "التَّغَابُن", "verse_count": 18, "start_ayah": 5200, "end_ayah": 5217},
    {"surah_number": 65, "name": "At-Talaq", "arabic_name": "الطَّلَاق", "verse_count": 12, "start_ayah": 5218, "end_ayah": 5229},
    {"surah_number": 66, "name": "At-Tahrim", "arabic_name": "التَّحْرِيم", "verse_count": 12, "start_ayah": 5230, "end_ayah": 5241},
    {"surah_number": 67, "name": "Al-Mulk", "arabic_name": "الْمُلْك", "verse_count": 30, "start_ayah": 5242, "end_ayah": 5271},
    {"surah_number": 68, "name": "Al-Qalam", "arabic_name": "الْقَلَم", "verse_count": 52, "start_ayah": 5272, "end_ayah": 5323},
    {"surah_number": 69, "name": "Al-Haqqah", "arabic_name": "الْحَاقَّة", "verse_count": 52, "start_ayah": 5324, "end_ayah": 5375},
    {"surah_number": 70, "name": "Al-Ma'arij", "arabic_name": "الْمَعَارِج", "verse_count": 44, "start_ayah": 5376, "end_ayah": 5419},
    {"surah_number": 71, "name": "Nuh", "arabic_name": "نُوح", "verse_count": 28, "start_ayah": 5420, "end_ayah": 5447},
    {"surah_number": 72, "name": "Al-Jinn", "arabic_name": "الْجِنّ", "verse_count": 28, "start_ayah": 5448, "end_ayah": 5475},
    {"surah_number": 73, "name": "Al-Muzzammil", "arabic_name": "الْمُزَّمِّل", "verse_count": 20, "start_ayah": 5476, "end_ayah": 5495},
    {"surah_number": 74, "name": "Al-Muddathir", "arabic_name": "الْمُدَّثِّر", "verse_count": 56, "start_ayah": 5496, "end_ayah": 5551},
    {"surah_number": 75, "name": "Al-Qiyamah", "arabic_name": "الْقِيَامَة", "verse_count": 40, "start_ayah": 5552, "end_ayah": 5591},
    {"surah_number": 76, "name": "Al-Insan", "arabic_name": "الْإِنْسَان", "verse_count": 31, "start_ayah": 5592, "end_ayah": 5622},
    {"surah_number": 77, "name": "Al-Mursalat", "arabic_name": "الْمُرْسَلَات", "verse_count": 50, "start_ayah": 5623, "end_ayah": 5672},
    {"surah_number": 78, "name": "An-Naba", "arabic_name": "النَّبَأ", "verse_count": 40, "start_ayah": 5673, "end_ayah": 5712},
    {"surah_number": 79, "name": "An-Nazi'at", "arabic_name": "النَّازِعَات", "verse_count": 46, "start_ayah": 5713, "end_ayah": 5758},
    {"surah_number": 80, "name": "Abasa", "arabic_name": "عَبَسَ", "verse_count": 42, "start_ayah": 5759, "end_ayah": 5800},
    {"surah_number": 81, "name": "At-Takwir", "arabic_name": "التَّكْوِير", "verse_count": 29, "start_ayah": 5801, "end_ayah": 5829},
    {"surah_number": 82, "name": "Al-Infitar", "arabic_name": "الْإِنْفِطَار", "verse_count": 19, "start_ayah": 5830, "end_ayah": 5848},
    {"surah_number": 83, "name": "Al-Mutaffifin", "arabic_name": "المُطَفِّفِين", "verse_count": 36, "start_ayah": 5849, "end_ayah": 5884},
    {"surah_number": 84, "name": "Al-Inshiqaq", "arabic_name": "الْإِنْشِقَاق", "verse_count": 25, "start_ayah": 5885, "end_ayah": 5909},
    {"surah_number": 85, "name": "Al-Buruj", "arabic_name": "الْبُرُوج", "verse_count": 22, "start_ayah": 5910, "end_ayah": 5931},
    {"surah_number": 86, "name": "At-Tariq", "arabic_name": "الطَّارِق", "verse_count": 17, "start_ayah": 5932, "end_ayah": 5948},
    {"surah_number": 87, "name": "Al-A'la", "arabic_name": "الْأَعْلَىٰ", "verse_count": 19, "start_ayah": 5949, "end_ayah": 5967},
    {"surah_number": 88, "name": "Al-Ghashiyah", "arabic_name": "الْغَاشِيَة", "verse_count": 26, "start_ayah": 5968, "end_ayah": 5993},
    {"surah_number": 89, "name": "Al-Fajr", "arabic_name": "الْفَجْر", "verse_count": 30, "start_ayah": 5994, "end_ayah": 6023},
    {"surah_number": 90, "name": "Al-Balad", "arabic_name": "الْبَلَد", "verse_count": 20, "start_ayah": 6024, "end_ayah": 6043},
    {"surah_number": 91, "name": "Ash-Shams", "arabic_name": "الشَّمْس", "verse_count": 15, "start_ayah": 6044, "end_ayah": 6058},
    {"surah_number": 92, "name": "Al-Layl", "arabic_name": "اللَّيْل", "verse_count": 21, "start_ayah": 6059, "end_ayah": 6079},
    {"surah_number": 93, "name": "Ad-Duha", "arabic_name": "الضُّحَى", "verse_count": 11, "start_ayah": 6080, "end_ayah": 6090},
    {"surah_number": 94, "name": "Ash-Sharh", "arabic_name": "الشَّرْح", "verse_count": 8, "start_ayah": 6091, "end_ayah": 6098},
    {"surah_number": 95, "name": "At-Tin", "arabic_name": "التِّين", "verse_count": 8, "start_ayah": 6099, "end_ayah": 6106},
    {"surah_number": 96, "name": "Al-Alaq", "arabic_name": "الْعَلَق", "verse_count": 19, "start_ayah": 6107, "end_ayah": 6125},
    {"surah_number": 97, "name": "Al-Qadr", "arabic_name": "الْقَدْر", "verse_count": 5, "start_ayah": 6126, "end_ayah": 6130},
    {"surah_number": 98, "name": "Al-Bayyinah", "arabic_name": "الْبَيِّنَة", "verse_count": 8, "start_ayah": 6131, "end_ayah": 6138},
    {"surah_number": 99, "name": "Az-Zalzalah", "arabic_name": "الزَّلْزَلَة", "verse_count": 8, "start_ayah": 6139, "end_ayah": 6146},
    {"surah_number": 100, "name": "Al-Adiyat", "arabic_name": "الْعَادِيَات", "verse_count": 11, "start_ayah": 6147, "end_ayah": 6157},
    {"surah_number": 101, "name": "Al-Qari'ah", "arabic_name": "الْقَارِعَة", "verse_count": 11, "start_ayah": 6158, "end_ayah": 6168},
    {"surah_number": 102, "name": "At-Takathur", "arabic_name": "التَّكَاثُر", "verse_count": 8, "start_ayah": 6169, "end_ayah": 6176},
    {"surah_number": 103, "name": "Al-Asr", "arabic_name": "الْعَصْر", "verse_count": 3, "start_ayah": 6177, "end_ayah": 6179},
    {"surah_number": 104, "name": "Al-Humazah", "arabic_name": "الْهُمَزَة", "verse_count": 9, "start_ayah": 6180, "end_ayah": 6188},
    {"surah_number": 105, "name": "Al-Fil", "arabic_name": "الْفِيل", "verse_count": 5, "start_ayah": 6189, "end_ayah": 6193},
    {"surah_number": 106, "name": "Quraysh", "arabic_name": "قُرَيْش", "verse_count": 4, "start_ayah": 6194, "end_ayah": 6197},
    {"surah_number": 107, "name": "Al-Ma'un", "arabic_name": "المَاعُون", "verse_count": 7, "start_ayah": 6198, "end_ayah": 6204},
    {"surah_number": 108, "name": "Al-Kawthar", "arabic_name": "الْكَوْثَر", "verse_count": 3, "start_ayah": 6205, "end_ayah": 6207},
    {"surah_number": 109, "name": "Al-Kafirun", "arabic_name": "الْكَافِرُون", "verse_count": 6, "start_ayah": 6208, "end_ayah": 6213},
    {"surah_number": 110, "name": "An-Nasr", "arabic_name": "النَّصْر", "verse_count": 3, "start_ayah": 6214, "end_ayah": 6216},
    {"surah_number": 111, "name": "Al-Masad", "arabic_name": "المَسَد", "verse_count": 5, "start_ayah": 6217, "end_ayah": 6221},
    {"surah_number": 112, "name": "Al-Ikhlas", "arabic_name": "الْإِخْلَاص", "verse_count": 4, "start_ayah": 6222, "end_ayah": 6225},
    {"surah_number": 113, "name": "Al-Falaq", "arabic_name": "الْفَلَق", "verse_count": 5, "start_ayah": 6226, "end_ayah": 6230},
    {"surah_number": 114, "name": "An-Nas", "arabic_name": "النَّاس", "verse_count": 6, "start_ayah": 6231, "end_ayah": 6236},
  ];

  static const List<Map<String, dynamic>> parahRanges = [
    {
      "para_number": 1,
      "name_english": "Alif Lam Meem",
      "name_arabic": "آلم",
      "surahs": [
        {
          "surah_number": 1,
          "surah_name": "Al-Fatihah",
          "arabic_name": "الْفَاتِحَة",
          "start_ayah": 2,
          "end_ayah": 7,
          "verses_in_para": 6
        },
        {
          "surah_number": 2,
          "surah_name": "Al-Baqarah",
          "arabic_name": "الْبَقَرَة",
          "start_ayah": 8,
          "end_ayah": 148,
          "verses_in_para": 141
        },
      ],
      "start_ayah": 2,
      "end_ayah": 148,
      "total_verses": 147
    },
    {
      "para_number": 2,
      "name_english": "Sayaqool",
      "name_arabic": "سَيَقُولُ",
      "surahs": [
        {
          "surah_number": 2,
          "surah_name": "Al-Baqarah",
          "arabic_name": "الْبَقَرَة",
          "start_ayah": 149,
          "end_ayah": 259,
          "verses_in_para": 111
        },
      ],
      "start_ayah": 149,
      "end_ayah": 259,
      "total_verses": 111
    },
    {
      "para_number": 3,
      "name_english": "Tilka Ar-Rusul",
      "name_arabic": "تِلْكَ الرُّسُل",
      "surahs": [
        {
          "surah_number": 2,
          "surah_name": "Al-Baqarah",
          "arabic_name": "الْبَقَرَة",
          "start_ayah": 260,
          "end_ayah": 293,
          "verses_in_para": 34
        },
        {
          "surah_number": 3,
          "surah_name": "Aal-E-Imran",
          "arabic_name": "آلِ عِمْرَان",
          "start_ayah": 294,
          "end_ayah": 384,
          "verses_in_para": 91
        },
      ],
      "start_ayah": 260,
      "end_ayah": 384,
      "total_verses": 125
    },
    {
      "para_number": 4,
      "name_english": "Lan Tanalu",
      "name_arabic": "لَنْ تَنَالُوا",
      "surahs": [
        {
          "surah_number": 3,
          "surah_name": "Aal-E-Imran",
          "arabic_name": "آلِ عِمْرَان",
          "start_ayah": 385,
          "end_ayah": 493,
          "verses_in_para": 109
        },
        {
          "surah_number": 4,
          "surah_name": "An-Nisa",
          "arabic_name": "النِّسَاء",
          "start_ayah": 494,
          "end_ayah": 515,
          "verses_in_para": 22
        },
      ],
      "start_ayah": 385,
      "end_ayah": 515,
      "total_verses": 131
    },
    {
      "para_number": 5,
      "name_english": "Wa Al-Muḥsanat",
      "name_arabic": "وَالْمُحْصَنَات",
      "surahs": [
        {
          "surah_number": 4,
          "surah_name": "An-Nisa",
          "arabic_name": "النِّسَاء",
          "start_ayah": 516,
          "end_ayah": 663,
          "verses_in_para": 148
        },
      ],
      "start_ayah": 516,
      "end_ayah": 663,
      "total_verses": 148
    },
    {
      "para_number": 6,
      "name_english": "La Yuḥibbullah",
      "name_arabic": "لَا يُحِبُّ اللَّه",
      "surahs": [
        {
          "surah_number": 4,
          "surah_name": "An-Nisa",
          "arabic_name": "النِّسَاء",
          "start_ayah": 664,
          "end_ayah": 669,
          "verses_in_para": 6
        },
        {
          "surah_number": 5,
          "surah_name": "Al-Ma'idah",
          "arabic_name": "المَائِدَة",
          "start_ayah": 670,
          "end_ayah": 789,
          "verses_in_para": 120
        },
      ],
      "start_ayah": 664,
      "end_ayah": 789,
      "total_verses": 126
    },
    {
      "para_number": 7,
      "name_english": "Wa Idha Sami’u",
      "name_arabic": "وَإِذَا سَمِعُوا",
      "surahs": [
        {
          "surah_number": 6,
          "surah_name": "Al-An'am",
          "arabic_name": "الأَنْعَام",
          "start_ayah": 790,
          "end_ayah": 954,
          "verses_in_para": 165
        },
      ],
      "start_ayah": 790,
      "end_ayah": 954,
      "total_verses": 165
    },
    {
      "para_number": 8,
      "name_english": "Wa A’lamu",
      "name_arabic": "وَاعْلَمُوا",
      "surahs": [
        {
          "surah_number": 7,
          "surah_name": "Al-A'raf",
          "arabic_name": "الأَعْرَاف",
          "start_ayah": 955,
          "end_ayah": 1102,
          "verses_in_para": 148
        },
      ],
      "start_ayah": 955,
      "end_ayah": 1102,
      "total_verses": 148
    },
    {
      "para_number": 9,
      "name_english": "Qala Al-Mala’u",
      "name_arabic": "قَالَ الْمَلَأُ",
      "surahs": [
        {
          "surah_number": 7,
          "surah_name": "Al-A'raf",
          "arabic_name": "الأَعْرَاف",
          "start_ayah": 1103,
          "end_ayah": 1160,
          "verses_in_para": 58
        },
        {
          "surah_number": 8,
          "surah_name": "Al-Anfal",
          "arabic_name": "الأَنْفَال",
          "start_ayah": 1161,
          "end_ayah": 1235,
          "verses_in_para": 75
        },
      ],
      "start_ayah": 1103,
      "end_ayah": 1235,
      "total_verses": 133
    },
    {
      "para_number": 10,
      "name_english": "Wa Alam",
      "name_arabic": "وَاعْلَمْ",
      "surahs": [
        {
          "surah_number": 9,
          "surah_name": "At-Tawbah",
          "arabic_name": "التَّوْبَة",
          "start_ayah": 1236,
          "end_ayah": 1364,
          "verses_in_para": 129
        },
      ],
      "start_ayah": 1236,
      "end_ayah": 1364,
      "total_verses": 129
    },
    {
      "para_number": 11,
      "name_english": "Ya’tudhiroon",
      "name_arabic": "يَعْتَذِرُونَ",
      "surahs": [
        {
          "surah_number": 10,
          "surah_name": "Yunus",
          "arabic_name": "يُونُس",
          "start_ayah": 1365,
          "end_ayah": 1473,
          "verses_in_para": 109
        },
        {
          "surah_number": 11,
          "surah_name": "Hud",
          "arabic_name": "هُود",
          "start_ayah": 1474,
          "end_ayah": 1517,
          "verses_in_para": 44
        },
      ],
      "start_ayah": 1365,
      "end_ayah": 1517,
      "total_verses": 153
    },
    {
      "para_number": 12,
      "name_english": "Wa Mamin Da’abbah",
      "name_arabic": "وَمَا مِنْ دَابَّة",
      "surahs": [
        {
          "surah_number": 11,
          "surah_name": "Hud",
          "arabic_name": "هُود",
          "start_ayah": 1518,
          "end_ayah": 1596,
          "verses_in_para": 79
        },
        {
          "surah_number": 12,
          "surah_name": "Yusuf",
          "arabic_name": "يُوسُف",
          "start_ayah": 1597,
          "end_ayah": 1707,
          "verses_in_para": 111
        },
      ],
      "start_ayah": 1518,
      "end_ayah": 1707,
      "total_verses": 190
    },
    {
      "para_number": 13,
      "name_english": "Wa Ma Ubarriru",
      "name_arabic": "وَمَا أُبَرِّئُ",
      "surahs": [
        {
          "surah_number": 13,
          "surah_name": "Ar-Ra'd",
          "arabic_name": "الرَّعْد",
          "start_ayah": 1708,
          "end_ayah": 1750,
          "verses_in_para": 43
        },
        {
          "surah_number": 14,
          "surah_name": "Ibrahim",
          "arabic_name": "إِبْرَاهِيم",
          "start_ayah": 1751,
          "end_ayah": 1802,
          "verses_in_para": 52
        },
        {
          "surah_number": 15,
          "surah_name": "Al-Hijr",
          "arabic_name": "الْحِجْر",
          "start_ayah": 1803,
          "end_ayah": 1901,
          "verses_in_para": 99
        },
      ],
      "start_ayah": 1708,
      "end_ayah": 1901,
      "total_verses": 194
    },
    {
      "para_number": 14,
      "name_english": "Rubama",
      "name_arabic": "رُبَمَا",
      "surahs": [
        {
          "surah_number": 16,
          "surah_name": "An-Nahl",
          "arabic_name": "النَّحْل",
          "start_ayah": 1902,
          "end_ayah": 2029,
          "verses_in_para": 128
        },
        {
          "surah_number": 17,
          "surah_name": "Al-Isra",
          "arabic_name": "الإِسْرَاء",
          "start_ayah": 2030,
          "end_ayah": 2140,
          "verses_in_para": 111
        },
      ],
      "start_ayah": 1902,
      "end_ayah": 2140,
      "total_verses": 239
    },
    {
      "para_number": 15,
      "name_english": "Subhana Alladhi",
      "name_arabic": "سُبْحَانَ الَّذِي",
      "surahs": [
        {
          "surah_number": 18,
          "surah_name": "Al-Kahf",
          "arabic_name": "الْكَهْف",
          "start_ayah": 2141,
          "end_ayah": 2250,
          "verses_in_para": 110
        },
        {
          "surah_number": 19,
          "surah_name": "Maryam",
          "arabic_name": "مَرْيَم",
          "start_ayah": 2251,
          "end_ayah": 2348,
          "verses_in_para": 98
        },
      ],
      "start_ayah": 2141,
      "end_ayah": 2348,
      "total_verses": 208
    },
    {
      "para_number": 16,
      "name_english": "Qala Alam",
      "name_arabic": "قَالَ أَلَمْ",
      "surahs": [
        {
          "surah_number": 20,
          "surah_name": "Taha",
          "arabic_name": "طَه",
          "start_ayah": 2349,
          "end_ayah": 2483,
          "verses_in_para": 135
        },
        {
          "surah_number": 21,
          "surah_name": "Al-Anbiya",
          "arabic_name": "الأَنْبِيَاء",
          "start_ayah": 2484,
          "end_ayah": 2595,
          "verses_in_para": 112
        },
      ],
      "start_ayah": 2349,
      "end_ayah": 2595,
      "total_verses": 247
    },
    {
      "para_number": 17,
      "name_english": "Iqtaraba",
      "name_arabic": "اقْتَرَبَ",
      "surahs": [
        {
          "surah_number": 22,
          "surah_name": "Al-Hajj",
          "arabic_name": "الْحَجّ",
          "start_ayah": 2596,
          "end_ayah": 2673,
          "verses_in_para": 78
        },
        {
          "surah_number": 23,
          "surah_name": "Al-Mu'minun",
          "arabic_name": "الْمُؤْمِنُون",
          "start_ayah": 2674,
          "end_ayah": 2791,
          "verses_in_para": 118
        },
      ],
      "start_ayah": 2596,
      "end_ayah": 2791,
      "total_verses": 196
    },
    {
      "para_number": 18,
      "name_english": "Qadd Aflaha",
      "name_arabic": "قَدْ أَفْلَحَ",
      "surahs": [
        {
          "surah_number": 24,
          "surah_name": "An-Nur",
          "arabic_name": "النُّور",
          "start_ayah": 2792,
          "end_ayah": 2855,
          "verses_in_para": 64
        },
        {
          "surah_number": 25,
          "surah_name": "Al-Furqan",
          "arabic_name": "الْفُرْقَان",
          "start_ayah": 2856,
          "end_ayah": 2932,
          "verses_in_para": 77
        },
        {
          "surah_number": 26,
          "surah_name": "Ash-Shu'ara",
          "arabic_name": "الشُّعَرَاء",
          "start_ayah": 2933,
          "end_ayah": 3005,
          "verses_in_para": 73
        },
      ],
      "start_ayah": 2792,
      "end_ayah": 3005,
      "total_verses": 214
    },
    {
      "para_number": 19,
      "name_english": "Wa Qala",
      "name_arabic": "وَقَالَ",
      "surahs": [
        {
          "surah_number": 26,
          "surah_name": "Ash-Shu'ara",
          "arabic_name": "الشُّعَرَاء",
          "start_ayah": 3006,
          "end_ayah": 3159,
          "verses_in_para": 154
        },
        {
          "surah_number": 27,
          "surah_name": "An-Naml",
          "arabic_name": "النَّمْل",
          "start_ayah": 3160,
          "end_ayah": 3252,
          "verses_in_para": 93
        },
      ],
      "start_ayah": 3006,
      "end_ayah": 3252,
      "total_verses": 247
    },
    {
      "para_number": 20,
      "name_english": "A’man Khalaqa",
      "name_arabic": "أَمَّنْ خَلَقَ",
      "surahs": [
        {
          "surah_number": 28,
          "surah_name": "Al-Qasas",
          "arabic_name": "الْقَصَص",
          "start_ayah": 3253,
          "end_ayah": 3340,
          "verses_in_para": 88
        },
        {
          "surah_number": 29,
          "surah_name": "Al-Ankabut",
          "arabic_name": "الْعَنْكَبُوت",
          "start_ayah": 3341,
          "end_ayah": 3409,
          "verses_in_para": 69
        },
        {
          "surah_number": 30,
          "surah_name": "Ar-Rum",
          "arabic_name": "الرُّوم",
          "start_ayah": 3410,
          "end_ayah": 3469,
          "verses_in_para": 60
        },
        {
          "surah_number": 31,
          "surah_name": "Luqman",
          "arabic_name": "لُقْمَان",
          "start_ayah": 3470,
          "end_ayah": 3503,
          "verses_in_para": 34
        },
        {
          "surah_number": 32,
          "surah_name": "As-Sajdah",
          "arabic_name": "السَّجْدَة",
          "start_ayah": 3504,
          "end_ayah": 3533,
          "verses_in_para": 30
        },
      ],
      "start_ayah": 3253,
      "end_ayah": 3533,
      "total_verses": 281
    },
    {
      "para_number": 21,
      "name_english": "Utlu Ma Uḥiya",
      "name_arabic": "اتْلُ مَا أُوحِيَ",
      "surahs": [
        {
          "surah_number": 33,
          "surah_name": "Al-Ahzab",
          "arabic_name": "الْأَحْزَاب",
          "start_ayah": 3534,
          "end_ayah": 3606,
          "verses_in_para": 73
        },
        {
          "surah_number": 34,
          "surah_name": "Saba",
          "arabic_name": "سَبَأ",
          "start_ayah": 3607,
          "end_ayah": 3660,
          "verses_in_para": 54
        },
        {
          "surah_number": 35,
          "surah_name": "Fatir",
          "arabic_name": "فَاطِر",
          "start_ayah": 3661,
          "end_ayah": 3705,
          "verses_in_para": 45
        },
        {
          "surah_number": 36,
          "surah_name": "Ya-Sin",
          "arabic_name": "يَا سِين",
          "start_ayah": 3706,
          "end_ayah": 3788,
          "verses_in_para": 83
        },
      ],
      "start_ayah": 3534,
      "end_ayah": 3788,
      "total_verses": 255
    },
    {
      "para_number": 22,
      "name_english": "Wa Man Yaqnut",
      "name_arabic": "وَمَنْ يَقْنُتْ",
      "surahs": [
        {
          "surah_number": 37,
          "surah_name": "As-Saffat",
          "arabic_name": "الصَّافَّات",
          "start_ayah": 3789,
          "end_ayah": 3970,
          "verses_in_para": 182
        },
        {
          "surah_number": 38,
          "surah_name": "Sad",
          "arabic_name": "ص",
          "start_ayah": 3971,
          "end_ayah": 4058,
          "verses_in_para": 88
        },
      ],
      "start_ayah": 3789,
      "end_ayah": 4058,
      "total_verses": 270
    },
    {
      "para_number": 23,
      "name_english": "Wa Mali",
      "name_arabic": "وَمَا لِي",
      "surahs": [
        {
          "surah_number": 39,
          "surah_name": "Az-Zumar",
          "arabic_name": "الزُّمَر",
          "start_ayah": 4059,
          "end_ayah": 4133,
          "verses_in_para": 75
        },
        {
          "surah_number": 40,
          "surah_name": "Ghafir",
          "arabic_name": "غَافِر",
          "start_ayah": 4134,
          "end_ayah": 4218,
          "verses_in_para": 85
        },
        {
          "surah_number": 41,
          "surah_name": "Fussilat",
          "arabic_name": "فُصِّلَت",
          "start_ayah": 4219,
          "end_ayah": 4272,
          "verses_in_para": 54
        },
        {
          "surah_number": 42,
          "surah_name": "Ash-Shura",
          "arabic_name": "الشُّورَىٰ",
          "start_ayah": 4273,
          "end_ayah": 4325,
          "verses_in_para": 53
        },
      ],
      "start_ayah": 4059,
      "end_ayah": 4325,
      "total_verses": 267
    },
    {
      "para_number": 24,
      "name_english": "Fa Man Azlamu",
      "name_arabic": "فَمَنْ أَظْلَمُ",
      "surahs": [
        {
          "surah_number": 43,
          "surah_name": "Az-Zukhruf",
          "arabic_name": "الزُّخْرُف",
          "start_ayah": 4326,
          "end_ayah": 4414,
          "verses_in_para": 89
        },
        {
          "surah_number": 44,
          "surah_name": "Ad-Dukhan",
          "arabic_name": "الدُّخَان",
          "start_ayah": 4415,
          "end_ayah": 4473,
          "verses_in_para": 59
        },
        {
          "surah_number": 45,
          "surah_name": "Al-Jathiyah",
          "arabic_name": "الجَاثِيَة",
          "start_ayah": 4474,
          "end_ayah": 4510,
          "verses_in_para": 37
        },
        {
          "surah_number": 46,
          "surah_name": "Al-Ahqaf",
          "arabic_name": "الْأَحْقَاف",
          "start_ayah": 4511,
          "end_ayah": 4545,
          "verses_in_para": 35
        },
        {
          "surah_number": 47,
          "surah_name": "Muhammad",
          "arabic_name": "مُحَمَّد",
          "start_ayah": 4546,
          "end_ayah": 4583,
          "verses_in_para": 38
        },
        {
          "surah_number": 48,
          "surah_name": "Al-Fath",
          "arabic_name": "الْفَتْح",
          "start_ayah": 4584,
          "end_ayah": 4604,
          "verses_in_para": 21
        },
      ],
      "start_ayah": 4326,
      "end_ayah": 4604,
      "total_verses": 279
    },
    {
      "para_number": 25,
      "name_english": "Ilayhi Yuraddu",
      "name_arabic": "إِلَيْهِ يُرَدُّ",
      "surahs": [
        {
          "surah_number": 48,
          "surah_name": "Al-Fath",
          "arabic_name": "الْفَتْح",
          "start_ayah": 4605,
          "end_ayah": 4612,
          "verses_in_para": 8
        },
        {
          "surah_number": 49,
          "surah_name": "Al-Hujurat",
          "arabic_name": "الحُجُرَات",
          "start_ayah": 4613,
          "end_ayah": 4630,
          "verses_in_para": 18
        },
        {
          "surah_number": 50,
          "surah_name": "Qaf",
          "arabic_name": "ق",
          "start_ayah": 4631,
          "end_ayah": 4675,
          "verses_in_para": 45
        },
        {
          "surah_number": 51,
          "surah_name": "Adh-Dhariyat",
          "arabic_name": "الذَّارِيَات",
          "start_ayah": 4676,
          "end_ayah": 4735,
          "verses_in_para": 60
        },
        {
          "surah_number": 52,
          "surah_name": "At-Tur",
          "arabic_name": "الطُّور",
          "start_ayah": 4736,
          "end_ayah": 4784,
          "verses_in_para": 49
        },
        {
          "surah_number": 53,
          "surah_name": "An-Najm",
          "arabic_name": "النَّجْم",
          "start_ayah": 4785,
          "end_ayah": 4846,
          "verses_in_para": 62
        },
        {
          "surah_number": 54,
          "surah_name": "Al-Qamar",
          "arabic_name": "الْقَمَر",
          "start_ayah": 4847,
          "end_ayah": 4901,
          "verses_in_para": 55
        },
      ],
      "start_ayah": 4605,
      "end_ayah": 4901,
      "total_verses": 297
    },
    {
      "para_number": 26,
      "name_english": "Ha Meem",
      "name_arabic": "حم",
      "surahs": [
        {
          "surah_number": 55,
          "surah_name": "Ar-Rahman",
          "arabic_name": "الرَّحْمَن",
          "start_ayah": 4902,
          "end_ayah": 4979,
          "verses_in_para": 78
        },
        {
          "surah_number": 56,
          "surah_name": "Al-Waqi'ah",
          "arabic_name": "الْوَاقِعَة",
          "start_ayah": 4980,
          "end_ayah": 5075,
          "verses_in_para": 96
        },
        {
          "surah_number": 57,
          "surah_name": "Al-Hadid",
          "arabic_name": "الْحَدِيد",
          "start_ayah": 5076,
          "end_ayah": 5104,
          "verses_in_para": 29
        },
        {
          "surah_number": 58,
          "surah_name": "Al-Mujadila",
          "arabic_name": "المُجَادَلَة",
          "start_ayah": 5105,
          "end_ayah": 5126,
          "verses_in_para": 22
        },
        {
          "surah_number": 59,
          "surah_name": "Al-Hashr",
          "arabic_name": "الْحَشْر",
          "start_ayah": 5127,
          "end_ayah": 5150,
          "verses_in_para": 24
        },
      ],
      "start_ayah": 4902,
      "end_ayah": 5150,
      "total_verses": 249
    },
    {
      "para_number": 27,
      "name_english": "Qala Fa Man",
      "name_arabic": "قَالَ فَمَنْ",
      "surahs": [
        {
          "surah_number": 60,
          "surah_name": "Al-Mumtahanah",
          "arabic_name": "الْمُمْتَحَنَة",
          "start_ayah": 5151,
          "end_ayah": 5163,
          "verses_in_para": 13
        },
        {
          "surah_number": 61,
          "surah_name": "As-Saff",
          "arabic_name": "الصَّفّ",
          "start_ayah": 5164,
          "end_ayah": 5177,
          "verses_in_para": 14
        },
        {
          "surah_number": 62,
          "surah_name": "Al-Jumu'ah",
          "arabic_name": "الْجُمُعَة",
          "start_ayah": 5178,
          "end_ayah": 5188,
          "verses_in_para": 11
        },
        {
          "surah_number": 63,
          "surah_name": "Al-Munafiqun",
          "arabic_name": "الْمُنَافِقُون",
          "start_ayah": 5189,
          "end_ayah": 5199,
          "verses_in_para": 11
        },
        {
          "surah_number": 64,
          "surah_name": "At-Taghabun",
          "arabic_name": "التَّغَابُن",
          "start_ayah": 5200,
          "end_ayah": 5217,
          "verses_in_para": 18
        },
        {
          "surah_number": 65,
          "surah_name": "At-Talaq",
          "arabic_name": "الطَّلَاق",
          "start_ayah": 5218,
          "end_ayah": 5229,
          "verses_in_para": 12
        },
        {
          "surah_number": 66,
          "surah_name": "At-Tahrim",
          "arabic_name": "التَّحْرِيم",
          "start_ayah": 5230,
          "end_ayah": 5241,
          "verses_in_para": 12
        },
        {
          "surah_number": 67,
          "surah_name": "Al-Mulk",
          "arabic_name": "الْمُلْك",
          "start_ayah": 5242,
          "end_ayah": 5271,
          "verses_in_para": 30
        },
        {
          "surah_number": 68,
          "surah_name": "Al-Qalam",
          "arabic_name": "الْقَلَم",
          "start_ayah": 5272,
          "end_ayah": 5323,
          "verses_in_para": 52
        },
        {
          "surah_number": 69,
          "surah_name": "Al-Haqqah",
          "arabic_name": "الْحَاقَّة",
          "start_ayah": 5324,
          "end_ayah": 5375,
          "verses_in_para": 52
        },
        {
          "surah_number": 70,
          "surah_name": "Al-Ma'arij",
          "arabic_name": "الْمَعَارِج",
          "start_ayah": 5376,
          "end_ayah": 5419,
          "verses_in_para": 44
        },
      ],
      "start_ayah": 5151,
      "end_ayah": 5419,
      "total_verses": 269
    },
    {
      "para_number": 28,
      "name_english": "Qad Sami’a Allah",
      "name_arabic": "قَدْ سَمِعَ اللَّه",
      "surahs": [
        {
          "surah_number": 71,
          "surah_name": "Nuh",
          "arabic_name": "نُوح",
          "start_ayah": 5420,
          "end_ayah": 5447,
          "verses_in_para": 28
        },
        {
          "surah_number": 72,
          "surah_name": "Al-Jinn",
          "arabic_name": "الْجِنّ",
          "start_ayah": 5448,
          "end_ayah": 5475,
          "verses_in_para": 28
        },
        {
          "surah_number": 73,
          "surah_name": "Al-Muzzammil",
          "arabic_name": "الْمُزَّمِّل",
          "start_ayah": 5476,
          "end_ayah": 5495,
          "verses_in_para": 20
        },
        {
          "surah_number": 74,
          "surah_name": "Al-Muddathir",
          "arabic_name": "الْمُدَّثِّر",
          "start_ayah": 5496,
          "end_ayah": 5551,
          "verses_in_para": 56
        },
        {
          "surah_number": 75,
          "surah_name": "Al-Qiyamah",
          "arabic_name": "الْقِيَامَة",
          "start_ayah": 5552,
          "end_ayah": 5591,
          "verses_in_para": 40
        },
        {
          "surah_number": 76,
          "surah_name": "Al-Insan",
          "arabic_name": "الْإِنْسَان",
          "start_ayah": 5592,
          "end_ayah": 5622,
          "verses_in_para": 31
        },
        {
          "surah_number": 77,
          "surah_name": "Al-Mursalat",
          "arabic_name": "الْمُرْسَلَات",
          "start_ayah": 5623,
          "end_ayah": 5672,
          "verses_in_para": 50
        },
      ],
      "start_ayah": 5420,
      "end_ayah": 5672,
      "total_verses": 253
    },
    {
      "para_number": 29,
      "name_english": "Tabaraka Alladhi",
      "name_arabic": "تَبَارَكَ الَّذِي",
      "surahs": [
        {
          "surah_number": 78,
          "surah_name": "An-Naba",
          "arabic_name": "النَّبَأ",
          "start_ayah": 5673,
          "end_ayah": 5712,
          "verses_in_para": 40
        },
        {
          "surah_number": 79,
          "surah_name": "An-Nazi'at",
          "arabic_name": "النَّازِعَات",
          "start_ayah": 5713,
          "end_ayah": 5758,
          "verses_in_para": 46
        },
        {
          "surah_number": 80,
          "surah_name": "Abasa",
          "arabic_name": "عَبَسَ",
          "start_ayah": 5759,
          "end_ayah": 5800,
          "verses_in_para": 42
        },
        {
          "surah_number": 81,
          "surah_name": "At-Takwir",
          "arabic_name": "التَّكْوِير",
          "start_ayah": 5801,
          "end_ayah": 5829,
          "verses_in_para": 29
        },
        {
          "surah_number": 82,
          "surah_name": "Al-Infitar",
          "arabic_name": "الْإِنْفِطَار",
          "start_ayah": 5830,
          "end_ayah": 5848,
          "verses_in_para": 19
        },
        {
          "surah_number": 83,
          "surah_name": "Al-Mutaffifin",
          "arabic_name": "المُطَفِّفِين",
          "start_ayah": 5849,
          "end_ayah": 5884,
          "verses_in_para": 36
        },
        {
          "surah_number": 84,
          "surah_name": "Al-Inshiqaq",
          "arabic_name": "الْإِنْشِقَاق",
          "start_ayah": 5885,
          "end_ayah": 5909,
          "verses_in_para": 25
        },
        {
          "surah_number": 85,
          "surah_name": "Al-Buruj",
          "arabic_name": "الْبُرُوج",
          "start_ayah": 5910,
          "end_ayah": 5931,
          "verses_in_para": 22
        },
        {
          "surah_number": 86,
          "surah_name": "At-Tariq",
          "arabic_name": "الطَّارِق",
          "start_ayah": 5932,
          "end_ayah": 5948,
          "verses_in_para": 17
        },
      ],
      "start_ayah": 5673,
      "end_ayah": 5948,
      "total_verses": 276
    },
    {
      "para_number": 30,
      "name_english": "Amma",
      "name_arabic": "عَمَّ",
      "surahs": [
        {
          "surah_number": 87,
          "surah_name": "Al-A'la",
          "arabic_name": "الْأَعْلَىٰ",
          "start_ayah": 5949,
          "end_ayah": 5967,
          "verses_in_para": 19
        },
        {
          "surah_number": 88,
          "surah_name": "Al-Ghashiyah",
          "arabic_name": "الْغَاشِيَة",
          "start_ayah": 5968,
          "end_ayah": 5993,
          "verses_in_para": 26
        },
        {
          "surah_number": 89,
          "surah_name": "Al-Fajr",
          "arabic_name": "الْفَجْر",
          "start_ayah": 5994,
          "end_ayah": 6023,
          "verses_in_para": 30
        },
        {
          "surah_number": 90,
          "surah_name": "Al-Balad",
          "arabic_name": "الْبَلَد",
          "start_ayah": 6024,
          "end_ayah": 6043,
          "verses_in_para": 20
        },
        {
          "surah_number": 91,
          "surah_name": "Ash-Shams",
          "arabic_name": "الشَّمْس",
          "start_ayah": 6044,
          "end_ayah": 6058,
          "verses_in_para": 15
        },
        {
          "surah_number": 92,
          "surah_name": "Al-Layl",
          "arabic_name": "اللَّيْل",
          "start_ayah": 6059,
          "end_ayah": 6079,
          "verses_in_para": 21
        },
        {
          "surah_number": 93,
          "surah_name": "Ad-Duha",
          "arabic_name": "الضُّحَى",
          "start_ayah": 6080,
          "end_ayah": 6090,
          "verses_in_para": 11
        },
        {
          "surah_number": 94,
          "surah_name": "Ash-Sharh",
          "arabic_name": "الشَّرْح",
          "start_ayah": 6091,
          "end_ayah": 6098,
          "verses_in_para": 8
        },
        {
          "surah_number": 95,
          "surah_name": "At-Tin",
          "arabic_name": "التِّين",
          "start_ayah": 6099,
          "end_ayah": 6106,
          "verses_in_para": 8
        },
        {
          "surah_number": 96,
          "surah_name": "Al-Alaq",
          "arabic_name": "الْعَلَق",
          "start_ayah": 6107,
          "end_ayah": 6125,
          "verses_in_para": 19
        },
        {
          "surah_number": 97,
          "surah_name": "Al-Qadr",
          "arabic_name": "الْقَدْر",
          "start_ayah": 6126,
          "end_ayah": 6130,
          "verses_in_para": 5
        },
        {
          "surah_number": 98,
          "surah_name": "Al-Bayyinah",
          "arabic_name": "الْبَيِّنَة",
          "start_ayah": 6131,
          "end_ayah": 6138,
          "verses_in_para": 8
        },
        {
          "surah_number": 99,
          "surah_name": "Az-Zalzalah",
          "arabic_name": "الزَّلْزَلَة",
          "start_ayah": 6139,
          "end_ayah": 6146,
          "verses_in_para": 8
        },
        {
          "surah_number": 100,
          "surah_name": "Al-Adiyat",
          "arabic_name": "الْعَادِيَات",
          "start_ayah": 6147,
          "end_ayah": 6157,
          "verses_in_para": 11
        },
        {
          "surah_number": 101,
          "surah_name": "Al-Qari'ah",
          "arabic_name": "الْقَارِعَة",
          "start_ayah": 6158,
          "end_ayah": 6168,
          "verses_in_para": 11
        },
        {
          "surah_number": 102,
          "surah_name": "At-Takathur",
          "arabic_name": "التَّكَاثُر",
          "start_ayah": 6169,
          "end_ayah": 6176,
          "verses_in_para": 8
        },
        {
          "surah_number": 103,
          "surah_name": "Al-Asr",
          "arabic_name": "الْعَصْر",
          "start_ayah": 6177,
          "end_ayah": 6179,
          "verses_in_para": 3
        },
        {
          "surah_number": 104,
          "surah_name": "Al-Humazah",
          "arabic_name": "الْهُمَزَة",
          "start_ayah": 6180,
          "end_ayah": 6188,
          "verses_in_para": 9
        },
        {
          "surah_number": 105,
          "surah_name": "Al-Fil",
          "arabic_name": "الْفِيل",
          "start_ayah": 6189,
          "end_ayah": 6193,
          "verses_in_para": 5
        },
        {
          "surah_number": 106,
          "surah_name": "Quraysh",
          "arabic_name": "قُرَيْش",
          "start_ayah": 6194,
          "end_ayah": 6197,
          "verses_in_para": 4
        },
        {
          "surah_number": 107,
          "surah_name": "Al-Ma'un",
          "arabic_name": "المَاعُون",
          "start_ayah": 6198,
          "end_ayah": 6204,
          "verses_in_para": 7
        },
        {
          "surah_number": 108,
          "surah_name": "Al-Kawthar",
          "arabic_name": "الْكَوْثَر",
          "start_ayah": 6205,
          "end_ayah": 6207,
          "verses_in_para": 3
        },
        {
          "surah_number": 109,
          "surah_name": "Al-Kafirun",
          "arabic_name": "الْكَافِرُون",
          "start_ayah": 6208,
          "end_ayah": 6213,
          "verses_in_para": 6
        },
        {
          "surah_number": 110,
          "surah_name": "An-Nasr",
          "arabic_name": "النَّصْر",
          "start_ayah": 6214,
          "end_ayah": 6216,
          "verses_in_para": 3
        },
        {
          "surah_number": 111,
          "surah_name": "Al-Masad",
          "arabic_name": "المَسَد",
          "start_ayah": 6217,
          "end_ayah": 6221,
          "verses_in_para": 5
        },
        {
          "surah_number": 112,
          "surah_name": "Al-Ikhlas",
          "arabic_name": "الْإِخْلَاص",
          "start_ayah": 6222,
          "end_ayah": 6225,
          "verses_in_para": 4
        },
        {
          "surah_number": 113,
          "surah_name": "Al-Falaq",
          "arabic_name": "الْفَلَق",
          "start_ayah": 6226,
          "end_ayah": 6230,
          "verses_in_para": 5
        },
        {
          "surah_number": 114,
          "surah_name": "An-Nas",
          "arabic_name": "النَّاس",
          "start_ayah": 6231,
          "end_ayah": 6236,
          "verses_in_para": 6
        },
      ],
      "start_ayah": 5949,
      "end_ayah": 6236,
      "total_verses": 288
    },
  ];

  // Method to get Ayah range for a given Surah
  static Map<String, int> getAyahRange(int surahNumber) {
    final surah = surahRanges.firstWhere((s) => s['surah_number'] == surahNumber);
    return {
      'arabic_name':surah['arabic_name'],
      'verse_count':surah['verse_count'],
      'start': surah['start_ayah'],
      'end': surah['end_ayah'],
      'name': surah['name']
    };
  }


  // Method to get Ayah range for a given Parah
  static Map<String, int> getParaRange(int paraNumber) {
    final surah = parahRanges.firstWhere((s) => s['para_number'] == paraNumber);
    return {
      'name_arabic':surah['name_arabic'],
      'verse_count':surah['verse_count'],
      'start': surah['start_ayah'],
      'end': surah['end_ayah'],
      'name_english': surah['name_english']
    };
  }
}