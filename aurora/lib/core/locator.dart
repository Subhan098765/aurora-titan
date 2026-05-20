import 'package:get_it/get_it.dart';
import 'package:aurora/services/websocket_service.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<WebSocketService>(() => WebSocketService());
}
