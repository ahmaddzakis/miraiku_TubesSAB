import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/game_manager.dart';

// Helper class untuk mengelola riwayat aktivitas
class ActivityHistoryManager {
  static const String _key = 'user_activities';

  // 1. Simpan aktivitas baru
  static Future<void> addActivity(String title, String description) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> activities = prefs.getStringList(_key) ?? [];

    final newActivity = {
      'title': title,
      'description': description,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Masukkan di urutan paling atas (terbaru)
    activities.insert(0, jsonEncode(newActivity));

    // Opsional: Batasi maksimal 100 aktivitas agar memori lokal tidak membengkak
    if (activities.length > 100) {
      activities = activities.sublist(0, 100);
    }

    await prefs.setStringList(_key, activities);
    await prefs.setBool('has_new_activity', true);
  }

  // 2. Ambil semua aktivitas
  static Future<List<Map<String, String>>> getActivities() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> activities = prefs.getStringList(_key) ?? [];

    return activities.map((String item) {
      final Map<String, dynamic> decoded = jsonDecode(item);
      return {
        'title': decoded['title']?.toString() ?? '',
        'description': decoded['description']?.toString() ?? '',
        'timestamp': decoded['timestamp']?.toString() ?? '',
      };
    }).toList();
  }

  // (Opsional) Hapus riwayat
  static Future<void> clearActivities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  late Future<List<Map<String, String>>> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    _activitiesFuture = ActivityHistoryManager.getActivities();
  }

  String _formatTime(String isoString) {
    if (isoString.isEmpty) return '';
    final dt = DateTime.tryParse(isoString);
    if (dt == null) return '';
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF9F6F0);
        final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final Color textColor = isDark ? Colors.white : const Color(0xFF333333);
        final Color subTextColor = isDark ? Colors.white70 : const Color(0xFF8C8A87);
        final Color borderColor = isDark ? const Color(0xFF333333) : Colors.transparent;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: const Text("Riwayat Aktivitas"),
            centerTitle: true,
            backgroundColor: bgColor,
            elevation: 0,
            iconTheme: IconThemeData(color: textColor),
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: textColor,
              fontFamily: 'Serif'
            ),
            actions: [
              IconButton( // Tombol hapus riwayat
                icon: Icon(Icons.delete_sweep_rounded, color: isDark ? Colors.white54 : Colors.grey),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      title: Text("Hapus Semua?", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                      content: Text("Apakah Anda yakin ingin menghapus semua riwayat aktivitas?", style: TextStyle(color: subTextColor)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                          onPressed: () async {
                            await ActivityHistoryManager.clearActivities();
                            if (context.mounted) Navigator.pop(context);
                            setState(() {
                              _activitiesFuture = ActivityHistoryManager.getActivities();
                            });
                          },
                          child: const Text("Ya, Hapus", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  );
                },
              )
            ],
          ),
          body: FutureBuilder<List<Map<String, String>>>(
            future: _activitiesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFCC6633)));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_rounded, size: 80, color: isDark ? Colors.white12 : Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text("Belum ada aktivitas", style: TextStyle(color: subTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }

              final activities = snapshot.data!;
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final act = activities[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                      boxShadow: isDark ? [] : [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCC6633).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.history_rounded, color: Color(0xFFCC6633), size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      act['title'] ?? '',
                                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: textColor),
                                    ),
                                  ),
                                  Text(
                                    _formatTime(act['timestamp'] ?? ''),
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB5B0A8)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                act['description'] ?? '',
                                style: TextStyle(fontSize: 13, height: 1.4, color: subTextColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
