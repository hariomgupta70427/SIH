import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ScanHistoryItem {
  final String qrData;
  final DateTime scanTime;
  final String? partName;

  ScanHistoryItem({
    required this.qrData,
    required this.scanTime,
    this.partName,
  });

  Map<String, dynamic> toJson() {
    return {
      'qrData': qrData,
      'scanTime': scanTime.millisecondsSinceEpoch,
      'partName': partName,
    };
  }

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    return ScanHistoryItem(
      qrData: json['qrData'],
      scanTime: DateTime.fromMillisecondsSinceEpoch(json['scanTime']),
      partName: json['partName'],
    );
  }

  String get formattedTime {
    return DateFormat('dd/MM/yyyy HH:mm').format(scanTime);
  }
}

class ScanHistoryService {
  static const String _key = 'scan_history';

  static Future<List<ScanHistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_key) ?? [];
    
    return historyJson.map((item) {
      final Map<String, dynamic> json = jsonDecode(item);
      return ScanHistoryItem.fromJson(json);
    }).toList().reversed.toList();
  }

  static Future<void> addScan(ScanHistoryItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    
    // Add new item at the beginning
    history.insert(0, item);
    
    // Keep only last 100 scans
    if (history.length > 100) {
      history.removeRange(100, history.length);
    }
    
    final historyJson = history.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_key, historyJson);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<int> getHistoryCount() async {
    final history = await getHistory();
    return history.length;
  }
}