import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    required String id,
    required String userId,
    required TransactionType type,
    required double amount,
    required List<TransactionItem> items,
    required DateTime createdAt,
    required PaymentMethod paymentMethod,
    String? customerName,
    String? customerPhone,
    @Default('') String notes,
    @Default('') String reference,
    @Default('pending') TransactionStatus status,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return TransactionModel.fromJson(data);
  }
}

@freezed
class TransactionItem with _$TransactionItem {
  const factory TransactionItem({
    required String productId,
    required String productName,
    required double price,
    required int quantity,
    @Default(0.0) double discount,
  }) = _TransactionItem;

  factory TransactionItem.fromJson(Map<String, dynamic> json) =>
      _$TransactionItemFromJson(json);
}

enum TransactionType {
  @JsonValue('sale')
  sale,
  @JsonValue('purchase')
  purchase,
  @JsonValue('return')
  returnTransaction,
  @JsonValue('adjustment')
  adjustment,
}

enum PaymentMethod {
  @JsonValue('cash')
  cash,
  @JsonValue('card')
  card,
  @JsonValue('mobile_payment')
  mobilePayment,
  @JsonValue('credit')
  credit,
}

enum TransactionStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('refunded')
  refunded,
}

extension TransactionModelExtension on TransactionModel {
  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get totalDiscount {
    return items.fold(0.0, (sum, item) => sum + item.discount);
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  bool get isCompleted {
    return status == TransactionStatus.completed;
  }

  bool get canBeRefunded {
    return status == TransactionStatus.completed && 
           type == TransactionType.sale;
  }

  String get displayStatus {
    switch (status) {
      case TransactionStatus.pending:
        return 'في الانتظار';
      case TransactionStatus.completed:
        return 'مكتمل';
      case TransactionStatus.cancelled:
        return 'ملغي';
      case TransactionStatus.refunded:
        return 'مسترد';
    }
  }
}