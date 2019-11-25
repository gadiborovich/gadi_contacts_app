import 'dart:async';

import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase _singleton = AppDatabase._();

  static AppDatabase get instance => _singleton;
  // _singletonCompleter is used for transforming synchronous code into asynchronous code.
  Completer<Database> _dbOpenCompleter;

  AppDatabase._();

  Future<Database> get database async {
    if (_dbOpenCompleter == null) {
      _dbOpenCompleter = Completer();
      // Calling _openDatabase will also complete the completer with database instance
      _openDataBase();
    }
    return _dbOpenCompleter.future;
  }

  Future _openDataBase() async {
    // The data of the database will be persisted to a file, so we first need to obtain a valid,
    // platform-specific path to the file.
    final appDocumentDir = await getApplicationDocumentsDirectory();
    // Path with the form: /platform-specific-directory/contacts.db
    final dbPath = join(appDocumentDir.path, 'contacts.db');
    // A database needs to be "opened" to allow for reads and writes
    final database = await databaseFactoryIo.openDatabase(dbPath);
    _dbOpenCompleter.complete(database);
  }
}
