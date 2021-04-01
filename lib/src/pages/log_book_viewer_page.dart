import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/data.dart';
import '../library/library.dart';
import '../model/model.dart';
import '../style.dart';
import '../widgets/widgets.dart';

class LogBookViewerPage extends StatefulWidget {
  @override
  _LogBookViewerPageState createState() => _LogBookViewerPageState();
}

class _LogBookViewerPageState extends State<LogBookViewerPage> {
  late final LogBookViewerModel _model;
  final _entryForm = GlobalKey<_LogEntryFormState>();

  @override
  void initState() {
    super.initState();
    _model = context.read<AppModel>().logBookViewer!;
    _model.onEntrySaved = () => _entryForm.currentState!.reset();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.watch<AppModel>();
  }

  @override
  void dispose() {
    _model.onEntrySaved = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loadLogBook = _model.loadLogBookTask;

    Widget title;
    Widget content = Container();
    switch (loadLogBook.status) {
      case TaskStatus.idle:
      case TaskStatus.waiting:
        title = CircularProgressIndicator();
        break;
      case TaskStatus.done:
        title = Text(loadLogBook.result!.title);
        break;
      case TaskStatus.error:
        title = Icon(Icons.error);
        content = _buildErrorBody(loadLogBook);
        break;
      case TaskStatus.active:
      case TaskStatus.canceled:
        throw 'Should not happen';
    }

    final watchLogEntries = _model.watchLogEntiresTask;
    switch (watchLogEntries.status) {
      case TaskStatus.idle:
      case TaskStatus.waiting:
        content = Center(child: CircularProgressIndicator());
        break;
      case TaskStatus.done:
      case TaskStatus.active:
        content = _buildEntriesList();
        break;
      case TaskStatus.error:
        content = _buildErrorBody(watchLogEntries);
        break;
      case TaskStatus.canceled:
        throw 'Should not happen';
    }

    return Scaffold(
      appBar: AppBar(
        title: title,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _LogEntrySearchDelegate(_model),
              );
            },
          ),
          AppBarMenu(
            onSelected: (value) {
              if (value == 'deleteLogBook') {
                Actions.invoke(
                  context,
                  DeleteLogBookIntent(_model.logBookId),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'deleteLogBook',
                child: Text('Delete'),
              )
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(child: content),
          _LogEntryForm(
            key: _entryForm,
            logEntry: _model.currentlyEditedEntry,
            onSubmit: (entryText) => _model.saveEntry(text: entryText),
            onCancel: _model.cancelEditEntry,
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesList() {
    final entries = _model.watchLogEntiresTask.result!.reversed.toList();

    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('This log book is empty'),
        ),
      );
    }

    return ListView.separated(
      restorationId: 'logEntriesList',
      reverse: true,
      padding: EdgeInsets.zero,
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _LogEntryListItem(
          key: ValueKey(entry.id),
          logEntry: entry,
          isEditing: entry.id == _model.currentlyEditedEntry?.id,
          onEdit: () => _model.editEntry(entry.id!),
          onDelete: () => _model.deleteEntry(entry.id!),
        );
      },
      separatorBuilder: (context, index) => Divider(height: 0),
    );
  }

  Widget _buildErrorBody(Task task) => Container(
        padding: EdgeInsets.all(AppStyle.spacing),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(task.error!.toString()),
            SizedBox(height: AppStyle.vSpacingHalf),
            TextButton(
              onPressed: _model.load,
              child: Text('Retry'),
            )
          ],
        ),
      );
}

class _LogEntryForm extends StatefulWidget {
  const _LogEntryForm({
    Key? key,
    required this.logEntry,
    required this.onSubmit,
    required this.onCancel,
  }) : super(key: key);

  final LogEntry? logEntry;

  final ValueChanged<String> onSubmit;

  final VoidCallback onCancel;

  @override
  _LogEntryFormState createState() => _LogEntryFormState();
}

class _LogEntryFormState extends State<_LogEntryForm> {
  final _entryForm = GlobalKey<FormState>();
  final _newEntryTextController = TextEditingController();
  final _entryTextController = TextEditingController();
  bool get _isNewEntry => widget.logEntry == null;
  TextEditingController get _effectiveTextController =>
      _isNewEntry ? _newEntryTextController : _entryTextController;

  void reset() {
    _entryForm.currentState!.reset();
  }

  void setEntryText(String text) {
    _entryTextController.text = text;
  }

