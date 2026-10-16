import 'package:component_repository/component_repository.dart';
import 'package:flame_component_editor/component_editor/bloc/component_editor_bloc.dart';
import 'package:flame_component_editor/component_editor/widgets/property_editors/property_editors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template properties_panel}
/// Lists an editor for every property of the component being edited.
///
/// Editors are picked from the capabilities the component implements, so a
/// new component type gets them without changes here.
/// {@endtemplate}
class PropertiesPanel extends StatelessWidget {
  /// {@macro properties_panel}
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final component = context.select<ComponentEditorBloc, Component>(
      (bloc) => bloc.state.component,
    );
    final bloc = context.read<ComponentEditorBloc>();

    return ListView(
      children: [
        if (component case final SizedComponent sized)
          SizeEditor(
            value: sized.size,
            onChanged: (size) => bloc.add(ComponentEditorSizeChanged(size)),
          ),
        if (component case final PaintedComponent painted)
          PaintEditor(
            value: painted.paint,
            onChanged: (paint) => bloc.add(ComponentEditorPaintChanged(paint)),
          ),
      ],
    );
  }
}
