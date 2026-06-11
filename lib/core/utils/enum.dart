import 'package:collection/collection.dart';

// USER ROLES
enum UserRole {
  admin(1, 'Admin'),
  facilitator(2, 'Facilitator'),
  report(3, 'Report'),
  caretaker(4, 'Caretaker');

  final int id;
  final String label;

  const UserRole(this.id, this.label);

  static UserRole? fromId(int id) {
    return UserRole.values.firstWhereOrNull((e) => e.id == id);
  }
}

