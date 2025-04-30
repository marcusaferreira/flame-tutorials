import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:klondike/klondike_game.dart';

main(){
  final game = KlondikeGame();
  runApp(GameWidget(game: game));
}