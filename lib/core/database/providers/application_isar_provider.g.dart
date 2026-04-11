// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_isar_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$applicationIsarHash() => r'219f6d915c10afdda114bed338b59edc11f82be3';

/// Single long-lived Isar instance for the app.
///
/// Copied from [applicationIsar].
@ProviderFor(applicationIsar)
final applicationIsarProvider = FutureProvider<Isar>.internal(
  applicationIsar,
  name: r'applicationIsarProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$applicationIsarHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ApplicationIsarRef = FutureProviderRef<Isar>;
String _$databaseRepositoriesHash() =>
    r'60f918128f30124023b0f640b48dbc2c7742c64c';

/// Repositories built on top of [applicationIsarProvider].
///
/// Copied from [databaseRepositories].
@ProviderFor(databaseRepositories)
final databaseRepositoriesProvider =
    FutureProvider<DatabaseRepositories>.internal(
  databaseRepositories,
  name: r'databaseRepositoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$databaseRepositoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DatabaseRepositoriesRef = FutureProviderRef<DatabaseRepositories>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
