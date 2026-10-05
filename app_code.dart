import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const EnglishDzApp());
}

class EnglishDzApp extends StatelessWidget {
  const EnglishDzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'English DZ Books',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFFFD700),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD700),
          secondary: Color(0xFFD4AF37),
          surface: Color(0xFF1E1E1E),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class BookResource {
  final String title;
  final String level;
  final String pdfUrl;
  final String audioUrl;

  BookResource({
    required this.title,
    required this.level,
    required this.pdfUrl,
    required this.audioUrl,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<BookResource> books = [
    BookResource(
      title: '1MS Student Book',
      level: '1MS',
      pdfUrl: 'https://github.com/creativeproducts46-alt/English-Teachers-Bag/releases/download/v1.0/1MS_English_Book_Enhanced.pdf',
      audioUrl: '',
    ),
    BookResource(
      title: '2MS Student Book',
      level: '2MS',
      pdfUrl: 'https://github.com/creativeproducts46-alt/English-Teachers-Bag/releases/download/v1.0/2MS_Book.pdf',
      audioUrl: '',
    ),
    BookResource(
      title: '3MS Student Book',
      level: '3MS',
      pdfUrl: 'https://github.com/creativeproducts46-alt/English-Teachers-Bag/releases/download/v1.0/3MS_Book.pdf',
      audioUrl: '',
    ),
    BookResource(
      title: '4MS Student Book (BEM)',
      level: '4MS',
      pdfUrl: 'https://github.com/creativeproducts46-alt/English-Teachers-Bag/releases/download/v1.0/4MS_Book.pdf',
      audioUrl: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'English DZ Books',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFD700)),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return Card(
              color: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFFFD700), width: 1.2),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InteractiveReaderPage(book: book),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.menu_book, size: 55, color: Color(0xFFFFD700)),
                      const SizedBox(height: 12),
                      Text(
                        book.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        book.level,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class InteractiveReaderPage extends StatefulWidget {
  final BookResource book;
  const InteractiveReaderPage({super.key, required this.book});

  @override
  State<InteractiveReaderPage> createState() => _InteractiveReaderPageState();
}

class _InteractiveReaderPageState extends State<InteractiveReaderPage> {
  String? localPdfPath;
  bool isLoading = true;
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _downloadAndLoadPdf();
  }

  Future<void> _downloadAndLoadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.book.pdfUrl));
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${widget.book.level}_book.pdf');
      await file.writeAsBytes(response.bodyBytes);
      setState(() {
        localPdfPath = file.path;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title, style: const TextStyle(color: Color(0xFFFFD700))),
        backgroundColor: const Color(0xFF1A1A1A),
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                  )
                : localPdfPath != null
                    ? PDFView(
                        filePath: localPdfPath,
                        enableSwipe: true,
                        swipeHorizontal: true,
                        autoSpacing: false,
                        pageFling: true,
                      )
                    : const Center(child: Text('Failed to load book.')),
          ),
          if (widget.book.audioUrl.isNotEmpty)
            Container(
              height: 70,
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                border: Border(top: BorderSide(color: Color(0xFFFFD700), width: 1)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      color: const Color(0xFFFFD700),
                      size: 40,
                    ),
                    onPressed: () async {
                      if (isPlaying) {
                        await audioPlayer.pause();
                        setState(() => isPlaying = false);
                      } else {
                        await audioPlayer.play(UrlSource(widget.book.audioUrl));
                        setState(() => isPlaying = true);
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Listening Script / Audio Track',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
