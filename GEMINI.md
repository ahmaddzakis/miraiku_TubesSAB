# MIRAIku — Project Context & Engineering Guidelines

## 1. Gambaran Umum Proyek
- **Nama Aplikasi:** MIRAIku (未来く)
- **Domain:** Aplikasi mobile pembelajaran bahasa Jepang mandiri untuk tingkat pemula (**JLPT N5**), mencakup Hiragana, Katakana, Kanji Dasar, Kosakata, Tata Bahasa Dasar, dan Simulasi Ujian JLPT N5.
- **Konteks Akademis:** Objek penelitian Tugas Akhir mengenai penerapan **Octalysis Gamification Framework (Yu-kai Chou)** untuk meningkatkan motivasi belajar bahasa Jepang mandiri. Setiap fitur dan keputusan UI/UX harus dapat dipertanggungjawabkan secara teoritis berdasarkan 8 Core Drives Octalysis.
- **Tech Stack:** Flutter (Dart SDK `^3.11.5`), Material 3, Supabase (Auth, Database/Profiles, Storage), `SharedPreferences` (offline cache & sync queue), `audioplayers`, `flutter_local_notifications`, `home_widget`, `signature`.
- **Target Platform:** Android & Windows (serta kompatibel iOS/Web dengan platform guard yang tepat).

---

## 2. Arsitektur & Hasil Audit Baseline

### A. Struktur Direktori Target
```text
lib/
├── main.dart                         # Entry point, app bootstrap, MaterialApp
├── core/
│   ├── config/                       # Environment & Supabase configuration
│   ├── theme/                        # Centralized Design System (Material 3)
│   │   ├── app_colors.dart           # Semantic color tokens (Light & Dark, WCAG AA)
│   │   ├── app_text_styles.dart      # Typography scale (Nunito + NotoSansJP)
│   │   ├── app_spacing.dart          # Spacing, radius, and layout constants
│   │   └── app_theme.dart            # ThemeData (lightTheme & darkTheme)
│   ├── widgets/                      # Reusable UI components
│   │   ├── app_dialogs.dart
│   │   ├── app_snackbar.dart
│   │   └── ...                       # Buttons, cards, progress bars, badges
│   ├── repository/
│   │   └── local_repository.dart     # Offline-first cache & cloud sync queue
│   ├── game_manager.dart             # Core gamification state & business logic
│   ├── settings_controller.dart      # Theme & localization controller
│   ├── sound_manager.dart            # Audio feedback service
│   ├── notification_service.dart     # Local study reminder scheduler
│   └── widget_service.dart           # Android/iOS home screen streak widget
├── data/                             # Static N5 learning content (decoupled from UI)
│   ├── alphabet_data.dart            # Hiragana, Katakana, N5 Kanji datasets
│   ├── quiz_repository.dart          # Unit 1-4 tiered exercises & unit tests
│   └── simulation_data.dart          # JLPT N5 mock exam questions & explanations
├── widgets/                          # Shared feature widgets (TopStatusBar, PathNode, BottomNav)
└── features/                         # Feature modules (UI + Controllers)
    ├── common/                       # Greeting overlay (Mochi mascot)
    ├── kana/                         # Alphabet grid & stroke drawing canvas
    ├── learn/                        # Learning path (Units 1-4) & quiz exercise engine
    ├── leaderboard/                  # Global XP & streak rankings
    ├── login/                        # Welcome onboarding & Supabase/Google Auth
    ├── profile/                      # User profile, achievements, settings, notifications
    ├── simulation/                   # JLPT N5 mock exam, result, review, history
    └── tracker/                      # JLPT N5 readiness gauge & breakdown
```

