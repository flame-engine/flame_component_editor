import 'package:component_repository/component_repository.dart';
import 'package:flame_component_editor/component_editor/widgets/property_editors/enum_field.dart';
import 'package:flame_component_editor/component_editor/widgets/property_editors/property_section.dart';
import 'package:flutter/material.dart';

/// {@template collision_editor}
/// Edits a [ComponentCollision]: the collision type and whether the hitbox
/// is solid.
/// {@endtemplate}
class CollisionEditor extends StatelessWidget {
  /// {@macro collision_editor}
  const new({required this.value, required this.onChanged, super.key});

  /// The collision being edited.
  final ComponentCollision value;

  /// Called with the updated collision.
  final ValueChanged<ComponentCollision> onChanged;

  @override
  Widget build(BuildContext context) {
    return PropertySection(
      title: 'Collision',
      children: [
        EnumField<HitboxCollisionType>(
          label: 'Type',
          values: HitboxCollisionType.values,
          value: value.type,
          labelOf: (type) => type.label,
          onChanged: (type) => onChanged(value.copyWith(type: type)),
        ),
        SwitchListTile(
          title: const Text('Solid'),
          subtitle: const Text('Also collides with hitboxes inside it'),
          contentPadding: EdgeInsets.zero,
          dense: true,
          value: value.isSolid,
          onChanged: (isSolid) => onChanged(value.copyWith(isSolid: isSolid)),
        ),
      ],
    );
  }
}
