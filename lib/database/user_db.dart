// ignore_for_file: unused_local_variable

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nongendu/model/user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:nongendu/database/database_service.dart';

class UserDB {
  final tableName = 'userDB';

  Future<void> createTable(Database database) async {
    // debugPrint(
    //     '<------------------create table if not exists------------------>');
    await database.execute('''create table if not exists $tableName(
      "id" integer not null,
      "user_type" text not null,
      "user_id" text not null,
      "e_mail" text not null,
      "name" text not null,
      "password" text not null,
      "created_at" integer not null default (cast(strftime('%s','now') as int))
    );''');
    // --- primary key ("id" autoincrement)
  }

  Future<int> create(
      {required int id,
      required String userType,
      required String userId,
      required String eMail,
      required String name,
      required String password}) async {
    final database = await DatabaseService().database;
    // debugPrint(
    //     '===========================create ==> $tableName============================');
    return await database.rawInsert(
      '''insert into $tableName (id,user_type,user_id,e_mail,name,password,created_at) values (?,?,?,?,?,?,?)''',
      [
        id,
        userType,
        userId,
        eMail,
        name,
        password,
        DateTime.now().millisecondsSinceEpoch
      ],
    );
  }

  Future<List<User>> fetchAll() async {
    final database = await DatabaseService().database;
    final users = await database
        .rawQuery('''select * from $tableName order by coalesce(created_at)''');
    return users.map((user) => User.fromSqfliteDatabase(user)).toList();
  }

  Future<Map> fetchById(String utype, String uid) async {
    var retStr = 'not found';
    const name = 'userDB';
    final database = await DatabaseService().database;
    final path = await getDatabasesPath();
    final filePath = join(path, name);
    if (!await File(filePath).exists()) {
      debugPrint('dose not exists... create...');
      createTable(database);
    }
    // debugPrint('2===utype id==>$utype=$uid====');
    final user = await database.rawQuery(
        '''select * from $tableName where id=?''',
        [0]); //user_type=? and user_id=?''',
    //  [utype, uid]);

    // debugPrint('1=====user.length==> ${user.length} ==========');
    // ignore: unnecessary_null_comparison
    if (user.isEmpty) {
      debugPrint('1========== no data ==========');
      await create(
          id: 0,
          userType: 'not found',
          userId: 'userEmail',
          eMail: 'profile.eMail',
          name: 'parents01',
          password: 'passworD');
      final user = await database
          .rawQuery('''select * from $tableName where id=?''', [0]);
      // debugPrint('1========== ${user.first['user_type']} ==========');
      return user.first;
    } else {
      // debugPrint('2========== ${user.first['name']} ==========');
      // debugPrint(
      // 'xxxxx id= ${user[0]['id']} type= ${user[0]['user_type']} name= ${user[0]['name']} xxxxx');
      retStr =
          '${user.first}|${user[0]['id']}|${user[0]['user_type']}|${user[0]['user_id']}|${user[0]['e_mail']}|${user[0]['name']}|${user[0]['password']}';
      // debugPrint(retStr);
      return user.first;
    }
  }

  Future<String> fetchData(String utype, String uid) async {
    var retStr = 'not found';
    final database = await DatabaseService().database;
    final user =
        await database.rawQuery('''select * from $tableName where id=?''', [0]);
    retStr =
        '${user.first}|${user[0]['id']}|${user[0]['user_type']}|${user[0]['user_id']}|${user[0]['e_mail']}|${user[0]['name']}|${user[0]['password']}';
    // debugPrint(retStr);
    return retStr;
  }

  Future<int> update(
      {required int id,
      String? userType,
      String? userId,
      String? eMail,
      String? name,
      String? password}) async {
    final database = await DatabaseService().database;
    late int recUpdate = 0;
    // debugPrint('--------update------------');
    recUpdate = await database.update(
      tableName,
      {
        'id': id,
        if (userType != null) 'user_type': userType,
        if (userId != null) 'user_id': userId,
        if (eMail != null) 'e_mail': eMail,
        if (name != null) 'name': name,
        if (password != null) 'password': password,
        'created_at': DateTime.now().microsecondsSinceEpoch,
      },
      where: 'id = ?',
      conflictAlgorithm: ConflictAlgorithm.rollback,
      whereArgs: [id],
    );
    // debugPrint('recUpdate ==> $recUpdate');
    return recUpdate;
  }

  Future<void> delete(int id) async {
    final database = await DatabaseService().database;
    // debugPrint('deleted data from $tableName where id=$id');
    await database.rawDelete('''delete from $tableName where id = ?''', [id]);
  }
}
