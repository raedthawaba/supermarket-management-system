import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String name,
    required UserRole role,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(true) bool isActive,
    String? phone,
    String? avatar,
    @Default([]) List<String> permissions,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

enum UserRole {
  @JsonValue('admin')
  admin,
  @JsonValue('manager')
  manager,
  @JsonValue('cashier')
  cashier,
  @JsonValue('inventory_manager')
  inventoryManager,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'مدير عام';
      case UserRole.manager:
        return 'مدير';
      case UserRole.cashier:
        return 'كاشير';
      case UserRole.inventoryManager:
        return 'مدير المخزون';
    }
  }

  bool get canManageInventory {
    return this == UserRole.admin || this == UserRole.inventoryManager;
  }

  bool get canViewReports {
    return this == UserRole.admin || this == UserRole.manager;
  }

  bool get canProcessSales {
    return this != UserRole.admin; // Admin can't process sales directly
  }
}