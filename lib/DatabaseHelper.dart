// ignore_for_file: prefer_conditional_assignment
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_mpesa_sms/MpesaSMSModel.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:sqflite/sqflite.dart';

class DatabaseHelper {


  String mpesaTransActionTable = 'MpesaTransAction';

  String colID = 'ID';
  String colTransID = 'TransID';
  String colMpesaAmount = 'MpesaAmount';
  String colMpesaPhoneNumber = 'MpesaPhoneNumber';
  String colMpesaUserName = 'MpesaUserName';
  String colMpesaTransDate = 'MpesaTransDate';
  String colAddedBy = 'AddedBy';
  String colStatusID = 'StatusID';
  String colDateTime = 'DateTime';






  static Database? _database;  // Singleton Database
  static DatabaseHelper? _databaseHelper; // Singleton DatabaseHelper
  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper!;
  }

  Future<Database?> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = p.join(directory.path, 'smsDB.db');

    // Open/create the database at a given path
    var notesDatabase =
    await openDatabase(path, version:  1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $mpesaTransActionTable($colID INTEGER PRIMARY KEY AUTOINCREMENT, '
            '$colTransID NVARCHAR(50),$colMpesaAmount NVARCHAR(50),$colMpesaPhoneNumber NVARCHAR(50),$colMpesaUserName NVARCHAR(50),$colMpesaTransDate NVARCHAR(50), $colAddedBy INTEGER, '
            '$colStatusID INTEGER ,$colDateTime NVARCHAR(20)  )');



  }

  Future<int?> insertMpesaMessage(MpesaSMSModel cart) async {
    Database? db = await database;
    var result = await db?.insert(mpesaTransActionTable, cart.toMap());
    return result;
  }

  Future<List<Map<String, dynamic>>?> getTransActionMapList() async {
    Database? db = await database;
//		var result = await db.rawQuery('SELECT * FROM $mpesaTransActionTable order by $colID ASC');
    var result = await db?.query(mpesaTransActionTable,

        orderBy: '$colID DESC');
    return result;
  }





  Future<int?> updateIsSentMpesa(transID) async {
    var db = await database;
    var result = await db?.rawUpdate(
        'UPDATE  $mpesaTransActionTable SET $colStatusID=1  WHERE TransID=$transID');
    return result;
  }




  Future deleteSentMpesa(statusID) async {
    var dbClient = await database;
    await dbClient?.transaction((txn) async {
      await txn.execute("DELETE FROM $mpesaTransActionTable WHERE StatusID=$statusID'" );
    });
  }






}