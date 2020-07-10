import 'dart:async';

import 'package:airscaper/model/entities/scenario_item.dart';
import 'package:airscaper/model/inventory_local_source.dart';
import 'package:airscaper/repositories/scenario_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../injection.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final ScenarioRepository _repository = sl();
  final InventoryLocalSource _localSource = sl();

  @override
  InventoryState get initialState => InventoryState(loading: true);

  @override
  Stream<InventoryState> mapEventToState(InventoryEvent event) async* {
    try {
      // Init item
      if (event is InitInventoryEvent) {
        final items = await _localSource.loadUnusedItems();
        final scenarioItems = _repository.getItems(items);
        yield InventoryState(items: scenarioItems);

        // Remove item
      } else if (event is RemoveItemInventoryEvent) {
        await _localSource.updateItemUsed(event.itemId);

        var newItems = state.items ?? [];
        newItems.removeWhere((it) => it.id == event.itemId);
        yield state.clone(items: newItems);

        // Add item
      } else if (event is AddItemInventoryEvent) {
        final id = await _localSource.insertItem(event.itemId);
        final scenarioItem = _repository.getItem(id);

        final newItems = (state.items ?? []) + [scenarioItem];
        yield state.clone(items: newItems);

        // Select item
      } else if (event is SelectItemInventoryEvent) {
        if(state.selectedItem == event.itemId) {
          // -1 instead of null to make clone works (null values are replaced
          // by current state value)
          yield state.clone(selectedItem: -1);
        } else {
          yield state.clone(selectedItem: event.itemId);
        }

        // Clear inventory
      } else if (event is ClearInventoryEvent) {
        await _localSource.clear();
        yield InventoryState(items: []);

      } else {
        throw Exception("Event not handled : $event");
      }
    } catch (exception, stack) {
      debugPrintStack(stackTrace: stack, label: exception.toString());
    }
  }
}

/// EVENT
abstract class InventoryEvent {}

class InitInventoryEvent extends InventoryEvent {}

class AddItemInventoryEvent extends InventoryEvent {
  final int itemId;

  AddItemInventoryEvent(this.itemId);
}

class RemoveItemInventoryEvent extends InventoryEvent {
  final int itemId;

  RemoveItemInventoryEvent(this.itemId);
}

class SelectItemInventoryEvent extends InventoryEvent {
  final int itemId;

  SelectItemInventoryEvent(this.itemId);
}

class ClearInventoryEvent extends InventoryEvent {}

/// STATE
class InventoryState {
  final List<ScenarioItem> items;
  final bool loading;
  final int selectedItem;

  InventoryState(
      {this.items, this.loading = false, this.selectedItem});

  InventoryState clone(
          {List<ScenarioItem> items, bool loading, int selectedItem}) =>
      InventoryState(
          items: items ?? this.items,
          loading: loading ?? this.loading,
          selectedItem: selectedItem ?? this.selectedItem
      );
}