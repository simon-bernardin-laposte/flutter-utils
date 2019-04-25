import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n.dart';

Future<T?> showAppDialog<T>(
    {required BuildContext context,
    Widget? title,
    Widget? content,
    List<Widget>? children,
    required List<Widget> actions,
    Color closeColor = Colors.black54,
    bool closeButton = false}) {
  assert((content != null) != (children != null));
  content ??= children != null
      ? SingleChildScrollView(
          child: ListBody(
            children: children,
          ),
        )
      : null;
  if (closeButton) {
    title = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(child: title ?? const SizedBox()),
          if (closeButton) ...[
            const SizedBox(width: 16),
            SizedOverflowBox(
                size: const Size.square(24),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.close, color: closeColor),
                  onPressed: () => Navigator.pop(context),
                ))
          ]
        ]);
  }
  return showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) =>
          AlertDialog(title: title, content: content, actions: actions));
}

Future showErrorDialog(BuildContext context, Object error) {
  final l10n = UtilLocalizations.of(context);
  return showDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
              title: Text(l10n.formatDialogTitleError(error)),
              content: Text(l10n.formatError(error)),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: Text(l10n.formatDialogBtnLabelError(error)),
                )
              ]));
}

Future<T> standardErrorHandler<T>(
    BuildContext context, FutureOr<T> Function() callback) async {
  try {
    return await callback();
  } catch (error) {
    await showErrorDialog(context, error);
    rethrow;
  }
}
