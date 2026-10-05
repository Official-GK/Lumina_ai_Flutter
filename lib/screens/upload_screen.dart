import '../app_theme.dart';
import '../services/api_service.dart';
import '../providers/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  PlatformFile? _selectedFile;           // Works on Web & Mobile
  String _selectedTrajectory = 'Product Designer (AI / Systems)';
  String _selectedSeniority = 'Mid-Level';
  bool _isAnalyzing = false;
  String? _error;

  final List<String> _trajectories = [
    'Product Designer (AI / Systems)',
    'AI / ML Engineer',
    'Full Stack Developer',
    'Data Scientist',
    'DevOps / Platform Engineer',
    'Growth Product Manager',
    'UX Researcher',
    'Backend Engineer',
  ];

  final List<String> _seniorities = ['Early Career', 'Mid-Level', 'Senior / Lead'];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,   // ← loads bytes on Web (no file path available)
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.single;
        _error = null;
      });
    }
  }

  Future<void> _analyzeResume() async {
    if (_selectedFile == null) {
      setState(() => _error = 'Please select your PDF resume first.');
      return;
    }
    setState(() { _isAnalyzing = true; _error = null; });

    // Capture context-dependent objects BEFORE any await
    final provider = context.read<UserDataProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final result = await ApiService().analyzeResumeBytes(
        _selectedFile!.bytes!,
        _selectedFile!.name,
        _selectedTrajectory,
      );
      if (!mounted) return;

      final data = result['data'] as Map<String, dynamic>;
      final warning = result['warning'] as String?;
      final score = data['profile_score'] ?? 0;

      if (warning != null) {
        // Firestore write failed — show a clear error dialog
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.cardBg,
            title: Row(children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              const SizedBox(width: 8),
              Text('Database Not Ready', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
            ]),
            content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('✅ AI analysis was successful! Score: $score%', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('⚠️ However, Cloud Firestore API is not enabled yet, so your data could not be saved.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 12),
              Text('To fix this:', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('1. Go to console.firebase.google.com\n2. Select project "ai-career--skill"\n3. Click Firestore Database → Create database\n4. Choose "Start in test mode"\n5. Come back and upload your resume again',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.5)),
            ]),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                child: Text('Got it!', style: TextStyle(color: AppTheme.cardBg)),
              ),
            ],
          ),
        );
        return;
      }

      // Full success — Firestore written, refresh provider
      await provider.refresh();

      messenger.showSnackBar(
        SnackBar(
          content: Text('✅ Resume analyzed! Career Readiness Score: $score%'),
          backgroundColor: AppTheme.primary,
          duration: const Duration(seconds: 4),
        ),
      );
      navigator.pushReplacementNamed('/home');
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Analysis failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg.withValues(alpha: 0.9),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: AppTheme.primary),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lumina', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                Text('Career AI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.primary)),
              ],
            ),
            const Spacer(),
            Text('Resume Upload', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  _stepBadge('1', 'Setup', true),
                  Expanded(child: LinearProgressIndicator(value: 0.66, backgroundColor: AppTheme.subtle, color: AppTheme.primary, borderRadius: BorderRadius.circular(4))),
                  _stepBadge('2', 'Upload', true),
                  Expanded(child: LinearProgressIndicator(value: 0, backgroundColor: AppTheme.subtle, color: AppTheme.primary, borderRadius: BorderRadius.circular(4))),
                  _stepBadge('3', 'Analysis', false),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Neural badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.psychology, size: 14, color: AppTheme.primaryText),
                const SizedBox(width: 6),
                Text('Neural Trajectory Match', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryText)),
              ]),
            ),
            const SizedBox(height: 16),
            Text('Upload Your Resume', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Text("Lumina's neural engine decodes hidden strengths, experiences, and trajectory alignment in seconds.", style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
            const SizedBox(height: 24),

            // Error banner
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.error.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Icon(Icons.error_outline, color: AppTheme.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: TextStyle(color: AppTheme.error, fontSize: 13))),
                ]),
              ),
              const SizedBox(height: 16),
            ],

            // Upload Zone
            GestureDetector(
              onTap: _isAnalyzing ? null : _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedFile != null ? AppTheme.primary : AppTheme.grey.shade300,
                    width: _selectedFile != null ? 2 : 1,
                  ),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
                ),
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppTheme.subtle, borderRadius: BorderRadius.circular(16)),
                    child: Icon(
                      _selectedFile != null ? Icons.check_circle : Icons.cloud_upload_outlined,
                      size: 40,
                      color: _selectedFile != null ? AppTheme.primary : AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedFile != null ? _selectedFile!.name : 'Tap to browse or drop resume',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedFile != null
                        ? '✓ PDF ready — ${(_selectedFile!.size / 1024).toStringAsFixed(1)} KB'
                        : 'Supports PDF (Max 15MB) • Optimized for ATS & neural parser',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isAnalyzing ? null : _pickFile,
                    icon: Icon(_selectedFile != null ? Icons.swap_horiz : Icons.folder_open_outlined, color: AppTheme.cardBg),
                    label: Text(
                      _selectedFile != null ? 'Change File' : 'Choose PDF',
                      style: TextStyle(color: AppTheme.cardBg, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 24),

            // Target Career
            Text('Target Career Trajectory', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTrajectory,
                  isExpanded: true,
                  dropdownColor: AppTheme.cardBg,
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  icon: Icon(Icons.keyboard_arrow_down, color: AppTheme.primary),
                  items: _trajectories.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _selectedTrajectory = v!),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Seniority
            Text('Target Seniority Benchmark', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            Row(
              children: _seniorities.map((s) {
                final selected = s == _selectedSeniority;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedSeniority = s),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.primary : AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: selected ? AppTheme.primary : AppTheme.grey.shade300),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: selected ? AppTheme.cardBg : AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Analyze Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _analyzeResume,
                icon: _isAnalyzing
                    ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: AppTheme.cardBg, strokeWidth: 2))
                    : Icon(Icons.auto_awesome, color: AppTheme.cardBg),
                label: Text(
                  _isAnalyzing ? 'Analyzing with Gemini AI...' : 'Analyze & Generate Roadmap',
                  style: TextStyle(color: AppTheme.cardBg, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.purpleHighlight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '✦ Upon submission, Lumina benchmarks your skills against 14,200+ live verified industry rubrics to generate your dynamic learning blueprint.',
                style: TextStyle(fontSize: 12, color: AppTheme.deepPurpleText),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _stepBadge(String step, String label, bool active) {
    return Column(children: [
      Container(
        width: 28, height: 28,
        decoration: BoxDecoration(color: active ? AppTheme.primary : AppTheme.subtle, shape: BoxShape.circle),
        child: Center(child: Text(step, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: active ? AppTheme.cardBg : AppTheme.textSecondary))),
      ),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 10, color: active ? AppTheme.primary : AppTheme.textSecondary, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
    ]);
  }
}
