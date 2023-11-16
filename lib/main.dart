import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AudioWebView(),
    );
  }
}

class AudioWebView extends StatefulWidget {
  @override
  _AudioWebViewState createState() => _AudioWebViewState();
}

class _AudioWebViewState extends State<AudioWebView> {

  WebViewController? controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(_createHtmlContent(2400));
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Simple Example')),
      body: Column(
        children: [
          ElevatedButton(onPressed: () {
            _onLoadPage();
          }, child: Text("Play"),),
          WebViewWidget(controller: controller!),
        ],
      ),
    );
  }

  Future<void> _onLoadPage() {
    return controller!.loadHtmlString(_createHtmlContent(400));
  }

  String _createHtmlContent(int frequency) {
    return '''
      <html>
      <body>
      <script>
        var context = new AudioContext();
        var oscillator = context.createOscillator();
        oscillator.type = 'sine';
        oscillator.frequency.setValueAtTime($frequency, context.currentTime);
        oscillator.connect(context.destination);
        oscillator.start();
      </script>
      </body>
      </html>
    ''';
  }
}