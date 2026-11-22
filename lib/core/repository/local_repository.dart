import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocalRepository {
  static const String _pendingActionsKey = 'pending_sync_actions';
  static bool _isSyncing = false;
  static bool _hasPendingWhileSyncing = false;
  static int _retryCount = 0;
  static const int _maxRetries = 3;
  static DateTime? _nextAllowedRetry;
  static StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// When `true` (e.g. during ephemeral Developer Quick Login sessions),
  /// progress changes are kept in local cache only and never pushed to Supabase.
  static bool Function()? isCloudSyncDisabled;

  /// Indicates whether a cloud metadata update is currently in flight,
  /// allowing auth listeners to avoid redundant re-sync loops.
  static bool get isSyncing => _isSyncing;

  // --- 1. FALLBACK PATTERN: FETCH DATA ---
  static Future<Map<String, dynamic>> getUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    if (isCloudSyncDisabled?.call() == true) {
      return _getLocalCachedMetadata(prefs);
    }

    final SupabaseClient supabase;
    try {
      supabase = Supabase.instance.client;
    } catch (_) {
      return _getLocalCachedMetadata(prefs);
    }

    final user = supabase.auth.currentUser;

    if (user == null) return _getLocalCachedMetadata(prefs);

    try {
      // Attempt Supabase fetch only if a valid session exists
      if (supabase.auth.currentSession == null) {
        return _getLocalCachedMetadata(prefs);
      }
      final response = await supabase.auth.getUser();
      final meta = response.user?.userMetadata ?? {};

      // Update local cache on success
      await _cacheUserMetadata(meta);
      return meta;
    } catch (e) {
      debugPrint("Offline mode: Fetching from local cache.");
      // Fallback to local cache
      return _getLocalCachedMetadata(prefs);
    }
  }

  // --- 2. OFFLINE SYNC QUEUE: SAVE SINGLE OR BATCH ACTIONS ---
  static Future<void> queueAction(
    String key,
    dynamic value, {
    bool triggerSync = true,
  }) async {
    await queueActionsBatch({key: value}, triggerSync: triggerSync);
  }

  /// Enqueues multiple key-value pairs atomically into local cache and the
  /// persistent sync queue, then triggers a single non-throwing cloud sync.
  static Future<void> queueActionsBatch(
    Map<String, dynamic> actions, {
    bool triggerSync = true,
  }) async {
    if (actions.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    if (isCloudSyncDisabled?.call() == true) {
      for (final entry in actions.entries) {
        await _saveSingleCacheValue(prefs, entry.key, entry.value);
      }
      return;
    }

    final List<String> pending = prefs.getStringList(_pendingActionsKey) ?? [];

    // Parse existing pending items into a map keyed by action key (deduplicated)
    final Map<String, Map<String, dynamic>> pendingMap = {};
    for (final itemStr in pending) {
      try {
        final decoded = jsonDecode(itemStr) as Map<String, dynamic>;
        final k = decoded['key'] as String?;
        if (k != null) {
          pendingMap[k] = decoded;
        }
      } catch (_) {}
    }

    final String nowIso = DateTime.now().toIso8601String();

    for (final entry in actions.entries) {
      final String key = entry.key;
      final dynamic value = entry.value;

      // Save to local immediate cache for 0ms UI responsiveness
      await _saveSingleCacheValue(prefs, key, value);

      pendingMap[key] = {
        'key': key,
        'value': value,
        'timestamp': nowIso,
      };
    }

    final List<String> updatedPending =
        pendingMap.values.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList(_pendingActionsKey, updatedPending);

    if (triggerSync) {
      // Non-blocking sync; errors are handled internally without unhandled async exceptions
      unawaited(syncPendingActions());
    }
  }

  // --- 3. CONNECTIVITY SYNC LISTENER ---
  static void startSyncListener() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.any((r) => r != ConnectivityResult.none)) {
        debugPrint("Internet restored. Triggering sync...");
        // Reset backoff when network connectivity is explicitly restored
        _nextAllowedRetry = null;
        unawaited(syncPendingActions());
      }
    });
  }

  /// Synchronizes all queued offline actions to Supabase Auth user metadata.
  ///
  /// Returns `true` if the queue is empty or synced successfully, `false` if
  /// throttled, offline, or an error occurred. Never throws an unhandled
  /// exception on background/fire-and-forget invocations.
  static Future<bool> syncPendingActions({bool ignoreBackoff = false}) async {
    if (isCloudSyncDisabled?.call() == true) {
      return false;
    }
    if (_isSyncing) {
      _hasPendingWhileSyncing = true;
      return false;
    }

    // Guard: Prevent rapid retries and respect exponential backoff
    if (!ignoreBackoff &&
        _nextAllowedRetry != null &&
        DateTime.now().isBefore(_nextAllowedRetry!)) {
      debugPrint("Sync throttled: Backoff active until $_nextAllowedRetry");
      return false;
    }

    final SupabaseClient supabase;
    try {
      supabase = Supabase.instance.client;
    } catch (_) {
      return false;
    }

    final session = supabase.auth.currentSession;
    final user = supabase.auth.currentUser;
    if (user == null || session == null || session.isExpired) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final List<String> pending = prefs.getStringList(_pendingActionsKey) ?? [];
    if (pending.isEmpty) return true;

    _isSyncing = true;
    try {
      // Aggregate all pending changes into a single batch update to avoid rate limits
      final Map<String, dynamic> updateData = {};
      for (final actionStr in pending) {
        try {
          final action = jsonDecode(actionStr) as Map<String, dynamic>;
          final key = action['key'] as String?;
          if (key != null) {
            updateData[key] = action['value'];
          }
        } catch (_) {}
      }

      if (updateData.isEmpty) {
        await prefs.remove(_pendingActionsKey);
        return true;
      }

      await supabase.auth.updateUser(UserAttributes(data: updateData));

      // Remove only the keys that were included in this batch snapshot
      final List<String> currentPending =
          prefs.getStringList(_pendingActionsKey) ?? [];
      currentPending.removeWhere((itemStr) {
        try {
          final decoded = jsonDecode(itemStr) as Map<String, dynamic>;
          final k = decoded['key'] as String?;
          return k != null && updateData.containsKey(k);
        } catch (_) {
          return true;
        }
      });

      if (currentPending.isEmpty) {
        await prefs.remove(_pendingActionsKey);
      } else {
        await prefs.setStringList(_pendingActionsKey, currentPending);
      }

      _retryCount = 0;
      _nextAllowedRetry = null;
      debugPrint("Sync successful: ${updateData.keys.length} actions pushed.");
      return true;
    } catch (e) {
      _retryCount++;
      debugPrint("Sync failed (Attempt $_retryCount/$_maxRetries): $e");

      if (_retryCount >= _maxRetries) {
        // Exponential/cooldown backoff: 2 minutes delay after max retries
        _nextAllowedRetry = DateTime.now().add(const Duration(minutes: 2));
        _retryCount = 0;
        debugPrint("Max sync retries reached. Backing off for 2 minutes.");
      }
      return false;
    } finally {
      _isSyncing = false;
      if (_hasPendingWhileSyncing) {
        _hasPendingWhileSyncing = false;
        // If new actions arrived while a sync was in progress and we did not fail,
        // schedule a follow-up sync for the remaining items.
        if (_retryCount == 0 && _nextAllowedRetry == null) {
          unawaited(syncPendingActions());
        }
      }
    }
  }

  /// Strictly await all pending actions being pushed to the cloud (e.g., before logout).
  static Future<void> flushQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> pending = prefs.getStringList(_pendingActionsKey) ?? [];
    if (pending.isEmpty) return;

    debugPrint("Flushing ${pending.length} pending actions...");
    await syncPendingActions(ignoreBackoff: true);
  }

  static Future<void> _saveSingleCacheValue(
    SharedPreferences prefs,
    String key,
    dynamic value,
  ) async {
    final cacheKey = 'cache_$key';
    if (value == null) {
      await prefs.remove(cacheKey);
    } else if (value is int) {
      await prefs.setInt(cacheKey, value);
    } else if (value is double) {
      await prefs.setDouble(cacheKey, value);
    } else if (value is String) {
      await prefs.setString(cacheKey, value);
    } else if (value is bool) {
      await prefs.setBool(cacheKey, value);
    } else if (value is List<String>) {
      await prefs.setStringList(cacheKey, value);
    } else if (value is List) {
      await prefs.setString(cacheKey, jsonEncode(value));
    }
  }

  /// Writes metadata key-value pairs into local `cache_*` keys without queueing
  /// a cloud sync request (useful when hydrating or persisting offline dev state).
  static Future<void> cacheMetadata(Map<String, dynamic> meta) =>
      _cacheUserMetadata(meta);

  // Helper: Cache metadata to SharedPreferences
  static Future<void> _cacheUserMetadata(Map<String, dynamic> meta) async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in meta.entries) {
      await _saveSingleCacheValue(prefs, entry.key, entry.value);
    }
  }

  // Helper: Get cached metadata
  static Map<String, dynamic> _getLocalCachedMetadata(SharedPreferences prefs) {
    final Map<String, dynamic> cache = {};
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('cache_')) {
        final String cleanKey = key.replaceFirst('cache_', '');
        final Object? rawVal = prefs.get(key);
        if (cleanKey == 'simulation_history' && rawVal is String) {
          try {
            cache[cleanKey] = jsonDecode(rawVal);
          } catch (_) {
            cache[cleanKey] = [];
          }
        } else {
          cache[cleanKey] = rawVal;
        }
      }
    }
    return cache;
  }
}
