import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_repository/project_repository.dart';

class _MockProjectRepository extends Mock implements ProjectRepository;

extension PumpApp on WidgetTester {
  /// Pumps [widget] wrapped in the app-level dependencies (theme, providers).
  ///
  /// Add repository/bloc providers here as they are introduced so that every
  /// widget test gets the same environment.
  Future<void> pumpApp(Widget widget, {ProjectRepository? projectRepository}) {
    return pumpWidget(
      RepositoryProvider.value(
        value: projectRepository ?? _MockProjectRepository(),
        child: MaterialApp(home: widget),
      ),
    );
  }
}
