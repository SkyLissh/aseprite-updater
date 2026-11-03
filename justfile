default:
  @just --list

run:
  fvm flutter run
  
build:
  fvm flutter build linux
  
generate:
  fvm dart run build_runner build --delete-conflicting-outputs
  
generate-watch:
  fvm dart run build_runner watch --delete-conflicting-outputs
