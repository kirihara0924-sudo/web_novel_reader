import 'package:flutter/material.dart'; // 画面を作るための基本ブロックを読み込む

void main() {
  runApp(const MyApp()); // アプリを起動する
}

// アプリ全体の設定
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web小説リーダー',
      theme: ThemeData(
        // アプリのメインカラー（ここでは深い紫色）
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), 
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

// メインの画面（タブ切り替え機能付き）
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 現在選ばれているタブの番号（0=探す、1=本棚）

  // タブごとの画面の中身
  static const List<Widget> _widgetOptions = <Widget>[
    Text('ここに内部ブラウザ（小説サイト）を表示します'), // 解説: 0番目の画面
    Text('ここに保存した小説の一覧（本棚）を表示します'), // 解説: 1番目の画面
  ];

  // タブが押された時に実行される処理
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // 選ばれた番号を更新して画面を切り替える
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 画面の上のバー（AppBar）
      appBar: AppBar(
        title: const Text('Web小説リーダー'), 
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // 画面の真ん中（Body）
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // 画面の下のタブナビゲーション
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.explore), // 探すアイコン（コンパス）
            label: '探す',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book), // 本アイコン
            label: '本棚',
          ),
        ],
        currentIndex: _selectedIndex, // 今選ばれているタブ
        onTap: _onItemTapped, // タブが押されたら呼び出す
      ),
    );
  }
}