  @override
  void didUpdateWidget(covariant _LogEntryForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.logEntry != oldWidget.logEntry) {
      _entryTextController.text = widget.logEntry?.text ?? '';
    }
  }

  @override
  void dispose() {
    _newEntryTextController.dispose();
    _entryTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Material(
        elevation: 16,
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(AppStyle.spacing),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text input
                Form(
                  key: _entryForm,
                  child: Expanded(
                    child: Actions(
                      actions: {
                        SubmitLogEntryForm: CallbackAction(
                          onInvoke: (_) => _submitEntryInput(),
                        )
                      },
                      child: Shortcuts(
                        shortcuts: logEntryFormShortcuts(),
                        child: TextFormField(
                          controller: _effectiveTextController,
                          minLines: 4,
                          maxLines: 4,
                          validator: requiredString(),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppStyle.hSpacing),
                // Buttons
                SizedBox(
                  width: 80,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: _submitEntryInput,
                        child: Text(_isNewEntry ? 'Create' : 'Save'),
                      ),
                      SizedBox(height: AppStyle.vSpacing),
                      if (!_isNewEntry)
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: widget.onCancel,
                          child: Text('Cancel'),
                        )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );

  void _submitEntryInput() {
    if (_entryForm.currentState!.validate()) {
      widget.onSubmit(_effectiveTextController.text);
    }
  }
}

class _LogEntryListItem extends StatelessWidget {
  const _LogEntryListItem({
    Key? key,
    required this.logEntry,
    this.isEditing = false,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  final LogEntry logEntry;
  final bool isEditing;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => Material(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 38,
              padding:
                  const EdgeInsets.symmetric(horizontal: AppStyle.hSpacingHalf),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppStyle.hSpacingHalf,
                    ),
                    child: RelativeDateBuilder(
                      date: logEntry.createdAt!,
                      builder: (context, time) => Text(
                        time,
                        style: Theme.of(context)
                            .textTheme
                            .caption!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Spacer(),
                  if (logEntry.updatedAt != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppStyle.hSpacingHalf,
                      ),
                      child: Text(
                        'edited',
                        style: Theme.of(context).textTheme.caption!,
                      ),
                    ),
                  if (isEditing)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppStyle.hSpacingHalf,
                      ),
                      child: Icon(
                        Icons.circle,
                        size: 10,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<Symbol>(
                      onSelected: (value) {
                        if (value == #edit) {
                          onEdit!();
                        } else if (value == #delete) {
                          onDelete!();
                        }
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          PopupMenuItem(
                            value: #edit,
                            child: Text('Edit'),
                          ),
                        if (onDelete != null)
                          PopupMenuItem(
                            value: #delete,
                            child: Text('Delete'),
                          )
                      ],
                    ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppStyle.hSpacing) +
                      EdgeInsets.only(bottom: AppStyle.vSpacing),
              child: Text(logEntry.text),
            ),
          ],
        ),
      );
}

class _LogEntrySearchDelegate extends SearchDelegate<LogEntry?> {
  _LogEntrySearchDelegate(this._model);

  final LogBookViewerModel _model;

  @override
  List<Widget> buildActions(BuildContext context) => [];

  @override
  Widget buildLeading(BuildContext context) => BackButton(
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _LogEntriesSearchResults(
        model: _model,
        query: query,
      );

  @override
  Widget buildSuggestions(BuildContext context) => _LogEntriesSearchResults(
        model: _model,
        query: query,
      );
}

class _LogEntriesSearchResults extends StatefulWidget {
  const _LogEntriesSearchResults({
    Key? key,
    required this.model,
    required this.query,
  }) : super(key: key);

  final String query;

  final LogBookViewerModel model;

  @override
  _LogEntriesSearchResultsState createState() =>
      _LogEntriesSearchResultsState();
}

class _LogEntriesSearchResultsState extends State<_LogEntriesSearchResults> {
  bool get queryIsEmpty => widget.query.isBlank;

  @override
  void initState() {
    super.initState();
    widget.model.searchLogEntiresTask.addListener(_onSearchTaskChange);
  }

  @override
  void didUpdateWidget(covariant _LogEntriesSearchResults oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(widget.model == oldWidget.model);

    if (oldWidget.query != widget.query) {
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        widget.model.setSearchEntriesQuery(widget.query);
      });
    }
  }

  @override
  void dispose() {
    widget.model.searchLogEntiresTask.removeListener(_onSearchTaskChange);
    super.dispose();
  }

  void _onSearchTaskChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (queryIsEmpty) {
      return Container();
    }

    final searchTask = widget.model.searchLogEntiresTask;
    final searchResults = widget.model.lastEntriesSearchResults;
    if (searchResults == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.separated(
      itemBuilder: (context, index) {
        final entry = searchResults[index];
        return _LogEntryListItem(
          logEntry: entry,
        );
      },
      separatorBuilder: (context, index) => Divider(height: 0),
      itemCount: searchTask.result!.length,
    );
  }
}
