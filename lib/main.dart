import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(ctx) => FutureBuilder(
      future: SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]),
      builder: (ctx, _) =>
          MaterialApp(home: Game(), debugShowCheckedModeBanner: false));
}

class Game extends StatefulWidget {
  @override
  _Game createState() => _Game();
}

class _Game extends State<Game> {
  int size = 14, max = 30, moves = 0, best = 0;
  List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
  ];
  List<List<int>> brd = [];

  @override
  Widget build(BuildContext ctx) => Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        brightness: Platform.isIOS ? Brightness.light : Brightness.dark,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.help),
              onPressed: () => dlg(
                  Image.asset('assets/images/help.png', fit: BoxFit.contain))),
          IconButton(icon: Icon(Icons.refresh), onPressed: () => gen())
        ],
      ),
      body: pad(Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(children: [
            txt('MOVES'),
            txt(moves.toString() + '/' + max.toString(), 28.0)
          ]),
          Flexible(
              child: pad(GridView.count(
                  primary: false,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  crossAxisCount: size,
                  children: brd
                      .expand((pair) => pair)
                      .toList()
                      .map((int v) =>
                          GridTile(child: Container(color: colors[v])))
                      .toList()))),
          pad(Column(children: [
            txt('HIGH SCORE'),
            txt((best ?? '-').toString(), 24.0)
          ])),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: colors
                .map((color) => ButtonTheme(
                    minWidth: 32,
                    child: RaisedButton(
                        elevation: 0,
                        color: color,
                        shape: CircleBorder(),
                        onPressed: () => sel(
                            colors.indexWhere((_color) => _color == color)))))
                .toList(),
          )
        ],
      )));

  dlg(w) =>
      showDialog(context: context, builder: (_) => AlertDialog(content: w));

  gen() {
    List<List<int>> _brd = [];
    Random random = new Random.secure();
    for (int i = 0; i < size; i++) {
      List<int> r = [];
      for (int j = 0; j < size; j++) r.add(random.nextInt(colors.length));
      _brd.add(r);
    }
    setState(() {
      moves = 0;
      brd = _brd;
    });
  }

  @override
  void initState() {
    super.initState();
    gen();
    prf().then((prefs) => setState(() => best = prefs.get('best')));
  }

  los() => moves >= max;

  pad(c, [p = 8.0]) => Padding(padding: EdgeInsets.all(p), child: c);

  pnt(int c, int r, int color) {
    int oldColor = brd[c][r];
    setState(() {
      brd[c][r] = color;
    });
    if (c - 1 >= 0 && brd[c - 1][r] == oldColor) pnt(c - 1, r, color);
    if (r + 1 < size && brd[c][r + 1] == oldColor) pnt(c, r + 1, color);
    if (c + 1 < size && brd[c + 1][r] == oldColor) pnt(c + 1, r, color);
    if (r - 1 >= 0 && brd[c][r - 1] == oldColor) pnt(c, r - 1, color);
  }

  prf() => SharedPreferences.getInstance();

  sel(int color) {
    if (brd[0][0] == color || win() || los()) return false;
    setState(() {
      moves += 1;
    });
    pnt(0, 0, color);
    if (win())
      dlg(Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.sentiment_satisfied, size: 48),
        txt("YOU WIN")
      ]));
    else if (los())
      dlg(Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.sentiment_dissatisfied, size: 48),
        txt("YOU LOSE")
      ]));
  }

  txt(s, [f = 14.0]) =>
      Text(s, style: TextStyle(fontSize: f, color: Colors.black));

  win() {
    int color = brd[0][0];
    for (int i = 0; i < size; i++)
      for (int j = 0; j < size; j++) if (color != brd[i][j]) return false;
    if (best == null || moves < best) {
      setState(() => best = moves);
      prf().then((prefs) => prefs.setInt('best', moves));
    }
    return true;
  }
}
