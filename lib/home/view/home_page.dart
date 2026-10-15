import 'package:flame_component_editor/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template home_page}
/// The screen shown when no project is open.
/// {@endtemplate}
class HomePage extends StatelessWidget {
  /// {@macro home_page}
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HomeBloc(projectRepository: context.read())
            ..add(const HomeRecentProjectsRequested()),
      child: const HomeView(),
    );
  }
}
