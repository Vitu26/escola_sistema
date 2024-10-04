class Documents {
  final String title;
  final String link;

  Documents({
    required this.title,
    required this.link,
  });

  factory Documents.fromJson(Map<String, dynamic> json) {
    return Documents(
      title: json['title'],
      link: json['link'],
    );
  }
}
