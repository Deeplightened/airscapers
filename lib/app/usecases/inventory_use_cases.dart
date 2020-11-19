import 'package:airscaper/common/entities/scenario_loot.dart';
import 'package:airscaper/app/views/home/bloc/inventory/inventory_bloc.dart';
import 'package:airscaper/app/views/home/bloc/inventory/inventory_events.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddLootUseCase {
  Future<AddLootResponse> execute(
      BuildContext context, Iterable<ScenarioLoot> loots) async {
    var existingElement = false;

    // ignore: close_sinks
    final inventoryBloc = BlocProvider.of<InventoryBloc>(context);
    final state = inventoryBloc.state;

    loots.forEach((loot) {
      if (state.isItemAlreadyInInventory(loot.id)) {
        existingElement = true;
      } else {
        inventoryBloc.add(AddItemInventoryEvent(loot.id));
      }
    });

    return (existingElement)
        ? AddLootResponse.ALREADY_FOUND
        : AddLootResponse.ADDED;
  }
}

enum AddLootResponse { ADDED, ALREADY_FOUND, ERROR }