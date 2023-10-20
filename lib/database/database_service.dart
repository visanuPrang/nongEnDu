// initialize & create database

// ignore_for_file: depend_on_referenced_packages, recursive_getters

import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:nongendu/database/user_db.dart';

class DatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      // debugPrint('!=null database');
      return _database!;
    }
    // debugPrint('==null database');
    _database = await _initialize();
    // debugPrint('_database as String?');
    return _database!;
  }

  Future<String> get fullPath async {
    const name = 'userDB';
    // debugPrint('------name------ $name -----------');
    final path = await getDatabasesPath();
    // debugPrint('-----path------- $path -----------');
    final filePath = join(path, name);
    // debugPrint('-----join(path, name)------- $filePath -----------');
    if (await File(filePath).exists()) {
      // debugPrint('---------- $filePath exists -----------');
    } else {
      // debugPrint('---------- $filePath does not exists -----------');
    }
    return join(path, name);
  }

  Future<Database> _initialize() async {
    // debugPrint('1   _initialize');
    final path = await fullPath;
    // debugPrint('2   _initialize $path');
    var database = await openDatabase(
      path,
      version: 1,
      onCreate: create,
      singleInstance: true,
    );
    // debugPrint('3   _initialize');

    return database;
  }

  Future<void> create(Database database, int version) async {
    await UserDB().createTable(database);
    // debugPrint('createTable');
  }
}
