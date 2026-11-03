import "package:flutter/foundation.dart";
import "package:logger/logger.dart";

final loggger = Logger(filter: ProductionFilter());

void configureLogger() {
  Logger.level = kReleaseMode ? Level.warning : Level.debug;
}
