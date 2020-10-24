import 'package:airscaper/model/entities/scenario_item.dart';
import 'package:airscaper/model/entities/scenario_loot.dart';

class InventoryState {
  final List<ScenarioItem> items;
  final Set<int> usedItems;
  final Set<int> resolvedItems;
  final Set<int> usedClues;
  final bool loading;
  final int selectedItem;
  final int newItem;
  final bool hasEnded;

  InventoryState(
      {this.items,
      this.resolvedItems = const {},
      this.usedItems = const {},
      this.usedClues = const {},
      this.loading = false,
      this.hasEnded = false,
      this.selectedItem,
      this.newItem});

  InventoryState clone(
          {List<ScenarioItem> items,
          Set<int> usedItems,
          Set<int> resolvedItems,
          Set<int> usedClues,
          bool loading,
          bool hasEnded,
          int selectedItem,
          int displayedItem,
          int newItem}) =>
      InventoryState(
          items: items ?? this.items,
          usedItems: usedItems ?? this.usedItems,
          resolvedItems: resolvedItems ?? this.resolvedItems,
          hasEnded: hasEnded ?? hasEnded,
          loading: loading ?? this.loading,
          selectedItem: selectedItem ?? this.selectedItem,
          newItem: newItem);

  ScenarioItem get selectedScenarioItem => items
      .firstWhere((element) => element.id == selectedItem, orElse: () => null);

  List<ScenarioItem> get unusedItems =>
      items.where((element) => !resolvedItems.contains(element.id));

  bool isItemAlreadyUsed(int id) =>
      !usedItems.contains(id) && !resolvedItems.contains(id);

  List<ScenarioLoot> filterAvailableLoots(List<ScenarioLoot> loots) =>
      loots.where((loot) => isItemAlreadyUsed(loot.id));
}
