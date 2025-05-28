import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../Utils/colors.dart'; // Ensure this file defines AppColors.background

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
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.02),
          buildFolderCard(
            context,
            imagePath: 'assets/images/color_pdf.jpg',
            fileName: 'Colorful Quran',
            fileSize: '90.8 MB',
            fileUrl: 'https://drive.google.com/uc?export=download&id=1nnR1Mn3ZJJFcY9jjJq5LVTZaT6xJsJGl',
            isDownloading: isDownloading['Colorful Quran'] ?? false,
            downloadProgress: downloadProgress['Colorful Quran'] ?? 0.0,
            downloadedFilePath: downloadedFilePaths['Colorful Quran'],
            onDownload: () => downloadPDF('Colorful Quran', 'https://drive.google.com/uc?export=download&id=1nnR1Mn3ZJJFcY9jjJq5LVTZaT6xJsJGl'),
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
            fileUrl: 'https://drive.google.com/uc?export=download&id=1lfWI8BXWXMx-ArJ1jrE-KtKrZ7jw4A9q',
            isDownloading: isDownloading['Black and White Quran'] ?? false,
            downloadProgress: downloadProgress['Black and White Quran'] ?? 0.0,
            downloadedFilePath: downloadedFilePaths['Black and White Quran'],
            onDownload: () => downloadPDF('Black and White Quran', 'https://drive.google.com/uc?export=download&id=1lfWI8BXWXMx-ArJ1jrE-KtKrZ7jw4A9q'),
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
              color: Colors.white,
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
                        fit: BoxFit.contain,
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
                            color: Colors.black87,
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
                            color: Colors.grey[600],
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
                              icon: Icon(Icons.close, color: Colors.red),
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
  final PdfViewerController _pdfController = PdfViewerController();
  int _currentPage = 0;
  int _totalPages = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchBar = false;

  // Surah to page mapping (0-based for RTL)
  final Map<String, int> _surahToPage = {
    'الفاتحة': 0, // First page
    'البقرة': 1, // Second page
    'آل عمران': 49, // Adjust based on your PDF
    // Add more Surahs
  };

  @override
  void initState() {
    super.initState();
    _loadLastPage();
  }

  // Load last read page
  Future<void> _loadLastPage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPage = prefs.getInt('${widget.fileName}_lastPage') ?? 0;
    setState(() {
      _currentPage = savedPage;
    });
    _pdfController.jumpToPage(savedPage + 1); // SfPdfViewer uses 1-based indexing
  }

  // Save last read page
  Future<void> _saveLastPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${widget.fileName}_lastPage', page);
  }

  // Search for a Surah
  void _searchSurah(String query) {
    final surahPage = _surahToPage[query];
    if (surahPage != null) {
      _pdfController.jumpToPage(surahPage + 1); // 1-based for SfPdfViewer
      setState(() {
        _currentPage = surahPage;
      });
      _saveLastPage(surahPage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('انتقل إلى $query', textDirection: TextDirection.rtl),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لم يتم العثور على السورة', textDirection: TextDirection.rtl),
        ),
      );
    }
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
          IconButton(
            icon: Icon(_showSearchBar ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _showSearchBar = !_showSearchBar;
                if (!_showSearchBar) _searchController.clear();
              });
            },
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            if (_showSearchBar)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'ادخل اسم السورة (مثل: الفاتحة)',
                    hintStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () => _searchSurah(_searchController.text),
                    ),
                  ),
                  onSubmitted: _searchSurah,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'اضغط بإصبعين للتكبير/التصغير',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                textDirection: TextDirection.rtl,
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  SfPdfViewer.file(
                    File(widget.filePath),
                    controller: _pdfController,
                    scrollDirection: PdfScrollDirection.horizontal,
                    pageLayoutMode: PdfPageLayoutMode.continuous, // RTL scrolling supported
                    onDocumentLoaded: (details) {
                      setState(() {
                        _totalPages = details.document.pages.count;
                      });
                    },
                    onPageChanged: (details) {
                      setState(() {
                        _currentPage = details.newPageNumber - 1; // Convert to 0-based
                      });
                      _saveLastPage(_currentPage);
                    },
                    onDocumentLoadFailed: (details) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'خطأ في تحميل الملف: ${details.description}',
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16, // RTL alignment
                    child: Text(
                      'الصفحة: $_currentPage / ${_totalPages - 1}',
                      style: GoogleFonts.poppins(fontSize: 16),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}