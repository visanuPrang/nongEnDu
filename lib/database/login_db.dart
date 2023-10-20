// database function tools

//todo_db.dart -> login_db.dart
//todo.dart -> user_login.dart

import 'package:nongendu/models/user_login.dart';
import 'package:sqflite/sqflite.dart';
import 'package:nongendu/database/database_service.dart';
// import 'package:';

class UserLoginDB {
  final tableName = 'userLogin.db';

  Future<void> createTable(Database database) async {
    await database.execute("""create table if not exists $tableName(
      "id" integer not null,
      "name" text not null,
      "password" text not null,
      "login_at" integer not null default (cast(strftime('%s','now') as int)),
      primary key ("id" autoincrement)
    );""");
  }

  Future<int> create({required String name, required String password}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
      '''insert into $tableName (name,password,login_at) values (?,?,?)''',
      [name, password, DateTime.now().millisecondsSinceEpoch],
    );
  }

  Future<List<UserLogin>> fetchAll() async {
    final database = await DatabaseService().database;
    final logins = await database.rawQuery(
        '''select * from $tableName order by coalesce(updated_at,created_at)''');
    return logins.map((todo) => UserLogin.fromSqfliteDatabase(todo)).toList();
  }

  Future<UserLogin> fetchById(int id) async {
    final database = await DatabaseService().database;
    final parents = await database
        .rawQuery('''select * from $tableName where id=?''', [id]);
    return UserLogin.fromSqfliteDatabase(parents.first);
  }

  Future<int> update({required int id, String? name, String? password}) async {
    final database = await DatabaseService().database;
    return await database.update(
      tableName,
      {
        if (name != null) 'name': name,
        if (password != null) 'password': password,
        'login_at': DateTime.now().microsecondsSinceEpoch,
      },
      where: 'id = ?',
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async {
    final database = await DatabaseService().database;
    await database.rawDelete('''delete from $tableName where id = ?''', [id]);
  }
}
