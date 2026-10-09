import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// アプリの起動スイッチです。ここからすべてが始まります。
void main() {
  runApp(const MyApp());
}

// ---------------------------------------------------
// アプリ全体の設定（色やテーマなど）
// ---------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // スマホのタスク一覧などで表示されるアプリの名前
      title: 'Web小説リーダー',
      
      // アプリ全体のデザイン（色合い）を決めます
      theme: ThemeData(
        // 💡ヒント：Colors.deepPurple を Colors.blue などに変えるとアプリ全体の色が変わります！
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      
      // 起動して最初に表示される画面
      home: const MainScreen(),
    );
  }
}

// ---------------------------------------------------
// 1. メイン画面（画面の下に「探す」「本棚」のタブがある土台）
// ---------------------------------------------------
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 現在選ばれているタブの番号を記憶する箱（0なら探す、1なら本棚）
  int _selectedIndex = 0;

  // タブのボタンが押された時に呼ばれる処理
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 画面の上のバー（AppBar）
      appBar: AppBar(
        title: const Text('マイWeb小説リーダー'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      
      // 画面の真ん中のメイン部分
      // 選ばれたタブの番号（_selectedIndex）を見て、表示する画面を切り替えます
      body: _selectedIndex == 0
          ? const PortalScreen() // 0なら「サイト一覧画面」を表示
          : const Center(child: Text('ここに保存した小説の一覧（本棚）を表示します')), // 1なら「本棚」を表示
          
      // 画面の下の切り替えタブ（BottomNavigationBar）
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          // 左側の「探す」タブ
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: '探す'),
          // 右側の「本棚」タブ
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: '本棚'),
        ],
        currentIndex: _selectedIndex, // 今光らせるタブの番号
        onTap: _onItemTapped, // 押されたら _onItemTapped を実行して画面を切り替える
      ),
    );
  }
}

// ---------------------------------------------------
// 2. 「サイト一覧画面」（お気に入りサイトが並ぶポータル画面）
// ---------------------------------------------------
class PortalScreen extends StatelessWidget {
  const PortalScreen({super.key});

  // サイトのボタンを押した時に「ブラウザ画面」へ移動するための共通の仕組み
  void _openBrowser(BuildContext context, String siteName, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BrowserScreen(siteName: siteName, url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 縦にスクロールできるリストを作ります
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // 見出しのテキスト
        const Text(
          'よく見るサイト', 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
        ),
        
        // テキストとボタンの間のちょっとした隙間
        const SizedBox(height: 10),

        // ----------------------
        // ハーメルンのボタン
        // ----------------------
        Card(
          child: ListTile(
            leading: const Icon(Icons.star, color: Colors.orange), // 星のアイコン
            title: const Text('ハーメルン'),
            subtitle: const Text('https://syosetu.org/'),
            trailing: const Icon(Icons.arrow_forward_ios), // 右向きの小さな矢印
            // タップされたら、名前とURLを渡してブラウザ画面を開く
            onTap: () => _openBrowser(context, 'ハーメルン', 'https://syosetu.org/'),
          ),
        ),

        // ----------------------
        // 小説家になろうのボタン
        // ----------------------
        Card(
          child: ListTile(
            leading: const Icon(Icons.book, color: Colors.blue), // 本のアイコン
            title: const Text('小説家になろう'),
            subtitle: const Text('https://yomou.syosetu.com/'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _openBrowser(context, '小説家になろう', 'https://yomou.syosetu.com/'),
          ),
        ),

        // ----------------------
        // カクヨムのボタン
        // ----------------------
        Card(
          child: ListTile(
            leading: const Icon(Icons.menu_book, color: Colors.green), // 開いた本のアイコン
            title: const Text('カクヨム'),
            subtitle: const Text('https://kakuyomu.jp/'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _openBrowser(context, 'カクヨム', 'https://kakuyomu.jp/'),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------
// 3. 「ブラウザ専用画面」（サイトを表示し、ダウンロードボタンを置く画面）
// ---------------------------------------------------
class BrowserScreen extends StatefulWidget {
  // 一覧画面から渡される「サイト名」と「URL」を受け取るための箱
  final String siteName;
  final String url;

  const BrowserScreen({super.key, required this.siteName, required this.url});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  // ブラウザを操るためのリモコン
  late final WebViewController _controller;

  // この画面が開かれた時の【最初の1回だけ】実行される準備処理
  @override
  void initState() {
    super.initState();
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // JavaScriptを許可
      ..loadRequest(Uri.parse(widget.url)); // 受け取ったURL（widget.url）を開く
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 画面の上のバー
      appBar: AppBar(
        // 受け取ったサイト名をタイトルに表示
        title: Text(widget.siteName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // 💡ヒント：この画面は「新しい画面」として開かれるため、
        // プログラムを書かなくてもFlutterが自動的に左端に「←（戻る）」ボタンを追加してくれます！
      ),
      
      // 画面の真ん中は、ブラウザ本体を表示
      body: WebViewWidget(controller: _controller),
      
      // 画面の右下に浮かぶ丸いボタン（ダウンロードボタン）
      floatingActionButton: FloatingActionButton(
        // ボタンが押された時の処理
        onPressed: () {
          // 画面の下から、短いメッセージ（SnackBar）を表示する
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('将来ここにダウンロード機能がつきます！')),
          );
        },
        child: const Icon(Icons.download), // ダウンロードのアイコン画像
      ),
    );
  }
}