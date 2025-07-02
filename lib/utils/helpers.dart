class Helpers {
  static String formatItemIds(List<int> ids) => ids.join(',');
  static List<int> parseItemIds(String csv) =>
      csv.split(',').map((id) => int.parse(id)).toList();
}
