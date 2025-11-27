import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  final ColorScheme colorScheme;
  final bool download;
  final bool upload;
  final bool running;
  final double totalMb;
  final double downloadedMb;
  final double uploadedMb;
  final double mbPerSec;
  final TextEditingController sizeController;
  final TextEditingController connController;
  final ValueChanged<bool> onDownloadChanged;
  final ValueChanged<bool> onUploadChanged;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const DashboardPage({
    super.key,
    required this.colorScheme,
    required this.download,
    required this.upload,
    required this.running,
    required this.totalMb,
    required this.downloadedMb,
    required this.uploadedMb,
    required this.mbPerSec,
    required this.sizeController,
    required this.connController,
    required this.onDownloadChanged,
    required this.onUploadChanged,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          _buildControlCard(),
          const SizedBox(height: 16),
          _buildStatsCard(),
          const SizedBox(height: 16),
          _buildStatusBar(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      color: const Color(0xFF0E2238), // biru sedikit lebih terang
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF42A5F5), Color(0xFF80D6FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.data_usage,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cartenz Data Waster',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Stress test your mobile data pipe with realistic upload & download traffic.',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlCard() {
    return Card(
      color: const Color(0xFF10273F),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mode & Settings',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Download'),
                Switch(
                  value: download,
                  onChanged: running ? null : onDownloadChanged,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Upload'),
                Switch(
                  value: upload,
                  onChanged: running ? null : onUploadChanged,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            TextField(
              controller: sizeController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Data size (MB, 0 = infinite)',
                helperText: 'Total data yang ingin dihabiskan.',
                border: OutlineInputBorder(),
              ),
              enabled: !running,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: connController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Concurrent connections',
                helperText: 'Semakin tinggi, semakin agresif.',
                border: OutlineInputBorder(),
              ),
              enabled: !running,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853), // hijau terang
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  elevation: 4,
                ),
                onPressed: running ? onStop : onStart,
                icon: Icon(running ? Icons.stop_rounded : Icons.play_arrow),
                label: Text(
                  running ? 'Stop Test' : 'Start Test',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      color: const Color(0xFF132D48),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Statistics',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatChip(
                  label: 'Total',
                  value: '${totalMb.toStringAsFixed(2)} MB',
                  color: const Color(0xFF2A4E7A),
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  label: 'Speed',
                  value: '${mbPerSec.toStringAsFixed(2)} MB/s',
                  color: const Color(0xFF355F93),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              icon: Icons.download_rounded,
              label: 'Downloaded',
              value: '${downloadedMb.toStringAsFixed(2)} MB',
              color: Colors.greenAccent,
            ),
            const SizedBox(height: 8),
            _buildStatRow(
              icon: Icons.upload_rounded,
              label: 'Uploaded',
              value: '${uploadedMb.toStringAsFixed(2)} MB',
              color: Colors.deepOrangeAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBar() {
    final bool isIdle = !running && mbPerSec == 0.0;
    final String text =
        running ? 'Running traffic test…' : (isIdle ? 'Idle' : 'Completed');

    final IconData icon =
        running ? Icons.wifi_tethering : (isIdle ? Icons.pause_circle : Icons.check_circle);

    final Color bgColor =
        running ? const Color(0xFF1B3C5D) : const Color(0xFF0E2238);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
