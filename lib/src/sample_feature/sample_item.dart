import 'package:flutter_study/src/sample_feature/sample_item_details_view.dart';

/// A placeholder class that represents an entity or model.
class SampleItem {
  const SampleItem(
      {this.id = 0,
      this.name = '',
      this.routeName = SampleItemDetailsView.routeName});

  final int id;
  final String name;
  final String routeName;
}
