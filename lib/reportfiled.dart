import 'package:flutter/material.dart';

class ReportFiled extends StatelessWidget
{
  final String message;

  const ReportFiled(
      {required this.message, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context)
  {      
    return AlertDialog(
      title: const Text('Что-то пошло не так'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      );
  }
}

void OutputMessage(BuildContext context, String message)
{
  showDialog(
      context: context,
      builder: (context) {
        return ReportFiled(message: message);
      },
    );
}