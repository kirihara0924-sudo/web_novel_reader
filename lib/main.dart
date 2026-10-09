import 'package:flutter/material.dart'; // Flutterの基本的なUI部品を使うために必要な宣言
import 'package:webview_flutter/webview_flutter.dart'; // WebView（ブラウザ）を使うために必要な宣言
import 'package:shared_preferences/shared_preferences.dart'; // データを端末に保存するために必要な宣言

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
          : const BookshelfScreen(), // 1なら上で新しく作った「本棚画面」を表示！
          
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
      
            // 画面の右下に浮かぶ丸いボタン
            // 画面の右下に浮かぶ丸いボタン
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 1. スナイパー（JavaScript）への命令文を作成する
          // 「novel_subtitle（サブタイトル）」と「novel_honbun（本文）」の箱を狙撃します
           final jsCode = '''
            (function() {
              // ① サブタイトルの箱をいろんな名前で探す
              var subtitleElement = document.querySelector('.novel_subtitle') 
                                 || document.querySelector('.p-novel__title--episode')
                                 || document.querySelector('.novel_title')
                                 || document.querySelector('.episode_title');
                                 
              // 見つからなければ、「ページ全体のタイトル」をサブタイトルとして代用する！
              var subtitleText = subtitleElement ? subtitleElement.innerText : document.title;
                          
              // ② 本文の箱を探す
              var honbunElement = document.getElementById('novel_honbun') 
                               || document.querySelector('.js-novel-text')
                               || document.querySelector('.p-novel__body');
              
              // 本文すら無ければエラー
              if (!honbunElement) return "エラー: 小説の本文が見つかりません！";
              // ③ 無事に両方揃ったら、合体させて返す！
              return subtitleText + "|||\\n\\n" + honbunElement.innerText;
            })();
          ''';
          
          // 2. ブラウザに命令を送り込んで、結果（文字データ）を受け取る！
          final result = await _controller.runJavaScriptReturningResult(jsCode);
          
          // 3. 受け取ったデータから、余計な記号を掃除して綺麗な文章にする
          final cleanText = result.toString().replaceAll('"', '').replaceAll(r'\n', '\n');
          
          // 4. 抽出した文字を、画面の真ん中にポップアップ（ダイアログ）でドーンと表示する！
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('🎯 抽出成功！'),
                content: SingleChildScrollView(
                  child: Text(cleanText), // 抜き出した文字を表示！
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('閉じる'),
                  ),
                ],
              ),
            );
          }
        },
        child: const Icon(Icons.get_app), // アイコンをダウンロード矢印に変更
      ),
    );
  }
}

// ---------------------------------------------------
// 4. 「本棚画面」（保存したデータを読み込んで一覧表示する画面）
// ---------------------------------------------------
class BookshelfScreen extends StatefulWidget {
  const BookshelfScreen({super.key});

  @override
  State<BookshelfScreen> createState() => _BookshelfScreenState();
}

class _BookshelfScreenState extends State<BookshelfScreen> {
  // 読み込んだデータを一時的に入れておく箱
  List<String> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks(); // 画面が開かれた時に、記憶装置からデータを読み込む
  }

  // 記憶装置からデータを引っ張り出してくる処理
  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // 記憶装置からリストを取り出す。無ければ空っぽにする。
      _bookmarks = prefs.getStringList('my_bookmarks') ?? [];
    });
  }

  // 本棚から項目を消す（削除）処理
  Future<void> _deleteBookmark(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bookmarks.removeAt(index); // リストから指定された番号のものを消す
    });
    await prefs.setStringList('my_bookmarks', _bookmarks); // 消した後のリストを上書きセーブ
  }

  @override
  Widget build(BuildContext context) {
    // まだ1つも保存されていない場合の画面
    if (_bookmarks.isEmpty) {
      return const Center(child: Text('まだ本棚には何もありません。'));
    }

    // 保存されているデータをリストにして表示する
    return ListView.builder(
      itemCount: _bookmarks.length,
      itemBuilder: (context, index) {
        // 保存されている "タイトル|URL" という文字列を、「|」の記号で真っ二つに割る
        final data = _bookmarks[index].split('|');
        final title = data[0]; // 前半がタイトル
        final url = data.length > 1 ? data[1] : ''; // 後半がURL

        return Card(
          child: ListTile(
            leading: const Icon(Icons.bookmark, color: Colors.deepPurple),
            title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis), // タイトルが長すぎたら「...」にする
            subtitle: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
            
            // タップしたら、またブラウザ画面を呼び出して続きを読む！
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BrowserScreen(siteName: title, url: url),
                ),
              );
            },
            
            // ゴミ箱ボタン（押したら消える）
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.grey),
              onPressed: () => _deleteBookmark(index),
            ),
          ),
        );
      },
    );
  }
}