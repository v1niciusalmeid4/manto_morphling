import 'package:flutter/services.dart';

class CnpjInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final oldDigits = _digitsOnly(oldValue.text);
    final newDigits = _digitsOnly(newValue.text);
    final isDeleting = newValue.text.length < oldValue.text.length;
    final deletedOnlySeparator =
        isDeleting && newDigits.length == oldDigits.length;

    String effectiveDigits = newDigits;
    int targetDigitsBeforeCursor = _countDigitsBeforeCursor(
      newValue.text,
      newValue.selection.baseOffset,
    );

    if (deletedOnlySeparator && oldDigits.isNotEmpty) {
      final digitsBeforeOldCursor = _countDigitsBeforeCursor(
        oldValue.text,
        oldValue.selection.baseOffset,
      );

      if (digitsBeforeOldCursor > 0) {
        final removeAt = digitsBeforeOldCursor - 1;
        final buffer = StringBuffer();
        for (var i = 0; i < oldDigits.length; i++) {
          if (i != removeAt) buffer.write(oldDigits[i]);
        }
        effectiveDigits = buffer.toString();
        targetDigitsBeforeCursor = digitsBeforeOldCursor - 1;
      }
    }

    final truncated =
        effectiveDigits.length > 14
            ? effectiveDigits.substring(0, 14)
            : effectiveDigits;
    final formatted = _formatCnpj(truncated);

    if (targetDigitsBeforeCursor > truncated.length) {
      targetDigitsBeforeCursor = truncated.length;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: _offsetForDigitPosition(formatted, targetDigitsBeforeCursor),
      ),
    );
  }

  String _digitsOnly(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  String _formatCnpj(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      if (i == 1 || i == 4) buffer.write('.');
      if (i == 7) buffer.write('/');
      if (i == 11) buffer.write('-');
    }
    return buffer.toString();
  }

  int _countDigitsBeforeCursor(String text, int cursorOffset) {
    final safeOffset = cursorOffset.clamp(0, text.length);
    var count = 0;

    for (var i = 0; i < safeOffset; i++) {
      final char = text[i];
      if (RegExp(r'\d').hasMatch(char)) count++;
    }

    return count;
  }

  int _offsetForDigitPosition(String formatted, int digitPosition) {
    if (digitPosition <= 0) return 0;

    var digits = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (RegExp(r'\d').hasMatch(formatted[i])) {
        digits++;
      }
      if (digits == digitPosition) {
        return i + 1;
      }
    }

    return formatted.length;
  }
}
