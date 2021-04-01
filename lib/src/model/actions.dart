import 'package:flutter/widgets.dart';

import 'app_model.dart';

class PopPageIntent extends Intent {}

class PopPageAction extends ContextAction<PopPageIntent> {
  @override
  Object? invoke(covariant PopPageIntent intent, [BuildContext? context]) {
    Navigator.of(context!).pop();
  }
}

class NewLogBookIntent extends Intent {}

class NewLogBookAction extends Action<NewLogBookIntent> {
  NewLogBookAction(this._appModel);

  final AppModel _appModel;

  @override
  Object? invoke(covariant NewLogBookIntent intent) {
    _appModel.openNewLogBookDialog();
  }
}

class DeleteLogBookIntent extends Intent {
  DeleteLogBookIntent(this.id);

  final String id;
}

class DeleteLogBookAction extends Action<DeleteLogBookIntent> {
  DeleteLogBookAction(this._appModel);

  final AppModel _appModel;

  @override
  Object? invoke(covariant DeleteLogBookIntent intent) {
    _appModel.deleteLogBook(intent.id);
  }
}

class DeleteAllLogBooksIntent extends Intent {}

class DeleteAllLogBooksAction extends Action<DeleteAllLogBooksIntent> {
  DeleteAllLogBooksAction(this._appModel);

  final AppModel _appModel;

  @override
  Object? invoke(covariant DeleteAllLogBooksIntent intent) {
    _appModel.deleteAllLogBooks();
  }
}

class SubmitLogEntryForm extends Intent {}

Map<Type, Action> globalActions(AppModel appModel) => {
      PopPageIntent: PopPageAction(),
      NewLogBookIntent: NewLogBookAction(appModel),
      DeleteLogBookIntent: DeleteLogBookAction(appModel),
      DeleteAllLogBooksIntent: DeleteAllLogBooksAction(appModel),
    };
