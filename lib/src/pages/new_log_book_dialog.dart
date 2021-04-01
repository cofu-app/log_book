import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../library/library.dart';
import '../model/model.dart';

class NewLogBookDialog extends StatefulWidget {
  @override
  _NewLogBookDialogState createState() => _NewLogBookDialogState();
}

class _NewLogBookDialogState extends State<NewLogBookDialog> {
  late AppModel _appModel;
  final _titleController = TextEditingController();
  final _form = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _appModel = context.read();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
        key: _form,
        child: SimpleDialog(
          title: Text('New log book'),
          children: [
            SimpleDialogOption(
              child: TextFormField(
                controller: _titleController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
                maxLength: 250,
                validator: requiredString(),
              ),
            ),
            SimpleDialogOption(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _createLogBook,
                    child: Text('Create'),
                  )
                ],
              ),
            )
          ],
        ),
      );

  void _createLogBook() async {
    if (_form.currentState!.validate()) {
      _appModel.createLogBook(title: _titleController.text);
    }
  }
}
