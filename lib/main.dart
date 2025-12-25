import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const HuarongRoadApp());
}

class HuarongRoadApp extends StatelessWidget {
  const HuarongRoadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '数字华容道',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  // 4x4 网格，1-15是数字，0代表空白
  List<int> numbers = [];
  int moveCount = 0;
  bool isWon = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  // 初始化并打乱（通过模拟随机移动确保一定有解）
  void _startNewGame() {
    numbers = List.generate(16, (index) => (index + 1) % 16); // 1,2...15,0
    moveCount = 0;
    isWon = false;
    
    // 模拟随机移动 500 次来打乱
    Random rng = Random();
    int emptyIndex = 15;
    int lastMove = -1;

    for (int i = 0; i < 500; i++) {
      List<int> neighbors = _getNeighbors(emptyIndex);
      // 避免来回移动
      neighbors.remove(lastMove);
      if (neighbors.isEmpty) { // 死胡同（极少见），重置
         lastMove = -1;
         continue; 
      }
      
      int target = neighbors[rng.nextInt(neighbors.length)];
      _swap(emptyIndex, target);
      lastMove = emptyIndex; // 记录上一次空白块的位置
      emptyIndex = target;
    }

    setState(() {});
  }

  // 获取空白块周围的可移动索引
  List<int> _getNeighbors(int index) {
    List<int> neighbors = [];
    int row = index ~/ 4;
    int col = index % 4;

    if (row > 0) neighbors.add(index - 4); // 上
    if (row < 3) neighbors.add(index + 4); // 下
    if (col > 0) neighbors.add(index - 1); // 左
    if (col < 3) neighbors.add(index + 1); // 右
    return neighbors;
  }

  void _swap(int index1, int index2) {
    int temp = numbers[index1];
    numbers[index1] = numbers[index2];
    numbers[index2] = temp;
  }

  void _onTileTap(int index) {
    if (isWon) return;

    int emptyIndex = numbers.indexOf(0);
    // 判断点击的格子是否在空白格旁边
    if (_isAdjacent(index, emptyIndex)) {
      setState(() {
        _swap(index, emptyIndex);
        moveCount++;
        _checkWin();
      });
    }
  }

  bool _isAdjacent(int index1, int index2) {
    int row1 = index1 ~/ 4;
    int col1 = index1 % 4;
    int row2 = index2 ~/ 4;
    int col2 = index2 % 4;
    return (row1 == row2 && (col1 - col2).abs() == 1) ||
           (col1 == col2 && (row1 - row2).abs() == 1);
  }

  void _checkWin() {
    for (int i = 0; i < 15; i++) {
      if (numbers[i] != i + 1) return;
    }
    setState(() {
      isWon = true;
    });
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("恭喜胜利！"),
        content: Text("你用了 $moveCount 步完成了游戏。"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _startNewGame();
            },
            child: const Text("再来一局"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("数字华容道 (离线版)")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text("步数: $moveCount", style: const TextStyle(fontSize: 24)),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: 16,
                    itemBuilder: (context, index) {
                      int number = numbers[index];
                      if (number == 0) return const SizedBox.shrink(); // 空白格
                      return GestureDetector(
                        onTap: () => _onTileTap(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "$number",
                            style: const TextStyle(
                                fontSize: 32, 
                                color: Colors.white, 
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("重新开始"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: _startNewGame,
            ),
          )
        ],
      ),
    );
  }
}
