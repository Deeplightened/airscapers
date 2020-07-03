import 'package:airscaper/usecases/init_use_cases.dart';
import 'package:airscaper/views/code/code_screen.dart';
import 'package:airscaper/views/home/end_screen.dart';
import 'package:airscaper/views/home/home_screen.dart';
import 'package:airscaper/views/home/scan_screen.dart';
import 'package:airscaper/views/init/scenario_choose_screen.dart';
import 'package:airscaper/views/init/scenario_start_screen.dart';
import 'package:airscaper/views/mechanism/mechanism_screen.dart';
import 'package:catcher/core/catcher.dart';
import 'package:catcher/handlers/console_handler.dart';
import 'package:catcher/mode/dialog_report_mode.dart';
import 'package:catcher/model/catcher_options.dart';
import 'package:flutter/material.dart';

import 'injection.dart';

Future<void> main() async {
  await init();

  final initAppUseCase = sl<InitAppUseCase>();
  final initResponse = await initAppUseCase.execute();

  var initialRoute;
  if (initResponse is NoScenarioResponse) {
    initialRoute = ChooseScenarioScreen.routeName;
  } else if (initResponse is HasScenarioResponse) {
    initialRoute = HomeScreen.routeName;
  }

  CatcherOptions debugOptions =
      CatcherOptions(DialogReportMode(), [ConsoleHandler()]);

  Catcher(MainApp(initialRoute: initialRoute), debugConfig: debugOptions);
}

class MainApp extends StatelessWidget {
  final String initialRoute;

  const MainApp({Key key, this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: Catcher.navigatorKey,
      title: 'Airscapers',
      theme: ThemeData(primaryColor: Colors.white, accentColor: Colors.black),
      debugShowCheckedModeBanner: false,
      routes: {
        // init
        ChooseScenarioScreen.routeName: (context) => ChooseScenarioScreen(),
        ScenarioStartScreen.routeName: (context) => ScenarioStartScreen(),

        // Home
        HomeScreen.routeName: (context) => HomeScreen(),
        ScanFragment.routeName: (context) => ScanFragment(),
        GameOverScreen.routeName: (context) => GameOverScreen()
      },
      initialRoute: initialRoute,
    );
  }
}
