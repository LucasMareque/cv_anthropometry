import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:create_app_flutter/models/analysis_result.dart';
import 'package:create_app_flutter/screens/camera_capture_screen.dart';
import 'package:create_app_flutter/services/analysis_api_service.dart';

/// URL base del backend (sin barra final). Cámbiala o edítala desde el menú lateral.
const String kDefaultApiBaseUrl = 'https://api.ejemplo.com';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController(
    text: kDefaultApiBaseUrl,
  );
  final TextEditingController _pathController = TextEditingController(
    text: '/analyze',
  );

  AnalysisResult? _lastResult;
  bool _loading = false;
  String? _lastError;

  @override
  void dispose() {
    _urlController.dispose();
    _pathController.dispose();
    super.dispose();
  }

  AnalysisApiService get _api => AnalysisApiService(
        baseUrl: _urlController.text.trim(),
        analyzePath: _pathController.text.trim().isEmpty
            ? '/analyze'
            : _pathController.text.trim(),
      );

  Future<void> _openCameraAndAnalyze() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Se necesita permiso de cámara para tomar la fotografía del cliente.',
          ),
        ),
      );
      return;
    }

    final path = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const CameraCaptureScreen()),
    );

    if (path == null || path.isEmpty) return;

    setState(() {
      _loading = true;
      _lastError = null;
    });

    try {
      final result = await _api.analyzeImageFile(path);
      if (!mounted) return;
      setState(() {
        _lastResult = result;
        _loading = false;
      });
    } on AnalysisApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _lastError = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _lastError = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Salud cardiovascular'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.92),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.favorite_outline,
                      size: 40,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Menú',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Análisis asistido por imagen',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text('URL del API', style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'https://tu-servidor.com',
                ),
                keyboardType: TextInputType.url,
                autocorrect: false,
              ),
              const SizedBox(height: 12),
              Text('Ruta del endpoint', style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              TextField(
                controller: _pathController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '/analyze',
                ),
                autocorrect: false,
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Acerca de'),
                subtitle: const Text(
                  'Los indicadores son estimaciones del modelo en el servidor. '
                  'No sustituyen valoración médica.',
                ),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/home_background.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.surface.withValues(alpha: 0.72),
                  theme.colorScheme.surface.withValues(alpha: 0.88),
                ],
              ),
            ),
          ),
          SafeArea(
            child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Análisis de salud cardiovascular',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Procedimiendo: Alejate de la cámara formando una T contus brazos. Coloca tu cuerpo en la figura descripta.'
            'El servidor (TensorFlow) devolverá medidas aproximadas como perímetro de cintura o ancho de brazo.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates_outlined,
                          color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Consejos para la captura',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _bullet(theme, 'Buena iluminación y fondo neutro.'),
                  _bullet(theme, 'Encuadre cuerpo completo o región según protocolo clínico.'),
                  _bullet(theme, 'Evita sombras fuertes sobre el contorno del cuerpo.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loading ? null : _openCameraAndAnalyze,
              icon: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.photo_camera_outlined),
              label: Text(_loading ? 'Analizando…' : 'Capturar y analizar'),
            ),
          ),
          if (_lastError != null) ...[
            const SizedBox(height: 20),
            Material(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline, color: theme.colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _lastError!,
                        style: TextStyle(color: theme.colorScheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (_lastResult != null) ...[
            const SizedBox(height: 24),
            Text(
              'Resultado del análisis',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _ResultCard(result: _lastResult!),
          ],
        ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullet(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: theme.textTheme.bodyMedium),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final AnalysisResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = <Widget>[];

    void addIf(String label, double? value, String unit) {
      if (value == null) return;
      rows.add(
        ListTile(
          title: Text(label),
          trailing: Text(
            '${value.toStringAsFixed(1)} $unit',
            style: theme.textTheme.titleMedium,
          ),
        ),
      );
    }

    addIf('Perímetro de cintura (aprox.)', result.waistCircumferenceCm, 'cm');
    addIf('Ancho de brazo (aprox.)', result.armWidthCm, 'cm');
    addIf('Perímetro de cadera (aprox.)', result.hipCircumferenceCm, 'cm');
    addIf('Perímetro de pecho (aprox.)', result.chestCircumferenceCm, 'cm');

    if (result.confidence != null) {
      final c = result.confidence!;
      final pct = c <= 1 ? c * 100 : c;
      rows.add(
        ListTile(
          title: const Text('Confianza del modelo'),
          trailing: Text(
            '${pct.toStringAsFixed(0)}%',
            style: theme.textTheme.titleMedium,
          ),
        ),
      );
    }

    if (rows.isEmpty) {
      rows.add(
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'El servidor respondió pero no se reconocieron campos conocidos. '
            'Revisa el modelo [AnalysisResult] o el JSON devuelto.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Card(
      child: Column(children: rows),
    );
  }
}
