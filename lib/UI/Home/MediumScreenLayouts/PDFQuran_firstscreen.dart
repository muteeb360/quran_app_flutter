import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import '../../../Utils/colors.dart'; // Ensure this file exists and defines AppColors.background

class PdfquranFirstscreen extends StatefulWidget {
  const PdfquranFirstscreen({super.key});

  @override
  State<PdfquranFirstscreen> createState() => _PdfquranFirstscreenState();
}

class _PdfquranFirstscreenState extends State<PdfquranFirstscreen> {
  // Download states for each PDF
  Map<String, double> downloadProgress = {};
  Map<String, bool> isDownloading = {};
  Map<String, String?> downloadedFilePaths = {};
  Map<String, StreamSubscription?> downloadSubscriptions = {};

  @override
  void initState() {
    super.initState();
    _loadDownloadedFiles();
  }

  // Load previously downloaded files from SharedPreferences
  Future<void> _loadDownloadedFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final directory = await getApplicationDocumentsDirectory();
    setState(() {
      for (var fileName in ['Colorful Quran', 'Black and White Quran']) {
        final filePath = prefs.getString(fileName);
        if (filePath != null && File(filePath).existsSync()) {
          downloadedFilePaths[fileName] = filePath;
        }
      }
    });
  }

  // Save downloaded file path to SharedPreferences
  Future<void> _saveDownloadedFile(String fileName, String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(fileName, filePath);
  }

  // Download PDF from Google Drive
  Future<void> downloadPDF(String fileName, String url) async {
    try {
      setState(() {
        isDownloading[fileName] = true;
        downloadProgress[fileName] = 0.0;
      });

      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception('Invalid response: ${response.statusCode}');
      }

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName.pdf';
      final file = File(filePath);
      final sink = file.openWrite();

      final subscription = response.stream.listen(
            (data) {
          sink.add(data);
          receivedBytes += data.length;
          setState(() {
            downloadProgress[fileName] = totalBytes > 0 ? receivedBytes / totalBytes : 0.0;
          });
        },
        onDone: () async {
          await sink.close();
          setState(() {
            isDownloading[fileName] = false;
            downloadedFilePaths[fileName] = filePath;
            downloadProgress.remove(fileName);
            downloadSubscriptions.remove(fileName);
          });
          await _saveDownloadedFile(fileName, filePath);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$fileName downloaded successfully')),
          );
        },
        onError: (e) {
          setState(() {
            isDownloading[fileName] = false;
            downloadProgress.remove(fileName);
            downloadSubscriptions.remove(fileName);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to download $fileName: $e')),
          );
        },
        cancelOnError: true,
      );

      downloadSubscriptions[fileName] = subscription;
    } catch (e) {
      setState(() {
        isDownloading[fileName] = false;
        downloadProgress.remove(fileName);
        downloadSubscriptions.remove(fileName);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading $fileName: $e')),
      );
    }
  }

  // Cancel download
  void cancelDownload(String fileName) {
    downloadSubscriptions[fileName]?.cancel();
    setState(() {
      isDownloading[fileName] = false;
      downloadProgress.remove(fileName);
      downloadSubscriptions.remove(fileName);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Download of $fileName cancelled')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'PDF Quran',
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
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.02),
          buildFolderCard(
            context,
            imagePath: 'assets/images/color_pdf.jpg',
            fileName: 'Colorful Quran',
            fileSize: '90.8 MB',
            fileUrl: 'https://drive.google.com/uc?export=download&id=1XKzw_pFBlYw05PlYUxXbrqOVoLsOucdB',
            isDownloading: isDownloading['Colorful Quran'] ?? false,
            downloadProgress: downloadProgress['Colorful Quran'] ?? 0.0,
            downloadedFilePath: downloadedFilePaths['Colorful Quran'],
            onDownload: () => downloadPDF('Colorful Quran', 'https://drive.google.com/uc?export=download&id=1XKzw_pFBlYw05PlYUxXbrqOVoLsOucdB'),
            onCancel: () => cancelDownload('Colorful Quran'),
            onOpen: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PDFViewerPage(
                    filePath: downloadedFilePaths['Colorful Quran']!,
                    fileName: 'Colorful Quran',
                  ),
                ),
              );
            },
          ),
          SizedBox(height: screenHeight * 0.02),
          buildFolderCard(
            context,
            imagePath: 'assets/images/bnw_pdf.jpg',
            fileName: 'Black and White Quran',
            fileSize: '41.2 MB',
            fileUrl: 'https://drive.google.com/uc?export=download&id=1l_NVVvo5Df4cKYcEQ9zq3Ap1NYhOPjeT',
            isDownloading: isDownloading['Black and White Quran'] ?? false,
            downloadProgress: downloadProgress['Black and White Quran'] ?? 0.0,
            downloadedFilePath: downloadedFilePaths['Black and White Quran'],
            onDownload: () => downloadPDF('Black and White Quran', 'https://drive.google.com/uc?export=download&id=1l_NVVvo5Df4cKYcEQ9zq3Ap1NYhOPjeT'),
            onCancel: () => cancelDownload('Black and White Quran'),
            onOpen: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PDFViewerPage(
                    filePath: downloadedFilePaths['Black and White Quran']!,
                    fileName: 'Black and White Quran',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildFolderCard(
      BuildContext context, {
        required String imagePath,
        required String fileName,
        required String fileSize,
        required String fileUrl,
        required bool isDownloading,
        required double downloadProgress,
        required String? downloadedFilePath,
        required VoidCallback onDownload,
        required VoidCallback onCancel,
        required VoidCallback onOpen,
      }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.23,
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                    width: screenWidth * 0.3,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fileSize,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                              color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        isDownloading
                            ? Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: downloadProgress,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF44C17B)),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.cancel, color: Colors.red),
                              onPressed: onCancel,
                            ),
                          ],
                        )
                            : downloadedFilePath != null
                            ? ElevatedButton(
                          onPressed: onOpen,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF44C17B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            'Open',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                            : ElevatedButton(
                          onPressed: onDownload,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF44C17B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            'Download',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -10,
            left: 10,
            child: Container(
              width: 40,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// PDF Viewer Page
class PDFViewerPage extends StatefulWidget {
  final String filePath;
  final String fileName;

  const PDFViewerPage({super.key, required this.filePath, required this.fileName});

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  PDFViewController? _pdfController;
  int _currentPage = 0;
  int _totalPages = 0;
  int? _lastReadPage; // Store last read page separately
  bool _isPageSet = false; // Flag to prevent multiple page sets

  // Parah to page mapping (customize based on your PDF)
  final Map<String, int> _parahToPage = {
    'Juz 1': 1,
    'Juz 2': 22,
    'Juz 3': 42,
    'Juz 4': 62,
    'Juz 5': 82,
    'Juz 6': 102,
    'Juz 7': 122,
    'Juz 8': 142,
    'Juz 9': 162,
    'Juz 10': 182,
    'Juz 11': 202,
    'Juz 12': 222,
    'Juz 13': 242,
    'Juz 14': 262,
    'Juz 15': 282,
    'Juz 16': 302,
    'Juz 17': 322,
    'Juz 18': 342,
    'Juz 19': 362,
    'Juz 20': 382,
    'Juz 21': 402,
    'Juz 22': 422,
    'Juz 23': 442,
    'Juz 24': 462,
    'Juz 25': 482,
    'Juz 26': 502,
    'Juz 27': 522,
    'Juz 28': 542,
    'Juz 29': 562,
    'Juz 30': 586,
  };

  // Surah to page mapping (customize based on your PDF)
  final Map<String, int> _surahToPage = {
    'Al-Fatihah': 1,
    'Al-Baqarah': 2,
    'Aal-E-Imran': 50,
    'An-Nisa': 77,
    'Al-Ma\'idah': 106,
    'Al-An\'am': 128,
    'Al-A\'raf': 151,
    'Al-Anfal': 177,
    'At-Tawbah': 187,
    'Yunus': 208,
    'Hud': 221,
    'Yusuf': 235,
    'Ar-Ra\'d': 249,
    'Ibrahim': 255,
    'Al-Hijr': 262,
    'An-Nahl': 267,
    'Al-Isra': 282,
    'Al-Kahf': 293,
    'Maryam': 305,
    'Ta-Ha': 312,
    'Al-Anbiya': 322,
    'Al-Hajj': 332,
    'Al-Mu\'minun': 342,
    'An-Nur': 350,
    'Al-Furqan': 359,
    'Ash-Shu\'ara': 367,
    'An-Naml': 377,
    'Al-Qasas': 385,
    'Al-Ankabut': 396,
    'Ar-Rum': 404,
    'Luqman': 411,
    'As-Sajdah': 415,
    'Al-Ahzab': 418,
    'Saba': 428,
    'Fatir': 434,
    'Ya-Sin': 440,
    'As-Saffat': 446,
    'Sad': 453,
    'Az-Zumar': 458,
    'Ghafir': 467,
    'Fussilat': 477,
    'Ash-Shura': 483,
    'Az-Zukhruf': 489,
    'Ad-Dukhan': 496,
    'Al-Jathiyah': 499,
    'Al-Ahqaf': 502,
    'Muhammad': 507,
    'Al-Fath': 511,
    'Al-Hujurat': 515,
    'Qaf': 518,
    'Adh-Dhariyat': 520,
    'At-Tur': 523,
    'An-Najm': 526,
    'Al-Qamar': 528,
    'Ar-Rahman': 531,
    'Al-Waqi\'ah': 534,
    'Al-Hadid': 537,
    'Al-Mujadilah': 542,
    'Al-Hashr': 545,
    'Al-Mumtahanah': 549,
    'As-Saff': 551,
    'Al-Jumu\'ah': 553,
    'Al-Munafiqun': 554,
    'At-Taghabun': 556,
    'At-Talaq': 558,
    'At-Tahrim': 560,
    'Al-Mulk': 562,
    'Al-Qalam': 564,
    'Al-Haqqah': 566,
    'Al-Ma\'arij': 568,
    'Nuh': 570,
    'Al-Jinn': 572,
    'Al-Muzzammil': 574,
    'Al-Muddaththir': 575,
    'Al-Qiyamah': 577,
    'Al-Insan': 578,
    'Al-Mursalat': 580,
    'An-Naba': 582,
    'An-Nazi\'at': 583,
    'Abasa': 585,
    'At-Takwir': 586,
    'Al-Infitar': 587,
    'Al-Mutaffifin': 588,
    'Al-Inshiqaq': 589,
    'Al-Buruj': 590,
    'At-Tariq': 591,
    'Al-A\'la': 592,
    'Al-Ghashiyah': 593,
    'Al-Fajr': 594,
    'Al-Balad': 595,
    'Ash-Shams': 596,
    'Al-Lail': 597,
    'Ad-Duha': 598,
    'Ash-Sharh': 599,
    'At-Tin': 600,
    'Al-Alaq': 601,
    'Al-Qadr': 602,
    'Al-Bayyinah': 603,
    'Az-Zalzalah': 604,
    'Al-Adiyat': 605,
    'Al-Qari\'ah': 606,
    'At-Takathur': 607,
    'Al-Asr': 608,
    'Al-Humazah': 609,
    'Al-Fil': 610,
    'Quraysh': 611,
    'Al-Ma\'un': 612,
    'Al-Kawthar': 613,
    'Al-Kafirun': 614,
    'An-Nasr': 615,
    'Al-Masad': 616,
    'Al-Ikhlas': 617,
    'Al-Falaq': 618,
    'An-Nas': 619,
  };

  @override
  void initState() {
    super.initState();
    _loadLastPage();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Load last read page
  Future<void> _loadLastPage() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPage = prefs.getInt('${widget.fileName}_lastPage') ?? 0;
    setState(() {
      _lastReadPage = lastPage;
      _currentPage = 0; // Start at page 0 until navigation succeeds
    });
    if (lastPage > 0) {
      // Show SnackBar with Resume action
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Last read: page ${lastPage + 1}'),
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Resume',
              onPressed: () => _navigateToPage(lastPage, showSnackBar: true),
            ),
          ),
        );
      });
      // Attempt navigation after a delay to mimic user interaction timing
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(Duration(seconds: 2)); // Increased delay for stability
        if (mounted && !_isPageSet && _lastReadPage != null) {
          await _navigateToPage(_lastReadPage!, showSnackBar: true);
        }
      });
    }
  }

  // Save last read page
  Future<void> _saveLastPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${widget.fileName}_lastPage', page);
    setState(() {
      _lastReadPage = page;
    });
  }

  // Navigate to a specific page with error handling and logging
  Future<void> _navigateToPage(int page, {bool showSnackBar = true}) async {
    if (_pdfController == null || !mounted) {
      print('Navigation failed: PDF controller is null or widget is unmounted');
      return;
    }
    try {
      print('Attempting to navigate to page $page');
      await _pdfController!.setPage(page);
      setState(() {
        _currentPage = page;
        _isPageSet = true; // Mark page as set
      });
      await _saveLastPage(page);
      print('Successfully navigated to page $page');
      if (showSnackBar && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigated to page ${page + 1}')),
        );
      }
    } catch (e) {
      print('Error navigating to page $page: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to navigate to page ${page + 1}'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _navigateToPage(page, showSnackBar: true),
            ),
          ),
        );
      }
    }
  }

  // Show Parah selection dialog
  void _showParahDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Parah',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600,color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: _parahToPage.length,
            itemBuilder: (context, index) {
              final parah = _parahToPage.keys.elementAt(index);
              return ListTile(
                title: Text(parah, style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToPage(_parahToPage[parah]!, showSnackBar: true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Navigated to $parah')),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  // Handle swipe gestures
  void _handleSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity; if (velocity != null) {
      if (velocity < 0 && _currentPage > 0) {
        // Swipe left: go to previous page
        final newPage = _currentPage - 1; _navigateToPage(newPage, showSnackBar: false);
        // No SnackBar for swipes
        } else if (velocity > 0 && _currentPage < _totalPages - 1) {
        // Swipe right: go to next page
        final newPage = _currentPage + 1; _navigateToPage(newPage, showSnackBar: false);
        // No SnackBar for swipes
        } } }

  // Show Surah selection dialog
  void _showSurahDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Surah',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600,color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: _surahToPage.length,
            itemBuilder: (context, index) {
              final surah = _surahToPage.keys.elementAt(index);
              return ListTile(
                title: Text(surah, style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToPage(_surahToPage[surah]!, showSnackBar: true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Navigated to $surah')),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.fileName,
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
                Color(0xFF44C17B),
                Color(0xFF205B3A),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'Parahs') {
                _showParahDialog();
              } else if (value == 'Surahs') {
                _showSurahDialog();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'Parahs',
                child: Text('Parahs', style: GoogleFonts.poppins()),
              ),
              PopupMenuItem(
                value: 'Surahs',
                child: Text('Surahs', style: GoogleFonts.poppins()),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: _lastReadPage != null && _lastReadPage! > 0
          ? FloatingActionButton(
        backgroundColor: Color(0xFF44C17B),
        tooltip: 'Resume at page ${_lastReadPage! + 1}',
        onPressed: () => _navigateToPage(_lastReadPage!, showSnackBar: true),
        child: Icon(Icons.restore_page, color: Colors.white),
      )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Swipe right for next page',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                GestureDetector(
                  onHorizontalDragEnd: _handleSwipe,
                  child: PDFView(
                    fitPolicy: FitPolicy.BOTH,
                    filePath: widget.filePath,
                    onViewCreated: (PDFViewController controller) async {
                      _pdfController = controller;
                      // Get total pages and validate current page
                      final total = await _pdfController?.getPageCount() ?? 0;
                      setState(() {
                        _totalPages = total;
                        // Validate _currentPage
                        if (_currentPage >= total) {
                          _currentPage = total - 1;
                        } else if (_currentPage < 0) {
                          _currentPage = 0;
                        }
                      });
                    },
                    onPageChanged: (page, total) {
                      setState(() {
                        _currentPage = page ?? 0;
                        _totalPages = total ?? 0;
                        _isPageSet = true; // Mark page as set
                      });
                      _saveLastPage(_currentPage);
                    },
                    onError: (error) {
                      print('PDF loading error: $error');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error loading PDF: $error')),
                      );
                    },
                    enableSwipe: false, // Disable default swipe handling
                    swipeHorizontal: true,
                    autoSpacing: true,
                    pageFling: false, // Disable fling to simplify control
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Text(
                    'Page: ${_currentPage + 1} / $_totalPages',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}