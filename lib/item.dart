class BoughtItem {
  late String name;
  late int boughtPrice;
  late DateTime boughtWhen;
  late String comments;

  BoughtItem(
      {required this.name,
      required this.boughtPrice,
      required this.boughtWhen,
      required this.comments});
}

class SoldItem {
  late String name;
  late int boughtPrice;
  late int soldPrice;
  late DateTime boughtWhen;
  late DateTime soldWhen;
  late String comments;

  double get profitPercent =>
      double.parse((soldPrice / boughtPrice * 100 - 100).toStringAsFixed(2));
  int get daysTaken => DateTime(soldWhen.year, soldWhen.month, soldWhen.day)
      .difference(DateTime(boughtWhen.year, boughtWhen.month, boughtWhen.day))
      .inDays;
  double get profitPercentPerDay => double.parse(
      (profitPercent / (daysTaken > 0 ? daysTaken : 1)).toStringAsFixed(2));

  SoldItem(
      {required this.name,
      required this.boughtPrice,
      required this.soldPrice,
      required this.boughtWhen,
      required this.soldWhen,
      required this.comments});
}
