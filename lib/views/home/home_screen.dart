import 'package:airscaper/common/ars_result.dart';
import 'package:airscaper/model/entities/scenario_item.dart';
import 'package:airscaper/usecases/init_use_cases.dart';
import 'package:airscaper/usecases/link_use_cases.dart';
import 'package:airscaper/views/common/ars_clock.dart';
import 'package:airscaper/views/common/ars_grid.dart';
import 'package:airscaper/views/home/bloc/inventory_bloc.dart';
import 'package:airscaper/views/home/bloc/timer_bloc.dart';
import 'package:airscaper/views/home/end_screen.dart';
import 'package:airscaper/views/home/main_scan_fragment.dart';
import 'package:airscaper/views/home/scan_screen.dart';
import 'package:airscaper/views/inventory/inventory_details_screen.dart';
import 'package:airscaper/views/mechanism/mechanism_screen.dart';
import 'package:airscaper/views/navigation/navigation_methods.dart';
import 'package:barcode_scan/platform_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:progress_indicators/progress_indicators.dart';

import '../../injection.dart';

final homeRouteBuilders = {
  MainScanFragment.routeName: (BuildContext context) => MainScanFragment(),
  ScanFragment.routeName: (BuildContext context) => ScanFragment(),
  InventoryDetailsFragment.routeName: (BuildContext context) => InventoryDetailsFragment(),
  MechanismFragment.routeName: (BuildContext context) => MechanismFragment()
};

class HomeScreen extends StatelessWidget {
  static const routeName = "/home";

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => TimerBloc()),
        BlocProvider(create: (context) => InventoryBloc()),
      ],
      child: HomeScreenLoader(),
    );
  }
}

class HomeScreenLoader extends StatelessWidget {

  final StartScenarioUseCase _startScenarioUseCase = sl();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ARSResult<bool>>(
        future: _startScenarioUseCase.execute(context),
        initialData: ARSResult.loading(),
        builder: (context, snapshot) {
          if(snapshot.error != null) {
            return createErrorView(snapshot.error);
          }
          final result = snapshot.data;
          if (result.errorCode != null) {
            return createErrorView(result.errorCode);
          } else if (result.loading) {
            return loadingView;
          }

          return Scaffold(
              backgroundColor: Colors.black,
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: HomeScreenContent(),
              ));
        });
  }

  Widget createErrorView(String errorCode) => Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: Text(
            errorCode,
            style: TextStyle(fontSize: 20),
          )));

  Widget get loadingView => Container(
    color: Colors.white,
    child: Center(
      child: JumpingDotsProgressIndicator(
          numberOfDots: 4, fontSize: 40.0, dotSpacing: 2.0),
    ),
  );
}

/// Visual content of the home page
class HomeScreenContent extends StatelessWidget {

  final EndScenarioUseCase _endScenarioUseCase = sl();
  final ParseLinkUseCase _parseLinkUseCase = sl();
  final InterpretLinkUseCase _interpretLinkUseCase = sl();

  final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        // CLock
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
              height: 80,
              child: ARSClock(
                onEnd: doGameOverScreen,
              )),
        ),

        // Main view
        Expanded(child: _createHomeNavigation(context)),

        // Inventory
        createInventory(context)

      ],
    );
  }

  Widget createInventory(BuildContext context) {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, snapshot) {
        final List<ScenarioItem> items = snapshot.items ?? [];
        return ARSGrid(items: items);
      },
    );
  }

  Widget _createHomeNavigation(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _homeNavigatorKey.currentState.maybePop();
        return false;
      },
      child: Navigator(
          key: _homeNavigatorKey,
          initialRoute: MainScanFragment.routeName,
          onGenerateRoute: (RouteSettings settings) => MaterialPageRoute(
              settings: settings, builder: homeRouteBuilders[settings.name])),
    );
  }

  doGameOverScreen(BuildContext context) async {
    await _endScenarioUseCase.execute();

    Future.delayed(
        Duration.zero,
        () => Navigator.of(context)
            .pushReplacementNamed(GameOverScreen.routeName));
  }

  onScanDebugClicked(BuildContext context) {
    if (kDebugMode) {
      Navigator.of(context).pushNamed(ScanFragment.routeName);
    }
  }

  onStartBarcodeScanner(BuildContext context) async {
    var result = await BarcodeScanner.scan();
    var cameraScanResult = result.rawContent;

    final link = _parseLinkUseCase.execute(cameraScanResult);
    if (link != null) {
      final intent = await _interpretLinkUseCase.execute(context, link);
      navigateTo(context, intent);
    } else {
      navigateShowDialog(
          context,
          DialogArguments(
              "Code invalide", "Ce code n'existe pas dans l'application"));
    }
  }
}
