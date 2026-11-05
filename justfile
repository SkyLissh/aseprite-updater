default:
  @just --list

run:
  fvm flutter run
  
build:
  fvm flutter build linux
  
generate:
  fvm dart run build_runner build
  
generate-watch:
  fvm dart run build_runner watch
  
test:
  fvm flutter test

analyze:
  fvm flutter analyze
  
format:
  fvm dart format lib test

format-check:
  fvm dart format --output=none --set-exit-if-changed lib test
  
l10n:
  fvm flutter gen-l10n

check: format-check analyze test
