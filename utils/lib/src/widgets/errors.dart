import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lp_utils/l10n.dart';

Future<T> appErrorHandlers<T>(
    BuildContext context, FutureOr<T> Function() callback) async {
  try {
    return await callback();
  } catch (error) {
    final l10n = UtilLocalizations.of(context);
    final theme = Theme.of(context);
    final errorColor = theme.errorColor;
    final contentColor = theme.colorScheme.onError;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: errorColor,
        content: Row(
          children: [
            Icon(Icons.warning_rounded, color: contentColor),
            const SizedBox(width: 12),
            Expanded(
                child: Text(l10n.formatError(error),
                    style: TextStyle(color: contentColor)))
          ],
        )));
    rethrow;
  }
}
