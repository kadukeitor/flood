import 'dart:io';
import 'dart:math';
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
          return MaterialApp(home: Game(), debugShowCheckedModeBanner: false);
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
  int size = 14, moves = 0, max = 30;
  List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
  ];
  List<List<int>> board = [];

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

  select(int color) async {
    if (board[0][0] == color || completed() || loosed()) return false;
    setState(() {
      moves += 1;
    });
    paint(0, 0, color);
    if (completed())
      dialog(Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.sentiment_satisfied, size: 48),
        text("YOU WIN")
      ]));
    if (loosed()) {
      dialog(Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.sentiment_dissatisfied, size: 48),
        text("YOU LOOSE")
      ]));
    }
  }

  paint(int c, int r, int color) {
    int oldColor = board[c][r];
    setState(() {
      board[c][r] = color;
    });
    if (c - 1 >= 0 && board[c - 1][r] == oldColor) paint(c - 1, r, color);
    if (r + 1 < size && board[c][r + 1] == oldColor) paint(c, r + 1, color);
    if (c + 1 < size && board[c + 1][r] == oldColor) paint(c + 1, r, color);
    if (r - 1 >= 0 && board[c][r - 1] == oldColor) paint(c, r - 1, color);
  }

  loosed() => moves >= max;

  completed() {
    int color = board[0][0];
    for (int i = 0; i < size; i++)
      for (int j = 0; j < size; j++) if (color != board[i][j]) return false;
    return true;
  }

  text(s, [f = 14.0]) => Text(s, style: TextStyle(fontSize: f));

  dialog(w) =>
      showDialog(context: context, builder: (_) => AlertDialog(content: w));

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
          IconButton(
              icon: Icon(Icons.help),
              onPressed: () => dialog(
                  Image.asset('assets/images/help.png', fit: BoxFit.contain))),
          IconButton(icon: Icon(Icons.refresh), onPressed: () => generate())
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Column(
                children: <Widget>[
                  text('MOVES', 18.0),
                  text(moves.toString() + '/' + max.toString(), 28.0)
                ],
              ),
            ),
            Flexible(
              child: GridView.count(
                  primary: false,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  crossAxisCount: size,
                  children: board
                      .expand((pair) => pair)
                      .toList()
                      .map((int v) =>
                          GridTile(child: Container(color: colors[v])))
                      .toList()),
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
                        onPressed: () => select(
                            colors.indexWhere((_color) => _color == color))));
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}
