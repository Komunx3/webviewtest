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

  WebViewController? _controller;

  // Frequence in Hz
  int _currentFrequency = 400;

  // Bandbreite in Hz
  int _currentBandbreite = 1000;

  bool _rauschen = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
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
      );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Simple Example')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Rauschen:"),
              Switch(value: _rauschen, onChanged: (value) {
                setState(() {
                  _rauschen = !_rauschen;

                  if(_rauschen) {
                    _currentFrequency = 6000;
                    _currentBandbreite = 100;
                  }
                });
              },),
            ],
          ),
          Text("Aktuelle Frequenz: " + _currentFrequency.toString()),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () {
                setState(() {
                  _currentFrequency-=400;
                });
              }, child: Text("-"),),
              SizedBox(width: 10),
              ElevatedButton(onPressed: () {
                setState(() {
                  _currentFrequency+=400;
                });
              }, child: Text("+"),),
            ],
          ),
          if(_rauschen) Text("Aktuelle Bandbreite: " + _currentBandbreite.toString()),
          if(_rauschen)  Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () {
                setState(() {
                  _currentBandbreite-=200;
                });
              }, child: Text("-"),),
              SizedBox(width: 10),
              ElevatedButton(onPressed: () {
                setState(() {
                  _currentBandbreite+=200;
                });
              }, child: Text("+"),),
            ],
          ),
          ElevatedButton(onPressed: () {
            _reloadPage();
          }, child: Text("Reload Webview"),),
          SizedBox(child: WebViewWidget(controller: _controller!), width: 200, height: 200,),
        ],
      ),
    );
  }

  Future<void> _reloadPage() async {
    String renderedContent;

    if(!_rauschen) {
      renderedContent = _createHtmlContentNormal(_currentFrequency);
    } else {
      renderedContent = _createHtmlContentForRauschen(_currentFrequency, _currentBandbreite);
    }

    return _controller!.loadHtmlString(renderedContent);
  }

  String _createHtmlContentNormal(int frequency) {
    return '''
      <html>
      <body>
      <script>
        var context = new AudioContext();
        var oscillator;
        
        if (oscillator) {
         oscillator.stop();
         oscillator.disconnect();
        } 
      
        oscillator = context.createOscillator();
        oscillator.type = 'sine';
        oscillator.frequency.setValueAtTime($frequency, context.currentTime);
        oscillator.connect(context.destination);
        oscillator.start();
      </script>
      </body>
      </html>
    ''';
  }

  String _createHtmlContentForRauschen(int frequency, int bandbreite) {
    double qualityFaktor = frequency/bandbreite;

    return '''
      <html>
      <body>
      <script>
         var context = new AudioContext();

      function createWhiteNoise() {
        var bufferSize = 2 * context.sampleRate, // 2 Sekunden Buffer
            noiseBuffer = context.createBuffer(1, bufferSize, context.sampleRate),
            output = noiseBuffer.getChannelData(0);
        for (var i = 0; i < bufferSize; i++) {
            output[i] = Math.random() * 2 - 1; // Zufällige Werte zwischen -1 und 1
        }

        var whiteNoise = context.createBufferSource();
        whiteNoise.buffer = noiseBuffer;
        whiteNoise.loop = true;
        whiteNoise.start(0);
        return whiteNoise;
      }

      var whiteNoiseSource = createWhiteNoise();
      whiteNoiseSource.connect(context.destination); // Verbinden zum Audio-Kontext
      </script>
      </body>
      </html>
    ''';
  }
}