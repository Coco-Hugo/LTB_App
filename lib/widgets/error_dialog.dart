import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onOkPressed;

  const ErrorDialog({
    super.key,
    required this.errorMessage,
    this.onOkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('An Error Occurred'),
      content: Text(errorMessage),
      actions: [
        TextButton(
          child: Text('OK'),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
            if (onOkPressed != null) {
              onOkPressed!();
            }
          },
        ),
      ],
    );
  }
}

void showErrorDialog(BuildContext context, String errorMessage,
    {VoidCallback? onOkPressed}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ErrorDialog(
        errorMessage: errorMessage,
        onOkPressed: onOkPressed,
      );
    },
  );
}
