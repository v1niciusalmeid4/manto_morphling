import 'package:flutter/material.dart';
import 'package:morphling/morphling.dart';

mixin HudMixin {
  final BuildContext? context = NavigatorService.key.currentContext;

  void _showSnackBar(String message, {required Color backgroundColor}) {
    if (context == null) {
      return;
    }

    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: backgroundColor,
      ),
    );
  }

  void showSuccess(String message) {
    _showSnackBar(message, backgroundColor: Colors.green);
  }

  void showFailure(String message) {
    _showSnackBar(message, backgroundColor: Colors.red);
  }

  void showWarning(String message) {
    _showSnackBar(message, backgroundColor: Colors.orange);
  }

  void showLoadingDialog({
    String? message,
    Widget? loadingWidget,
    bool canDismiss = false,
  }) {
    if (context == null) {
      return;
    }

    showDialog(
      context: context!,
      // ignore: deprecated_member_use
      builder:
          (context) => WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              child:
                  loadingWidget ??
                  Padding(
                    padding: const EdgeInsets.all(36.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator.adaptive(),
                        const SizedBox(height: 10.0),
                        message != null
                            ? Text(message)
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
            ),
          ),
      barrierDismissible: canDismiss,
    );
  }

  Future<T?>? showEspecialBottomSheet<T>(
    Widget bottomSheet, {
    bool isScrollControlled = false,
    bool useSafeArea = true,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    Color? barrierColor,
    bool enableDrag = true,
    bool isDismissible = true,
    RouteSettings? routeSettings,
  }) {
    if (context == null) {
      return null;
    }

    return showModalBottomSheet(
      context: context!,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.2,
                child: const Divider(),
              ),
              bottomSheet,
            ],
          ),
      isScrollControlled: isScrollControlled,
      useSafeArea: useSafeArea,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      barrierColor: barrierColor,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      routeSettings: routeSettings,
    );
  }

  Future<T?>? dialog<T>(
    Widget dialog, {
    bool barrierDismissible = true,
    Color? barrierColor,
    bool useSafeArea = true,
    RouteSettings? routeSettings,
  }) {
    if (context == null) {
      return null;
    }

    return showDialog(
      context: context!,
      builder: (context) => dialog,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      useSafeArea: useSafeArea,
      routeSettings: routeSettings,
    );
  }

  Future<bool?> requestConfirmation({
    String? title,
    String? message,
    String? cancelMessage,
    String? confirmMessage,
    bool canDismiss = true,
  }) async {
    return await dialog<bool>(
      AlertDialog(
        title: Text(title ?? 'Atenção'),
        content: Text(message ?? 'Deseja realizar essa ação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context!).pop(false),
            child: Text(cancelMessage ?? 'Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context!).pop(true),
            child: Text(confirmMessage ?? 'Confirmar'),
          ),
        ],
      ),
      barrierDismissible: canDismiss,
    );
  }

  Future<T?>? requestSelection<T>({
    required List<T> items,
    required String Function(T) label,
    String? title,
    String? cancelMessage,
    bool canDismiss = true,
  }) async {
    return dialog<T>(
      AlertDialog(
        title: Text(title ?? 'Selecione'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              items
                  .map(
                    (item) => ListTile(
                      title: Text(label(item)),
                      onTap: () => Navigator.of(context!).pop(item),
                    ),
                  )
                  .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context!).pop(),
            child: Text(cancelMessage ?? 'Cancelar'),
          ),
        ],
      ),
      barrierDismissible: canDismiss,
    );
  }
}
