import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:qr_scan/models/scan_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBProvider {
  static Database? _database;
  static final DBProvider db = DBProvider._();
  DBProvider._();

  Future<Database> get database async{
    _database ??= await initDB();
    return _database!;
  }

  Future<Database> initDB() async{
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, "Scans.db");

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db){},
      onCreate: (db, version) async{
        await db.execute('''
          create table Scans(
            id integer primary key,
            tipus text,
            valor text
          )
        ''');
      },
    );
  }

  Future<int> insertRawScan(ScanModel nouScan) async{
    final db = await database;
    return await db.rawInsert('''
      insert into Scans(id, tipus, valor)
        values (${nouScan.id}, ${nouScan.tipus}, ${nouScan.valor})
    ''');
  }

  Future<int> insertScan(ScanModel nouScan) async{
    final db = await database;
    return await db.insert('Scans', nouScan.toMap());
  }

  Future<List<ScanModel>> getAllScans() async{
    final db = await database;
    final result = await db.query("Scans");
    return result.isNotEmpty ? result.map((e) => ScanModel.fromMap(e)).toList() : [];
  }

  Future<ScanModel?> getScanById(int id) async{
    final db = await database;
    final result = await db.query("Scans", where: "id = ?", whereArgs: [id]);
    return result.isNotEmpty ? ScanModel.fromMap(result.first) : null;
  }

  Future<List<ScanModel>> getScansPerTipus(String type) async{
    final db = await database;
    final result = await db.query("Scans", where: "tipus = ?", whereArgs: [type]);
    return result.isNotEmpty ? result.map((e) => ScanModel.fromMap(e)).toList() : [];
  }

  Future<int> updateScan(ScanModel nouScan) async{
    final db = await database;
    final result = await db.update("Scans", nouScan.toMap(), where: "id = ?", whereArgs: [nouScan.id]);
    return result;
  }

  Future<int> deleteAllScans() async{
    final db = await database;
    final result = await db.rawDelete('''
      delete from Scans
    ''');
    return result;
  }

  Future<int> deleteScan(int id) async{
    final db = await database;
    final result = await db.delete("Scans", where: "id = ?", whereArgs: [id]);
    return result;
  }
}