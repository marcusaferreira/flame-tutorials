import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:klondike/card.dart';
import 'package:klondike/components/pile.dart';
import 'package:klondike/components/waste_pile.dart';
import 'package:klondike/klondike_game.dart';

class StockPile extends PositionComponent
    with HasGameReference<KlondikeGame>
    implements Pile {
  StockPile({super.position}) : super(size: KlondikeGame.cardSize);

  final List<Card> _cards = [];

  @override
  bool canMoveCard(Card card, MoveMethod method) => false;

  @override
  bool canAcceptCard(Card card) => false;

  @override
  void removeCard(Card card, MoveMethod method) =>
      throw StateError('cannot remove cards');

  @override
  void returnCard(Card card) => card.priority = _cards.indexOf(card);

  @override
  void acquireCard(Card card) {
    assert(!card.isFaceUp);
    card.position = position;
    card.priority = _cards.length;
    card.pile = this;
    _cards.add(card);
  }

  void handleTapUp(Card card) {
    final wastePile = parent!.firstChild<WastePile>()!;
    if (_cards.isEmpty) {
      assert(card.isBaseCard, 'Stock Pile is empty, but no Base Card present');
      card.position = position; // Force Base Card (back) into correct position.
      wastePile.removeAllCards().reversed.forEach((card) {
        card.flip();
        acquireCard(card);
      });
    } else {
      for (var i = 0; i < game.klondikeDraw; i++) {
        if (_cards.isNotEmpty) {
          final card = _cards.removeLast();
          card.doMoveAndFlip(
            wastePile.position,
            whenDone: () {
              wastePile.acquireCard(card);
            },
          );
        }
      }
    }
  }

  final _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10
    ..color = const Color(0xFF3F5B5D);

  final _circlePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 100
    ..color = const Color(0x883F5B5D);

  void render(Canvas canvas) {
    canvas.drawRRect(KlondikeGame.cardRRect, _borderPaint);
    canvas.drawCircle(Offset(width / 2, height / 2),
        KlondikeGame.cardWidth * 0.3, _circlePaint);
  }
}
