import 'package:airscaper/model/entities/scenario_item.dart';
import 'package:airscaper/model/entities/scenario_loot.dart';
import 'package:airscaper/usecases/link_use_cases.dart';
import 'package:airscaper/views/common/ars_button.dart';
import 'package:airscaper/views/common/ars_dialog_base.dart';
import 'package:airscaper/views/home/bloc/inventory/inventory_state.dart';
import 'package:airscaper/views/items/interactions/continue_button.dart';
import 'package:flutter/material.dart';

import '../../../injection.dart';

class ItemSearchButton extends StatefulWidget {
  final InventoryState inventoryState;
  final ScenarioItem item;
  final Function(BuildContext, int) onResolved;

  InterpretLinkUseCase get _interpretLinkUseCase => sl();

  const ItemSearchButton(this.inventoryState, this.item, this.onResolved,
      {Key key})
      : super(key: key);

  @override
  _ItemSearchButtonState createState() => _ItemSearchButtonState();
}

class _ItemSearchButtonState extends State<ItemSearchButton> {
  List<ScenarioLoot> _availableLoots;

  @override
  void initState() {
    super.initState();
    _availableLoots = widget.item.loots;
    _refreshLoots();
  }

  @override
  Widget build(BuildContext context) {
    if (_availableLoots.isNotEmpty) {
      return _getSearchButton(context);

    } else if (widget.item.transition != null) {
      return ItemContinueButton(widget.item, widget.onResolved);

    } else {
      return Container();
    }
  }

  Widget _getSearchButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ARSButton(
        onClick: (context) => _onSearchClicked(context),
        text: Text(
          "Fouiller",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  _onSearchClicked(BuildContext context) {
    if (widget.item.loots.length > 1) {
      showDialog(
          context: context,
          barrierDismissible: true,
          barrierColor: Colors.black45,
          child: SearchContent(
            loots: _availableLoots,
            onLootClicked: (loot) {
              Navigator.of(context, rootNavigator: true).pop();
              _onLootClicked(loot);
            },
          ));
    } else {
      // If only one loot, directly go to this one
      _onLootClicked(_availableLoots.first);
    }
  }

  _onLootClicked(ScenarioLoot loot) async {
    final intent = await widget._interpretLinkUseCase.execute(context, loot.id);

    await Navigator.of(context)
        .pushNamed(intent.screenName, arguments: intent.arguments);

    _refreshLoots(exitOnEmpty: true);
  }

  _refreshLoots({bool exitOnEmpty = false}) async {
    final newLoots =
        widget.inventoryState.filterAvailableLoots(_availableLoots);

    if (exitOnEmpty && newLoots.isEmpty) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _availableLoots = newLoots;
      });
    }
  }
}

class SearchContent extends StatelessWidget {
  final List<ScenarioLoot> loots;
  final Function(ScenarioLoot) onLootClicked;

  const SearchContent({Key key, this.loots, this.onLootClicked})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ARSDialogBase(
        child: Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: loots
              .where((it) => it.interactionText != null)
              .map((loot) => _createLootButton(loot))
              .toList()),
    ));
  }

  Widget _createLootButton(ScenarioLoot loot) => Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: ARSButton(
            onClick: (context) => onLootClicked(loot),
            text: Text(
              loot.interactionText,
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green),
      );
}