### B. State Management & Offline-First Architecture
- **Reactive State:** Menggunakan `ValueNotifier<T>` dan `ListenableBuilder` / `ValueListenableBuilder` yang terpusat dan bebas duplikasi key.
- **Offline-First Sync Pattern (`LocalRepository` + Supabase):**
  1. Setiap aksi pengguna (menambah XP, mengurangi nyawa, klaim hadiah, menyelesaikan level/karakter) wajib disimpan ke penyimpanan lokal (`SharedPreferences`) terlebih dahulu agar UI merespons secara instan (0ms latency).
  2. Perubahan dimasukkan ke antrean sinkronisasi (`pending_sync_actions`) dengan deduplikasi key.
  3. Sinkronisasi ke Supabase (`auth.updateUser` & tabel `profiles`) dijalankan secara asynchronous dengan *mutex lock* (`_isSyncing`), *batching* (menggabungkan banyak key menjadi satu request), dan *exponential backoff* tanpa melempar *unhandled async exception* ke UI thread.
  4. Saat koneksi internet kembali (`Connectivity().onConnectivityChanged`), antrean otomatis di-*flush*.

### C. Temuan Masalah Baseline yang Wajib Diperbaiki Bertahap
1. **Sync & Async Error:** `LocalRepository.syncPendingActions` melempar `rethrow` pada pemanggilan unawaited di `queueAction` dan `startSyncListener`, serta `GameManager.syncToCloud` memicu *sync storm* (memanggil `queueAction` puluhan kali dalam loop).
2. **Design System:** Lebih dari 300 warna, ukuran font, dan padding masih di-*hardcode* di dalam file screen; belum ada `lib/core/theme/` dan belum mem-bundle font `NotoSansJP`.
3. **Bug Fungsional:**
   - `WelcomeScreen` me-reset bahasa dan tema di `initState`.
   - `SimulationReviewScreen` menampilkan urutan soal asli (`SimulationData.n5Questions`), sedangkan `userAnswers` direkam dari soal yang telah di-*shuffle* di `SimulationTestScreen`.
   - `ExerciseScreen` memanggil `klik.mp3` yang tidak ada di `assets/audio/` dan belum merender teks `widget.hint`.
4. **Performa:** `KanaScreen` menggunakan banyak `GridView.builder(shrinkWrap: true)` di dalam `SingleChildScrollView`; `GameManager._startTicker` membaca `SharedPreferences` setiap 1 detik.
5. **Keamanan:** URL/Key Supabase masih hardcoded di `main.dart` (harus dipindah ke konfigurasi `--dart-define` dengan fallback aman untuk development).

---

## 3. Pedoman Octalysis Gamification Framework (8 Core Drives)

Setiap fitur gamifikasi dipetakan dan didokumentasikan secara lengkap di `docs/OCTALYSIS_MAPPING.md`:
1. **Core Drive 1 — Epic Meaning & Calling:** Misi belajar, narasi *"Perjalanan menuju fasih bahasa Jepang (JLPT N5)"* bersama maskot Mochi, badge puncak *"Mirai (未来)"*.
2. **Core Drive 2 — Development & Accomplishment:** XP, level/bintang bertingkat (Star 1–3), 10 achievement badges, progress bar kuis, streak harian, dan *JLPT N5 Readiness Tracker*.
3. **Core Drive 3 — Empowerment of Creativity & Feedback:** Latihan menulis kaligrafi/coretan Kana (*stroke canvas*), umpan balik audio-visual instan (benar/salah), pilihan mengulang level (*replay* per bintang).
4. **Core Drive 4 — Ownership & Possession:** Koleksi karakter Hiragana (104), Katakana (104), dan Kanji (68) yang terbuka warnanya saat dipelajari, akumulasi XP sebagai mata uang dalam aplikasi, kustomisasi profil & avatar.
5. **Core Drive 5 — Social Influence & Relatedness:** Peringkat Global (*Global Leaderboard*) dengan podium Top 3 dan *sticky banner* posisi pengguna.
6. **Core Drive 6 — Scarcity & Impatience:** Sistem *Hearts/Nyawa* (maksimal 5, regenerasi 20 menit/nyawa), pembukaan bertahap Unit 1 → 2 → 3 → 4, pembukaan Simulasi JLPT N5 dengan 1.500 XP.
7. **Core Drive 7 — Unpredictability & Curiosity:** Kuis dengan pengacakan soal & kata pengecoh, variasi sapaan maskot Mochi, pengingat harian acak, dan *Daily Surprise/Bonus Reward*.
8. **Core Drive 8 — Loss & Avoidance:** Mekanisme streak harian (reset jika absen), perlindungan streak (*Streak Freeze/Shield*), pengingat sebelum streak hilang, timer ujian, serta peringatan sebelum keluar dari sesi latihan.

