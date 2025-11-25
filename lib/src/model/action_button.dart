import 'package:flutter/cupertino.dart';
import '../features/chat/data/models/service_model.dart';

class ActionButton {
  final Widget widget;
  final String? label;
  final IconData? icon;
  // handler that receives the Service so callers always get the service data
  final void Function(ProductItemModel service) onTap;

  ActionButton({required this.widget, this.label, this.icon, required this.onTap});
}
