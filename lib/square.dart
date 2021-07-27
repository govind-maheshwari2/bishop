import 'constants.dart';
import 'variant.dart';

typedef Square = int;

extension SquareLogic on Square {
  Colour get colour => this & 1;
  int get piece => (this >> 1) & 127;
  int get flags => (this >> 8) & 15;
  bool get isEmpty => this == 0;
  bool get isNotEmpty => this != 0;
}

Square square(int piece, Colour colour, [int flags = 0]) {
  assert(colour <= BLACK);
  return (flags << 8) + (piece << 1) + colour;
}

String squareName(int square, BoardSize boardSize) {
  int rank = square ~/ boardSize.h + 1;
  int file = square % boardSize.h;
  String fileName = String.fromCharCode(ASCII_a + file);
  return '$fileName$rank';
}

int squareNumber(String name, BoardSize boardSize) {
  name = name.toLowerCase();
  RegExp rx = RegExp(r'([A-Za-z])([0-9]+)');
  RegExpMatch? match = rx.firstMatch(name);
  assert(match != null, 'Invalid square name: $name');
  assert(match!.groupCount == 2, 'Invalid square name: $name');
  String file = match!.group(1)!;
  String rank = match.group(2)!;
  int _file = file.codeUnits[0] - ASCII_a;
  int _rank = int.parse(rank) - 1;
  int square = _rank * boardSize.h + _file;
  return square;
}
