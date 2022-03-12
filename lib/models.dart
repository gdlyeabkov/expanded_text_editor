class Bookmark {
  final int? id;
  final String name;
  final String path;

  Bookmark({
    this.id,
    required this.name,
    required this.path
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'path': path
    };
  }

  Bookmark.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        name = res["name"],
        path = res["path"];

}

enum FileSortType {
  name,
  date
}

enum TimeStampType {
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  eleven,
  twelth
}

enum EncodingType {
  utf8,
  utf16,
  utf16be
}

enum StyleType {
  Default,
  GitHub,
  GitHubv2,
  Tommorow,
  Hemisu,
  AtelierCave,
  AtelierDune,
  AtelierEstuary,
  AtelierForest,
  AtelierHeath,
  AtelierLakeside,
  AtelierPlateau,
  AtelierSavanna,
  AtelierSeaside,
  AtelierSulphurpool
}

enum LangType {
  auto,
  rus,
  eng
}

enum BreakLineType {
  auto,
  linux,
  windows,
  macos
}

enum ParagraphCharType {
  tab,
  spaceChars
}

enum HintsType {
  enabled,
  disabled,
  fullDisabled
}

enum FontFamilyType {
  normal,
  sansSerif,
  serif,
  monospace,
  external
}

enum AutoSaveIntervalType {
  mins0secondss30,
  mins1,
  mins3,
  mins5,
  mins10
}

enum ThemeType {
  light,
  dark,
  black
}