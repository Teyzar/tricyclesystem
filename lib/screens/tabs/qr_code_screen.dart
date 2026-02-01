import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_state.dart';

/// Driver QR code screen. QR contains only driverId (uid) — no sensitive data.
class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  bool _isGenerating = false;
  File? _qrCodeFile;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = _getDriverId(context);
    if (uid != null) {
      _loadExistingQRCode(uid);
    }
  }

  Future<void> _loadExistingQRCode(String uid) async {
    if (uid.isEmpty) return;

    try {
      final qrCodeFile = await _getQRCodeFile(uid);
      if (await qrCodeFile.exists()) {
        setState(() {
          _qrCodeFile = qrCodeFile;
          _errorMessage = null;
        });
      }
    } catch (e) {
      print('No existing QR code found: $e');
    }
  }

  Future<File> _getQRCodeFile(String uid) async {
    final appDir = await getApplicationDocumentsDirectory();
    final qrCodesDir = Directory('${appDir.path}/qr_codes');

    // Create qr_codes directory if it doesn't exist
    if (!await qrCodesDir.exists()) {
      await qrCodesDir.create(recursive: true);
    }

    return File('${qrCodesDir.path}/$uid.png');
  }

  Future<void> _generateQRCode(String uid) async {
    if (uid.isEmpty) {
      setState(() {
        _errorMessage = 'User ID not found. Please log in again.';
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      print('Generating QR Code for $uid');

      // Validate QR code data
      final qrValidationResult = QrValidator.validate(
        data: uid,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.Q,
      );

      if (qrValidationResult.status != QrValidationStatus.valid) {
        throw Exception("Invalid QR Code data");
      }

      // Generate QR code image
      final qrCode = qrValidationResult.qrCode!;
      final painter = QrPainter.withQr(
        qr: qrCode,
        color: Colors.black,
        emptyColor: Colors.white,
        gapless: true,
      );

      final picData = await painter.toImageData(300); // 300x300 px
      if (picData == null) {
        throw Exception("Failed to generate QR code image");
      }

      final buffer = picData.buffer;
      final bytes = buffer.asUint8List();

      // Save QR code to local storage
      final qrCodeFile = await _getQRCodeFile(uid);
      await qrCodeFile.writeAsBytes(bytes);

      setState(() {
        _qrCodeFile = qrCodeFile;
        _isGenerating = false;
      });

      print("QR Code saved to: ${qrCodeFile.path}");

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR Code generated and saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error generating QR code: $e');
      setState(() {
        _errorMessage = 'Failed to generate QR code: ${e.toString()}';
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteQRCode() async {
    final uid = _getDriverId(context);
    if (uid == null || _qrCodeFile == null) return;

    try {
      if (await _qrCodeFile!.exists()) {
        await _qrCodeFile!.delete();
        setState(() {
          _qrCodeFile = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('QR Code deleted successfully!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('Error deleting QR code: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting QR code: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Get driver id from UserBloc (no Firebase Auth in UI).
  static String? _getDriverId(BuildContext context) {
    final state = context.read<UserBloc>().state;
    if (state is UserLoaded && state.user.id != null) {
      return state.user.id;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final uid = _getDriverId(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My QR Code'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_qrCodeFile != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteQRCode,
              tooltip: 'Delete QR Code',
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isGenerating
                  ? const Center(child: CircularProgressIndicator())
                  : _qrCodeFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _qrCodeFile!,
                        width: 196,
                        height: 196,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.qr_code,
                              size: 150,
                              color: Theme.of(context).primaryColor,
                            ),
                          );
                        },
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.qr_code,
                        size: 150,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
            ),
            const SizedBox(height: 24),
            Text(
              'Driver QR Code',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Show this QR code to students for scanning',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            if (_qrCodeFile != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Text(
                  'QR Code saved locally',
                  style: TextStyle(color: Colors.green[700]),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red[700]),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isGenerating || uid == null
                  ? null
                  : () => _generateQRCode(uid),
              icon: _isGenerating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label: Text(
                _isGenerating ? 'Generating...' : 'Generate New QR Code',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