> **Aturan Desain Gamifikasi:**
> - Utamakan **White Hat Core Drives (1, 2, 3)** sebagai fondasi motivasi intrinsik agar pengguna merasa kompeten dan berdaya.
> - Gunakan **Black Hat Core Drives (6, 7, 8)** secukupnya sebagai pemicu kebiasaan (*habit trigger*) tanpa memanipulasi atau membuat pengguna frustrasi.
> - Setiap penambahan atau perubahan fitur wajib mencantumkan **Core Drive** yang dituju.

---

## 4. Pedoman Design System (`lib/core/theme/`)

- **Aturan Utama:** Gunakan **Material 3**. Seluruh warna, tipografi, spacing, dan radius terpusat di `lib/core/theme/` (`AppColors`, `AppTextStyles`, `AppSpacing`, `AppTheme`). **DILARANG** melakukan *hardcode* warna (`Color(0xFF...)`), ukuran font, atau angka spacing/radius secara langsung di widget UI.
- **Kontras & Aksesibilitas:** Wajib memenuhi standar **WCAG AA** (minimal rasio kontras **4.5:1** untuk teks normal dan **3.0:1** untuk teks besar/komponen UI). Ukuran area sentuh (*tap target*) minimal **48x48 dp** dan dilengkapi `Semantics`.

### A. Palet Warna Resmi (Japanese Modern Heritage — Light & Dark Mode)

| Token (`AppColors`) | Light Mode | Dark Mode | Deskripsi & Penggunaan |
| :--- | :--- | :--- | :--- |
| `primary` | `#B84A1C` | `#F08A5D` | *Akane Terracotta / Warm Persimmon* — CTA utama, node aktif, aksen brand (WCAG AA dengan teks di atasnya). |
| `primaryContainer` | `#FCE8DF` | `#4A2515` | Latar kartu terpilih, badge primer, highlight lembut. |
| `secondary` | `#2B4C7E` | `#7FA6E0` | *Ai-iro Indigo* — Aksen sekunder (Katakana, tracker, informasi). |
| `secondaryContainer`| `#E3ECF8` | `#1E3252` | Latar chip/badge sekunder. |
| `accent` | `#D97706` | `#FBBF24` | *Kitsune Amber / Kin Gold* — Streak, bintang, XP, medali emas. |
| `accentContainer` | `#FEF3C7` | `#452B07` | Latar indikator XP/Streak. |
| `background` | `#F9F6F0` | `#121316` | *Washi Cream / Sumi Ink* — `scaffoldBackgroundColor` seluruh aplikasi. |
| `surface` | `#FFFFFF` | `#1C1E22` | *Pure Washi / Charcoal* — Kartu, dialog, bottom nav, bottom sheet. |
| `surfaceVariant` | `#EFECE6` | `#282A30` | Input field, track progress bar, node terkunci. |
| `textPrimary` | `#231F1C` | `#F5F3EF` | Teks judul dan isi utama (Kontras > 14:1). |
| `textSecondary` | `#635D57` | `#B5AFA8` | Subtitle, caption, hint (Kontras ≥ 5.7:1, lulus WCAG AA). |
| `border` | `#DFD9CE` | `#32353C` | Garis tepi kartu, divider, dan outline tombol. |
| `success` | `#1E7E48` | `#4ADE80` | *Matcha Green* — Jawaban benar, kelulusan ujian. |
| `error` | `#C92A2A` | `#F87171` | *Beni Crimson* — Jawaban salah, indikator nyawa/hearts, aksi destruktif. |
| `warning` | `#B45309` | `#FBBF24` | *Yuzu Ochre* — Peringatan waktu ujian, notifikasi streak. |

