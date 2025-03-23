import '../models/medical_report.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();

  factory CacheService() {
    return _instance;
  }

  CacheService._internal();

  final _reportCache = _LRUCache<String, MedicalReport>(maxSize: 100);
  final _patientReportsCache =
      _LRUCache<String, List<MedicalReport>>(maxSize: 50);

  MedicalReport? getReport(String id) {
    return _reportCache.get(id);
  }

  void cacheReport(MedicalReport report) {
    _reportCache.put(report.id, report);
  }

  List<MedicalReport>? getPatientReports(String patientId) {
    return _patientReportsCache.get(patientId);
  }

  void cachePatientReports(String patientId, List<MedicalReport> reports) {
    _patientReportsCache.put(patientId, reports);
  }

  void clearCache() {
    _reportCache.clear();
    _patientReportsCache.clear();
  }

  void invalidateReport(String id) {
    _reportCache.remove(id);
  }

  void invalidatePatientReports(String patientId) {
    _patientReportsCache.remove(patientId);
  }
}

class _LRUCache<K, V> {
  _LRUCache({required this.maxSize});

  final int maxSize;
  final _cache = <K, V>{};

  V? get(K key) {
    final value = _cache[key];
    if (value != null) {
      // Move to end (most recently used)
      _cache.remove(key);
      _cache[key] = value;
    }
    return value;
  }

  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    } else if (_cache.length >= maxSize) {
      // Remove least recently used item (first item)
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }

  void remove(K key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }
}
