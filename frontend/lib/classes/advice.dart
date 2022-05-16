
class Advice {

  Advice({
    required this.id,
    required this.title,
    required this.description,
    required this.timeOptions,
    required this.xps,
    this.isExpanded = false,
    
  });

  final  String id;
  final String title;
  final String description;
  final List<int> timeOptions;
  final int xps;
  bool isExpanded;
}
