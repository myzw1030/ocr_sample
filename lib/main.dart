import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

late List<CameraDescription> cameras;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // カメラ制御
  late CameraController _cameraController;
  String _extractedText = '';

  // カメラを初期化し、カメラのプレビューを行う
  void _initializeCamera() async {
    final camera = cameras[0];
    _cameraController = CameraController(camera, ResolutionPreset.max);
    _cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  // 写真撮影
  Future<void> _takePicture() async {
    // カメラコントロールが初期化されているか（カメラが使用可能かどうか）
    if (!_cameraController.value.isInitialized) {
      return;
    }
    // 写真を撮影
    final image = await _cameraController.takePicture();
    _recognizeTextFromImage(image.path);
  }

  // 写真からテキストを読み取り
  Future<void> _recognizeTextFromImage(String imagePath) async {
    // 画像のファイルパスを受け取る
    final inputImage = InputImage.fromFilePath(imagePath);
    // TextRecognizerの初期化（日本語設定 ※androidは日本語指定は失敗するのでデフォルトで使用すること）
    final textRecognizer =
        TextRecognizer(script: TextRecognitionScript.japanese);
    // 画像からテキストを読み取る（OCR処理）：認識されたテキストがRecognizedTextオブジェクトとして返される
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    // テキスト更新
    setState(() {
      _extractedText = recognizedText.text;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            // カメラのプレビュー表示
            Expanded(
              child: _cameraController.value.isInitialized
                  ? CameraPreview(_cameraController)
                  : const Center(child: CircularProgressIndicator()),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(_extractedText),
            ),
            ElevatedButton(
              onPressed: _takePicture,
              child: const Text('写真を撮る'),
            ),
          ],
        ),
      ),
    );
  }
}
