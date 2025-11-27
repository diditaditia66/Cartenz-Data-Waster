import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'pages/dashboard_page.dart';
import 'pages/speed_graph_page.dart';
import 'pages/about_page.dart';
import 'notification_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationHelper.initialize();
  runApp(const CartenzDataWasterApp());
}

class CartenzDataWasterApp extends StatelessWidget {
  const CartenzDataWasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    const deepBlue = Color(0xFF061826);

    return MaterialApp(
      title: 'Cartenz Data Waster',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF42A5F5),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: deepBlue,
        fontFamily: 'Roboto',
      ),
      home: const DataWasterHomePage(),
    );
  }
}

class DataWasterHomePage extends StatefulWidget {
  const DataWasterHomePage({super.key});

  @override
  State<DataWasterHomePage> createState() => _DataWasterHomePageState();
}

class _DataWasterHomePageState extends State<DataWasterHomePage> {
  // ====== Konfigurasi ======
  bool _download = true;
  bool _upload = false;

  final TextEditingController _sizeController =
      TextEditingController(text: '10'); // MB
  final TextEditingController _connController =
      TextEditingController(text: '3'); // koneksi paralel

  // ====== Status internal ======
  bool _running = false;
  bool _stopRequested = false;

  int _totalBytesDownloaded = 0;
  int _totalBytesUploaded = 0;

  double _mbPerSec = 0.0; // total (download + upload)

  Timer? _speedTimer;

  // untuk menghitung delta per detik
  int _lastDownloadedBytes = 0;
  int _lastUploadedBytes = 0;

  // History speed untuk grafik (MB/s, tiap detik)
  final List<double> _downloadSpeedHistory = [];
  final List<double> _uploadSpeedHistory = [];
  static const int _maxHistoryPoints = 60; // simpan 60 detik terakhir

  // Navigation index: 0 = Dashboard, 1 = Graph, 2 = About
  int _selectedIndex = 0;

  // URL backend
  static const String baseUrl = 'https://waster.anya-vpn.my.id';

  @override
  void dispose() {
    _sizeController.dispose();
    _connController.dispose();
    _speedTimer?.cancel();
    super.dispose();
  }

  double _currentTotalMb() {
    return (_totalBytesDownloaded + _totalBytesUploaded) /
        (1024 * 1024);
  }

  Future<void> _updateNotification() async {
    if (!_running) return;
    await NotificationHelper.updateRunningNotification(
      totalMb: _currentTotalMb(),
      currentSpeed: _mbPerSec,
    );
  }

  // ====== Logika utama ======

