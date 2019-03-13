# Flood

The tide is coming

![Alt text](assets/images/screenshot.png?raw=true "Flood")

## How to play

The goal of the game is to fill the board with a single color in less than 30 moves.  
The game starts a the top left corner of the board and you can chose any color at the bottom to match as much squares as possible in a single play.

## Project Description

Flood is a minimalistic application (less than 5k) written in Flutter intended to be played in Android and iOS.

## Technical Details
- Just one package imported (shared_preferences) that allow users to store their high scores.
- Reformatted with `dartfmt`.
- Orientation locked to `portrait`.  

## Features

- Board with 6 different colors.
- Limited amount of moves by game (30).
- Persistent high score (in the device).
- Instructions to play.

## To do (not enough with 5K)

- Board animations (using Flare).
- Timer.
- More granular scoring system (combining time & moves).
- User's high score list.
- Sounds.
- i18n.
- Color schemes.
- Online high score board (remote list using Firebase).
- Tests :-(.

## Scripts

- Get code size: `./size.sh`.
- Generate new launcher icons: `./icons.sh`.

### Size

```
find . -name "*.dart" | xargs cat | wc -c
```

### Launcher

```
flutter packages pub run flutter_launcher_icons:main
```

### Archive

```
git archive -o build/flood.zip HEAD
```

## License

MIT