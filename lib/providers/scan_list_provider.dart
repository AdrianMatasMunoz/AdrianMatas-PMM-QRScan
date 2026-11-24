import 'package:flutter/foundation.dart';
import 'package:qr_scan/models/scan_model.dart';
import 'package:qr_scan/providers/db_provider.dart';

class ScanListProvider extends ChangeNotifier {
  List<ScanModel> scans = [];
  String tipusSeleccionat = "http";

  Future<ScanModel> nouScan(String valor) async{
    final nouScan = ScanModel(valor: valor);
    final id = await DBProvider.db.insertScan(nouScan);
    nouScan.id = id;

    if(nouScan.tipus == tipusSeleccionat) {
      scans.add(nouScan);
      notifyListeners();
    }

    return nouScan;
  }

  Future<void> carregaScans() async {
    final scans = await DBProvider.db.getAllScans();
    this.scans = [...scans];
    notifyListeners();
  }

  Future<void> carregaScansPerTipus(String tipus) async{
    final scans = await DBProvider.db.getScansPerTipus(tipus);
    this.scans = [...scans];
    notifyListeners();
  }

  Future<void> esborraTots() async{
    await DBProvider.db.deleteAllScans();
    scans.clear();
  }

  Future<void> esborraPerId(int id) async {
    ScanModel? scan;
    try {
      scan = scans.firstWhere((element) => element.id == id);
    } on StateError catch (_) {
      scan = null;
    }
    scans.remove(scan);
    await DBProvider.db.deleteScan(id);
  }
}