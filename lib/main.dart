import 'dart:io';
import 'dart:math';
import 'package:flame/flame.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: SystemChrome.setPreferredOrientations(
            [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]),
        builder: (BuildContext context, _) {
          return MaterialApp(title: 'Flood', home: Game());
        });
  }
}

class Game extends StatefulWidget {
  @override
  _Game createState() {
    return _Game();
  }
}

class _Game extends State<Game> {
  final int size = 10;
  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
  ];
  List<List<int>> board = [];
  int moves = 0;

  generate() {
    List<List<int>> _board = [];
    Random random = new Random.secure();
    for (int i = 0; i < size; i++) {
      List<int> r = [];
      for (int j = 0; j < size; j++) {
        r.add(random.nextInt(colors.length));
      }
      _board.add(r);
    }
    setState(() {
      moves = 0;
      board = _board;
    });
  }

  select(int color) {
    if (board[0][0] == color) return false;
    if (completed()) return false;
    setState(() {
      moves += 1;
    });
    paint(0, 0, color);
    Flame.audio.play('water.mp3');
  }

  paint(int c, int r, int color) {
    int oldColor = board[c][r];
    setState(() {
      board[c][r] = color;
    });
    if (c - 1 >= 0 && board[c - 1][r] == oldColor) {
      paint(c - 1, r, color);
    }
    if (r + 1 < size && board[c][r + 1] == oldColor) {
      paint(c, r + 1, color);
    }
    if (c + 1 < size && board[c + 1][r] == oldColor) {
      paint(c + 1, r, color);
    }
    if (r - 1 >= 0 && board[c][r - 1] == oldColor) {
      paint(c, r - 1, color);
    }
  }

  completed() {
    int color = board[0][0];
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (color != board[i][j]) return false;
      }
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    generate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        brightness: Platform.isIOS ? Brightness.light : Brightness.dark,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.help), onPressed: null),
          IconButton(icon: Icon(Icons.format_list_numbered), onPressed: null),
          IconButton(icon: Icon(Icons.refresh), onPressed: () => generate())
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Flexible(
              child: GridView.count(
                  primary: false,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  crossAxisCount: size,
                  children: board
                      .expand((pair) => pair)
                      .toList()
                      .map(
                        (int v) => GridTile(
                              child: Container(
                                color: colors[v],
                              ),
                            ),
                      )
                      .toList()),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: Text(
                    'Moves',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Flexible(
                  child: Text(
                    moves.toString(),
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: colors.map((color) {
                return ButtonTheme(
                  minWidth: 32,
                  child: RaisedButton(
                    elevation: 0,
                    color: color,
                    shape: new CircleBorder(),
                    onPressed: () =>
                        select(colors.indexWhere((_color) => _color == color)),
                  ),
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}
