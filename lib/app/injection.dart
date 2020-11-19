import 'package:airscaper/app/domain/managers/timer_manager.dart';
import 'package:airscaper/app/domain/sharedprefs/scenario_shared_prefs.dart';
import 'package:airscaper/app/domain/scenario_repository.dart';
import 'package:airscaper/app/usecases/end_use_cases.dart';
import 'package:airscaper/app/usecases/init_use_cases.dart';
import 'package:airscaper/app/usecases/inventory_use_cases.dart';
import 'package:airscaper/app/usecases/link_use_cases.dart';
import 'package:get_it/get_it.dart';


final sl = GetIt.instance;

Future<void> init() async {

  // region Use Cases
  sl.registerLazySingleton<InitAppUseCase>(() => InitAppUseCase(sl()));
  sl.registerLazySingleton<InitScenarioIndexUseCase>(() => InitScenarioIndexUseCase(sl()));
  sl.registerLazySingleton<RegisterScenarioUseCase>(() => RegisterScenarioUseCase(sl()));
  sl.registerLazySingleton<InitStartDateUseCase>(() => InitStartDateUseCase(sl()));
  sl.registerLazySingleton<StartScenarioUseCase>(() => StartScenarioUseCase(sl(), sl()));
  sl.registerLazySingleton<LoadAllScenariosUseCase>(() => LoadAllScenariosUseCase(sl()));

  sl.registerLazySingleton<EndScenarioUseCase>(() => EndScenarioUseCase(sl(), sl()));
  sl.registerLazySingleton<ComputeCompletionUseCase>(() => ComputeCompletionUseCase(sl()));
  sl.registerLazySingleton<TimeUsedUseCase>(() => TimeUsedUseCase(sl()));

  sl.registerLazySingleton<AddLootUseCase>(() => AddLootUseCase());
  sl.registerLazySingleton<InterpretLinkUseCase>(() => InterpretLinkUseCase(sl(), sl(), sl()));
  sl.registerLazySingleton<ParseLinkUseCase>(() => ParseLinkUseCase());

  // endregion

  // region Repositories
  sl.registerLazySingleton<ScenarioRepository>(() => ScenarioRepository());
  // endregion

  // region Managers
  sl.registerLazySingleton<TimerManager>(() => TimerManager());
  // endregion

  // region Storage
  sl.registerLazySingleton<ScenarioSharedPrefs>(() => ScenarioSharedPrefs());
  // endregion
}