### B. Tipografi (`AppTextStyles`)
- **Font UI:** `Nunito` (dibundel di `assets/fonts/`).
- **Font Teks Jepang:** `NotoSansJP` (dibundel sebagai asset offline di `assets/fonts/` untuk Hiragana, Katakana, dan Kanji).
- **Skala Tipografi:**
  - `displayLarge`: 48px, w900 (Karakter utama kuis, skor simulasi)
  - `displayMedium`: 32px, w900 (Nama profil, gauge kesiapan JLPT)
  - `headlineLarge`: 26px, w900 (Judul halaman utama)
  - `headlineMedium`: 22px, w800 (Judul AppBar, Dialog, Header Unit)
  - `titleLarge`: 18px, w800 (Judul kartu, node belajar, pertanyaan)
  - `titleMedium`: 16px, w700 (Teks tombol utama, pilihan jawaban)
  - `bodyLarge`: 15px, w600 (Deskripsi materi, penjelasan jawaban)
  - `bodyMedium`: 14px, w500 (Teks paragraf & informasi umum)
  - `labelLarge`: 12px, w800, letterSpacing 1.2 (Tag, badge, label bagian)

### C. Animasi & Responsivitas
- Durasi animasi standar: **150ms – 400ms** dengan kurva natural (`Curves.easeOutCubic`, `Curves.easeInOut`).
- Wajib menghormati pengaturan aksesibilitas **`MediaQuery.disableAnimationsOf(context)`** (*reduce motion*).
- Layout responsif dari layar ponsel kecil (< 360dp) hingga tablet/desktop (> 600dp / > 900dp) dengan `SafeArea` dan pembatas lebar konten (`BoxConstraints(maxWidth: 800)`).

---

## 5. Standar Performa, Kualitas Kode & Pengujian

1. **Performa 60 FPS:**
   - Gunakan `const` constructor secara disiplin.
   - Pecah widget berukuran besar menjadi sub-widget terfokus (1 file = 1 tanggung jawab utama).
   - Gunakan lazy loading (`ListView.builder`, `SliverGrid`) — hindari nested `shrinkWrap: true` untuk daftar panjang.
   - Simpan state timer di memori (jangan memanggil `SharedPreferences.getInstance()` di dalam `Timer.periodic` setiap detik).
   - Selalu `dispose()` semua `TextEditingController`, `AnimationController`, `PageController`, `SignatureController`, `Timer`, dan `StreamSubscription`.
2. **Kualitas Kode & Linting:**
   - Penamaan konsisten: `snake_case.dart` untuk nama file, `PascalCase` untuk class/enum, `camelCase` untuk variabel/method.
   - `flutter_lints` aktif; setiap perubahan wajib lulus **`flutter analyze` dengan 0 error dan 0 warning**.
3. **Keamanan:**
   - Gunakan `String.fromEnvironment` (`--dart-define`) untuk kredensial Supabase & Google Client ID, serta pertimbangkan keamanan Row Level Security (RLS) pada tabel Supabase.
4. **Pengujian & Build:**
   - Tulis *unit test* untuk logika inti (perhitungan XP, level/bintang, streak, regenerasi nyawa, dan antrean sinkronisasi `LocalRepository`) serta *widget test* untuk komponen UI utama.
   - Pastikan aplikasi selalu dapat di-*build* pada target **Windows** dan **Android** setelah setiap tahap perubahan.
