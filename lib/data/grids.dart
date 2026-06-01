/// Grid sizes, from 4x3 up to 8x6, as advertised on the store listing.
class GridSize {
  final String label;
  final int cols;
  final int rows;
  const GridSize(this.label, this.cols, this.rows);

  int get pairs => (cols * rows) ~/ 2;
  String get key => '${cols}x$rows';
  @override
  String toString() => '$cols×$rows';
}

const List<GridSize> kGrids = [
  GridSize('Ușor', 4, 3),       // 6 pairs
  GridSize('Simplu', 4, 4),     // 8 pairs
  GridSize('Mediu', 5, 4),      // 10 pairs
  GridSize('Avansat', 6, 4),    // 12 pairs
  GridSize('Greu', 6, 5),       // 15 pairs
  GridSize('Foarte greu', 6, 6),// 18 pairs
  GridSize('Provocare', 7, 6),  // 21 pairs
  GridSize('Expert', 8, 6),     // 24 pairs
];

/// The hardest grid — used by the "Memory Master" achievement.
final GridSize kHardestGrid = kGrids.last;