  void _start() async {
    final sizeMb =
        double.tryParse(_sizeController.text.replaceAll(',', '.')) ?? 0.0;
    final connections = int.tryParse(_connController.text) ?? 1;

    if (!_download && !_upload) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal Download atau Upload')),
      );
      return;
    }

    if (connections < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Concurrent connections minimal 1')),
      );
      return;
    }

    setState(() {
      _running = true;
      _stopRequested = false;
      _totalBytesDownloaded = 0;
      _totalBytesUploaded = 0;
      _mbPerSec = 0.0;
      _lastDownloadedBytes = 0;
      _lastUploadedBytes = 0;
      _downloadSpeedHistory.clear();
      _uploadSpeedHistory.clear();
    });

    // tampilkan notifikasi awal
    await NotificationHelper.showRunningNotification(
      totalMb: 0,
      currentSpeed: 0,
    );

    // 0 = infinite, selain itu target total bytes
    final int targetBytes = sizeMb <= 0 ? 0 : (sizeMb * 1024 * 1024).round();

    // Timer untuk menghitung MB/s dan simpan history
    _speedTimer?.cancel();
    _speedTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final diffDownloaded = _totalBytesDownloaded - _lastDownloadedBytes;
      final diffUploaded = _totalBytesUploaded - _lastUploadedBytes;

      _lastDownloadedBytes = _totalBytesDownloaded;
      _lastUploadedBytes = _totalBytesUploaded;

      if (!mounted) return;

      final currentDownloadSpeed = diffDownloaded / (1024 * 1024);
      final currentUploadSpeed = diffUploaded / (1024 * 1024);
      final totalSpeed = currentDownloadSpeed + currentUploadSpeed;

      setState(() {
        _mbPerSec = totalSpeed;

        _downloadSpeedHistory.add(currentDownloadSpeed);
        _uploadSpeedHistory.add(currentUploadSpeed);

        if (_downloadSpeedHistory.length > _maxHistoryPoints) {
          _downloadSpeedHistory.removeAt(0);
        }
        if (_uploadSpeedHistory.length > _maxHistoryPoints) {
          _uploadSpeedHistory.removeAt(0);
        }
      });

      await _updateNotification();
    });

    // Jalankan beberapa koneksi paralel
    for (int i = 0; i < connections; i++) {
      _runConnectionLoop(targetBytes);
    }
  }

  void _stop() async {
    setState(() {
      _stopRequested = true;
      _running = false;
    });
    _speedTimer?.cancel();
    await NotificationHelper.cancelRunningNotification();
  }

  Future<void> _runConnectionLoop(int targetBytes) async {
    const int chunkSizeBytes = 256 * 1024; // 256 KB per request
    final rng = Random();

    while (!_stopRequested && mounted) {
      final totalBytesNow = _totalBytesDownloaded + _totalBytesUploaded;
      if (targetBytes > 0 && totalBytesNow >= targetBytes) {
        break;
      }

      try {
        // Download
        if (_download && !_stopRequested) {
          final bytes = await _doDownload(chunkSizeBytes);
          if (!mounted || _stopRequested) break;
          setState(() {
            _totalBytesDownloaded += bytes;
          });
        }

        // Upload
        if (_upload && !_stopRequested) {
          final bytes = await _doUpload(chunkSizeBytes, rng);
          if (!mounted || _stopRequested) break;
          setState(() {
            _totalBytesUploaded += bytes;
          });
        }
      } catch (e) {
        debugPrint('Error in loop: $e');
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    // Kalau target tercapai (bukan infinite mode), hentikan
    if (mounted && !_stopRequested && targetBytes > 0) {
      setState(() {
        _running = false;
      });
      _speedTimer?.cancel();
      await NotificationHelper.cancelRunningNotification();
    }
  }

  Future<int> _doDownload(int sizeBytes) async {
    final uri = Uri.parse('$baseUrl/waste-download?sizeBytes=$sizeBytes');
    final response = await http.get(uri);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes.length;
    } else {
      throw Exception('Download failed: ${response.statusCode}');
    }
  }

  Future<int> _doUpload(int sizeBytes, Random rng) async {
    final data = Uint8List.fromList(
      List<int>.generate(sizeBytes, (_) => rng.nextInt(256)),
    );
    final uri = Uri.parse('$baseUrl/waste-upload');
    final response = await http.post(uri, body: data);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data.length;
    } else {
      throw Exception('Upload failed: ${response.statusCode}');
    }
  }

  // ====== UI ======

  @override
  Widget build(BuildContext context) {
    final totalMb = _currentTotalMb();
    final downloadedMb = _totalBytesDownloaded / (1024 * 1024);
    final uploadedMb = _totalBytesUploaded / (1024 * 1024);

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Icon(
            Icons.shield_rounded,
            size: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                DashboardPage(
                  colorScheme: colorScheme,
                  download: _download,
                  upload: _upload,
                  running: _running,
                  totalMb: totalMb,
                  downloadedMb: downloadedMb,
                  uploadedMb: uploadedMb,
                  mbPerSec: _mbPerSec,
                  sizeController: _sizeController,
                  connController: _connController,
                  onDownloadChanged: (v) {
                    if (!_running) {
                      setState(() {
                        _download = v;
                      });
                    }
                  },
                  onUploadChanged: (v) {
                    if (!_running) {
                      setState(() {
                        _upload = v;
                      });
                    }
                  },
                  onStart: _start,
                  onStop: _stop,
                ),
                SpeedGraphPage(
                  colorScheme: colorScheme,
                  downloadSpeeds: _downloadSpeedHistory,
                  uploadSpeeds: _uploadSpeedHistory,
                ),
                const AboutPage(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.speed),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Speed Graph',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'About',
          ),
        ],
      ),
    );
  }
}
