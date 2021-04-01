import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/data.dart';
import '../library/library.dart';
import '../model/model.dart';
import '../style.dart';
import '../widgets/widgets.dart';

class LogBookBrowserPage extends StatefulWidget {
  @override
  _LogBookBrowserPageState createState() => _LogBookBrowserPageState();
}

class _LogBookBrowserPageState extends State<LogBookBrowserPage> {
  late final AppModel _model;
  late final Stream<List<LogBookSummary>> _logBooks;

  @override
  void initState() {
    super.initState();
    _model = context.read();
    _logBooks = _model.watchAllLogBooks();
  }

  @override
  Widget build(BuildContext context) => Shortcuts(
        shortcuts: logBookBrowserShortcuts(),
        child: Focus(
          autofocus: true,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Log books'),
              actions: [
                IconButton(
                  icon: Icon(Icons.add),
                  tooltip: 'New log book',
                  onPressed: _newLogBook,
                ),
                AppBarMenu(
                  onSelected: (value) {
                    if (value == 'deleteAllLogBooks') {
                      Actions.invoke(context, DeleteAllLogBooksIntent());
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'deleteAllLogBooks',
                      child: Text('Delete all log books'),
                    )
                  ],
                ),
              ],
            ),
            body: StreamBuilder<List<LogBookSummary>>(
              stream: _logBooks,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return _buildLoadedContent(snapshot.data!);
                }

                if (snapshot.hasError) {
                  return _buildErrorContent(snapshot);
                }

                return _buildLoadingContent();
              },
            ),
          ),
        ),
      );

  Widget _buildLoadingContent() => Center(
        child: CircularProgressIndicator(),
      );

  Widget _buildErrorContent(AsyncSnapshot<List<LogBookSummary>> snapshot) =>
      Container(
        padding: EdgeInsets.all(AppStyle.spacing),
        alignment: Alignment.center,
        child: Text(snapshot.error.toString()),
      );

  Widget _buildLoadedContent(List<LogBookSummary> data) {
    if (data.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppStyle.spacing),
          child: Text('There are no log books'),
        ),
      );
    }

    return Scrollbar(
      child: ListView.separated(
        restorationId: 'logBookList',
        itemBuilder: (_, index) => _LogBookListTile(logBook: data[index]),
        separatorBuilder: (_, __) => Divider(height: 0),
        itemCount: data.length,
      ),
    );
  }

  void _newLogBook() => Actions.invoke(context, NewLogBookIntent());
}

class _LogBookListTile extends StatelessWidget {
  const _LogBookListTile({
    Key? key,
    required this.logBook,
  }) : super(key: key);

  final LogBookSummary logBook;

  @override
  Widget build(BuildContext context) {
    final model = context.read<AppModel>();
    return Shortcuts(
      shortcuts: logBookBrowserListTileShortcuts(logBookId: logBook.id),
      child: ListTile(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                logBook.title,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              constraints: BoxConstraints(
                minWidth: 28,
                minHeight: 28,
              ),
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: ShapeDecoration(
                shape: StadiumBorder(),
                color: Colors.red,
              ),
              alignment: Alignment.center,
              child: Text(
                logBook.entryCount.toString(),
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
        subtitle: logBook.lastEntryCreatedAt?.let((it) => RelativeDateBuilder(
              date: it,
              builder: (_, time) => Text('Last entry: $time'),
            )),
        onTap: () => model.openLogBook(logBook.id),
      ),
    );
  }
}
