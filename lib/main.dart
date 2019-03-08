import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(ctx) =>
      MaterialApp(home: Game(), debugShowCheckedModeBanner: false);
}

class Game extends StatefulWidget {
  @override
  _Game createState() => _Game();
}

class _Game extends State<Game> {
  int siz = 14, max = 30, mov = 0, bst = 0;
  List<Color> clr = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
  ];
  List<List<int>> brd = [];

  dlg(w) =>
      showDialog(context: context, builder: (_) => AlertDialog(content: w));

  gen() {
    List<List<int>> _brd = [];
    Random random = new Random.secure();
    for (int i = 0; i < siz; i++) {
      List<int> r = [];
      for (int j = 0; j < siz; j++) r.add(random.nextInt(clr.length));
      _brd.add(r);
    }
    setState(() {
      mov = 0;
      brd = _brd;
    });
  }

  los() => mov >= max;

  pad(c, [p = 8.0]) => Padding(padding: EdgeInsets.all(p), child: c);

  pnt(int c, int r, int color) {
    int oldColor = brd[c][r];
    setState(() {
      brd[c][r] = color;
    });
    if (c - 1 >= 0 && brd[c - 1][r] == oldColor) pnt(c - 1, r, color);
    if (r + 1 < siz && brd[c][r + 1] == oldColor) pnt(c, r + 1, color);
    if (c + 1 < siz && brd[c + 1][r] == oldColor) pnt(c + 1, r, color);
    if (r - 1 >= 0 && brd[c][r - 1] == oldColor) pnt(c, r - 1, color);
  }

  prf() => SharedPreferences.getInstance();

  sel(int color) {
    if (brd[0][0] == color || win() || los()) return false;
    setState(() {
      mov += 1;
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
    for (int i = 0; i < siz; i++)
      for (int j = 0; j < siz; j++) if (color != brd[i][j]) return false;
    if (bst == null || mov < bst) {
      setState(() => bst = mov);
      prf().then((prefs) => prefs.setInt('best', mov));
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    gen();
    prf().then((prefs) => setState(() => bst = prefs.get('best')));
  }

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
            txt(mov.toString() + '/' + max.toString(), 28.0)
          ]),
          Flexible(
              child: pad(GridView.count(
                  primary: false,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  crossAxisCount: siz,
                  children: brd
                      .expand((pair) => pair)
                      .toList()
                      .map((int v) => GridTile(child: Container(color: clr[v])))
                      .toList()))),
          pad(Column(children: [
            txt('HIGH SCORE'),
            txt((bst ?? '-').toString(), 24.0)
          ])),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: clr
                .map((color) => ButtonTheme(
                    minWidth: 32,
                    child: RaisedButton(
                        elevation: 0,
                        color: color,
                        shape: CircleBorder(),
                        onPressed: () =>
                            sel(clr.indexWhere((_color) => _color == color)))))
                .toList(),
          )
        ],
      )));
}
