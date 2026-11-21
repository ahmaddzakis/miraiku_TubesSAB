# Pemetaan Octalysis Gamification Framework — MIRAIku

Dokumen ini memetakan seluruh fitur gamifikasi pada aplikasi pembelajaran bahasa Jepang **MIRAIku (JLPT N5)** ke dalam **8 Core Drives Octalysis Framework** (Yu-kai Chou). Dokumentasi ini menjadi landasan teoritis untuk Tugas Akhir serta acuan pengembangan fitur baru.

---

## Ringkasan Keseimbangan Octalysis (White Hat vs. Black Hat & Left Brain vs. Right Brain)

- **White Hat Gamification (Core Drives 1, 2, 3):** Menjadi **fondasi utama** aplikasi MIRAIku. Pengguna dimotivasi oleh makna perjalanan belajar menuju JLPT N5, rasa pencapaian saat menguasai karakter/level baru, dan umpan balik interaktif yang memberdayakan.
- **Black Hat Gamification (Core Drives 6, 7, 8):** Digunakan **secara terukur dan etis** hanya untuk membangun disiplin belajar harian (seperti pengingat streak dan batas nyawa agar pengguna tidak asal menebak), dilengkapi mekanisme pemulihan (beli nyawa dengan XP & perlindungan streak) agar pengguna tidak merasa tertekan.
- **Left Brain / Extrinsic (Core Drives 2, 4, 6):** XP, bintang, koleksi karakter Kana/Kanji, badge, dan syarat buka kunci simulasi.
- **Right Brain / Intrinsic (Core Drives 3, 5, 7):** Latihan menulis coretan (*stroke drawing*), papan peringkat komunitas, dan kejutan hadiah/kuis acak.

---

## Pemetaan Detail 8 Core Drives

### 1. Epic Meaning & Calling (Makna Epik & Panggilan Jiwa)
*Keyakinan bahwa pengguna sedang melakukan sesuatu yang lebih besar dari dirinya atau menjalani misi bermakna menuju kefasihan bahasa Jepang.*

| Fitur di MIRAIku | Lokasi Implementasi | Penjelasan Mekanisme & Landasan Teori | Status |
| :--- | :--- | :--- | :--- |
| **Maskot Mochi & Narasi Sambutan (*Okaeri*)** | `lib/features/common/screen_greeting_overlay.dart` | Menyambut pembelajar setiap membuka aplikasi dengan sapaan budaya Jepang (*"Okaeri! Ready to learn?"*, *"Ganbatte!"*) untuk membangun ikatan emosional dalam perjalanan belajar. | Aktif |
| **Dialog Motivasi Pra-Latihan** | `lib/features/learn/screen_learn.dart` | Menampilkan kutipan perjalanan (*"Satu langkah lebih dekat ke Jepang! 🎌"*, *"Perjalanan seribu mil dimulai dengan satu langkah!"*) sebelum memulai kuis. | Aktif |
| **Pencapaian Puncak "Mirai (未来)"** | `lib/features/profile/screen_profile.dart` | Badge pamungkas yang melambangkan visi masa depan pengguna setelah menamatkan seluruh Unit 1–4. | Aktif |
| **Visi Misi Belajar Harian / Onboarding Goal** | `lib/features/login/screen_welcome.dart` | Mengajak pengguna menetapkan komitmen sebagai pembelajar mandiri menuju kelulusan JLPT N5. | Aktif |

---

### 2. Development & Accomplishment (Perkembangan & Pencapaian)
*Dorongan internal untuk membuat kemajuan, mengembangkan keterampilan, mencapai penguasaan (*mastery*), dan mengatasi tantangan.*

| Fitur di MIRAIku | Lokasi Implementasi | Penjelasan Mekanisme & Landasan Teori | Status |
| :--- | :--- | :--- | :--- |
| **Experience Points (XP)** | `lib/core/game_manager.dart`, `lib/widgets/top_status_bar.dart` | Pengguna memperoleh +25 XP untuk setiap jawaban benar, +50 XP klaim harian, +200 XP klaim badge, dan +500 XP bonus streak 7 hari. | Aktif |
| **Sistem Bintang Bertingkat (1–3 Stars) & Unit Test** | `lib/features/learn/screen_learn.dart`, `lib/widgets/path_node.dart`, `lib/data/quiz_repository.dart` | Setiap materi memiliki 3 tingkat kesulitan (*Star 1, 2, 3*). Setiap kenaikan bintang menyajikan soal yang lebih menantang (*scaffolded mastery*), diakhiri dengan Ujian Unit. | Aktif |
| **10 Achievement Badges** | `lib/features/profile/screen_profile.dart` | Penghargaan visual dan bonus +200 XP untuk penguasaan spesifik: *Hiragana Master, Katakana Master, Kanji Learner, Alphabet Master, Simulator Pro, Streak 3/7/14/30 Hari,* dan *Mirai*. | Aktif |
| **JLPT N5 Readiness Tracker** | `lib/features/tracker/screen_jlpt_tracker.dart` | *Circular progress gauge* (0%–100%) yang menghitung kesiapan ujian N5 secara berbobot (Hiragana 20%, Katakana 20%, Kanji 30%, Unit 1–4 30%). | Aktif |
| **Progress Bar Real-Time & Skor/Grade Simulasi (S/A/B/C/D)** | `lib/features/learn/screen_exercise.dart`, `lib/features/simulation/simulation_result_screen.dart` | Memberikan visualisasi penyelesaian kuis secara langsung dan evaluasi standar JLPT (skor maksimal 180, batas lulus 80). | Aktif |

---

### 3. Empowerment of Creativity & Feedback (Pemberdayaan Kreativitas & Umpan Balik)
*Ketika pengguna terlibat dalam proses kreatif, mencoba berbagai kombinasi, memilih jalur belajar, dan langsung melihat hasil/umpan balik dari tindakan mereka.*

| Fitur di MIRAIku | Lokasi Implementasi | Penjelasan Mekanisme & Landasan Teori | Status |
| :--- | :--- | :--- | :--- |
| **Kanvas Latihan Menulis Aksara (*Stroke Drawing Canvas*)** | `lib/features/kana/screen_kana.dart` | Pengguna melihat animasi GIF urutan guratan (*stroke order*) lalu langsung mempraktikkan menulis aksara Hiragana/Katakana/Kanji di atas kanvas digital interaktif. | Aktif |
| **Umpan Balik Instan Multi-Sensorik** | `lib/features/learn/screen_exercise.dart`, `lib/core/sound_manager.dart`, `lib/widgets/shake_widget.dart` | Umpan balik langsung saat menjawab soal: efek suara (`benar.mp3`/`salah.mp3`/`victory.mp3`), getaran *haptic feedback*, animasi guncangan (`ShakeWidget`), dan koreksi jawaban instan. | Aktif |
| **Word Bank Sentence Construction** | `lib/features/learn/screen_exercise.dart` | Latihan menyusun kata/arti dengan memilih dan merangkai kepingan kata secara interaktif. | Aktif |
| **Pilihan Replay Tahapan Bintang & Review Pembahasan Simulasi** | `lib/widgets/path_node.dart`, `lib/features/simulation/simulation_review_screen.dart` | Pengguna bebas memilih tahapan bintang (1, 2, atau 3) yang ingin diasah kembali serta meninjau pembahasan lengkap (*explanation*) setiap soal simulasi JLPT. | Aktif |

---

### 4. Ownership & Possession (Kepemilikan & Penguasaan Koleksi)
*Dorongan di mana pengguna merasa memiliki sesuatu, sehingga secara alami ingin meningkatkan, melindungi, dan melengkapi koleksinya.*

| Fitur di MIRAIku | Lokasi Implementasi | Penjelasan Mekanisme & Landasan Teori | Status |
| :--- | :--- | :--- | :--- |
| **Koleksi Kartu Aksara (Hiragana, Katakana, Kanji)** | `lib/features/kana/screen_kana.dart`, `lib/core/game_manager.dart` | Grid karakter (104 Hiragana, 104 Katakana, 68 Kanji N5) yang berubah warna dan status menjadi *"LEARNED / SELESAI"* saat dipelajari, memicu efek *collection completion*. | Aktif |
| **Ekonomi XP (*Virtual Currency*)** | `lib/core/game_manager.dart`, `lib/features/simulation/screen_simulation.dart`, `lib/features/profile/screen_profile.dart` | XP yang dikumpulkan menjadi aset milik pengguna yang dapat dibelanjakan untuk membeli Nyawa (150 XP), **Streak Shield / Omamori** (300 XP), atau membuka kunci & tiket ujian Simulasi JLPT N5 (1.500 XP / 100 XP). | Aktif |
| **Personalisasi Profil & Riwayat Ujian** | `lib/features/profile/screen_settings.dart`, `lib/features/simulation/screen_simulation_history.dart` | Kepemilikan identitas pembelajar melalui foto avatar kustom (crop & upload ke Supabase Storage), nama tampilan, bio, serta arsip 10 riwayat skor simulasi terakhir. | Aktif |

---

### 5. Social Influence & Relatedness (Pengaruh Sosial & Keterkaitan)
*Elemen sosial yang mencakup perbandingan kemampuan, kompetisi sehat, apresiasi, dan rasa kebersamaan dengan pembelajar lain.*

| Fitur di MIRAIku | Lokasi Implementasi | Penjelasan Mekanisme & Landasan Teori | Status |
| :--- | :--- | :--- | :--- |
| **Peringkat Global (*Global Leaderboard*)** | `lib/features/leaderboard/screen_leaderboard.dart` | Menampilkan Top 20 pembelajar berdasarkan XP dan hari streak, lengkap dengan Podium Top 3 (Emas, Perak, Perunggu) untuk memicu kompetisi sehat. | Aktif |
| **Sticky User Rank Banner** | `lib/features/leaderboard/screen_leaderboard.dart` | Banner tetap di bagian bawah layar peringkat yang menunjukkan posisi, XP, dan streak pengguna saat ini dibandingkan komunitas. | Aktif |

---

### 6. Scarcity & Impatience (Kelangkaan & Ketidaksabaran)
*Dorongan menginginkan sesuatu karena jumlahnya terbatas, eksklusif, atau belum dapat diakses saat ini.*

| Fitur di MIRAIku | Lokasi Implementasi | Penjelasan Mekanisme & Landasan Teori | Status |
| :--- | :--- | :--- | :--- |
| **Sistem Nyawa (*Hearts*) & Cooldown Regenerasi** | `lib/core/game_manager.dart`, `lib/widgets/top_status_bar.dart` | Maksimal 5 nyawa dengan waktu pemulihan 20 menit per 1 nyawa. Membuat setiap kesempatan menjawab menjadi berharga dan mencegah *brute-force guessing*. | Aktif |
| **Pembukaan Konten Bertahap (*Progressive Unlocking*)** | `lib/features/learn/screen_learn.dart` | Level berikutnya dan Unit 2, 3, 4 terkunci (`NodeStatus.locked`) hingga pengguna menuntaskan syarat bintang dan Ujian Unit sebelumnya. | Aktif |
| **Gerbang Eksklusif Simulasi JLPT N5 (1.500 XP)** | `lib/features/simulation/screen_simulation.dart` | Mode Simulasi JLPT N5 dikunci di awal dan membutuhkan 1.500 XP untuk dibuka, menjadikannya *milestone* bergengsi yang dinanti pengguna. | Aktif |

---

### 7. Unpredictability & Curiosity (Ketidakpastian & Rasa Ingin Tahu)
*Dorongan untuk terus terlibat karena penasaran terhadap apa yang akan terjadi selanjutnya.*

| Fitur di MIRAIku | Lokasi Implementasi | Penjelasan Mekanisme & Landasan Teori | Status |
| :--- | :--- | :--- | :--- |
| **Pengacakan Soal & Kata Pengecoh (*Dynamic Shuffling*)** | `lib/features/learn/screen_exercise.dart`, `lib/features/simulation/screen_simulation_test.dart` | Urutan soal dan pilihan kata pengecoh (*decoy words*) diacak setiap sesi sehingga pengalaman kuis tidak monoton dan menguji pemahaman nyata. | Aktif |
| **Variasi Sapaan Maskot & Notifikasi Acak** | `lib/features/common/screen_greeting_overlay.dart`, `lib/core/notification_service.dart` | Ilustrasi ekspresi Mochi dan pesan pengingat belajar dipilih secara acak setiap hari. | Aktif |
| **Daily Omikuji Surprise (おみくじ)** | `lib/features/profile/screen_profile.dart` (`_claimDailyReward`) | Klaim harian interaktif bernuansa budaya Jepang (*Omikuji*). Setiap klaim menjamin minimal +50 Base XP ditambah undian keberuntungan positif: **Daikichi (大吉)** (+100 Total XP), **Chūkichi (中吉)** (+75 Total XP), atau **Shōkichi (小吉)** (+60 Total XP & +1 Heart). Bebas hasil negatif (*White-Hat aligned mystery box*). | Aktif |

---

### 8. Loss & Avoidance (Kehilangan & Penghindaran)
*Motivasi untuk bertindak guna menghindari konsekuensi negatif, seperti kehilangan progres atau runtutan belajar yang telah dibangun.*

| Fitur di MIRAIku | Lokasi Implementasi | Penjelasan Mekanisme & Landasan Teori | Status |
| :--- | :--- | :--- | :--- |
| **Streak Shield / Omamori (お守り)** | `lib/core/game_manager.dart` (`buyStreakShieldWithXP`, `_checkDailyStreak`), `lib/features/profile/screen_profile.dart` (`_buyStreakShield`) | Pengguna dapat menyimpan hingga 3 **Streak Shield (Omamori)** seharga 300 XP/shield (1 gratis untuk akun baru). Saat pengguna absen belajar, shield otomatis dikonsumsi untuk melindungi streak agar tidak hangus menjadi 1, menyeimbangkan *Core Drive 8* secara etis tanpa memicu demotivasi (*churn*). | Aktif |
| **Mekanisme Reset Streak Harian** | `lib/core/game_manager.dart` (`_checkDailyStreak`) | Jika pengguna melewatkan hari tanpa membuka aplikasi dan tidak memiliki *Streak Shield* yang cukup, streak harian kembali ke 1 (*sunk-cost loss avoidance*). | Aktif |
| **Home Screen Streak Widget & Pengingat Harian** | `lib/core/widget_service.dart`, `lib/core/notification_service.dart` | Widget layar utama ponsel dan notifikasi terjadwal mengingatkan pengguna sebelum hari berakhir agar streak tidak hangus. | Aktif |
| **Penalti Pengurangan Nyawa & Remedial Soal Salah** | `lib/features/learn/screen_exercise.dart` | Jawaban salah mengurangi 1 nyawa dan soal tersebut dimasukkan kembali ke antrean akhir sesi sampai berhasil dijawab benar. | Aktif |
| **Timer Ujian (15 Menit Unit Test & 50 Menit Simulasi)** | `lib/features/learn/screen_exercise.dart`, `lib/features/simulation/screen_simulation_test.dart` | Batas waktu nyata yang berubah warna menjadi merah saat sisa waktu ≤ 60 detik. | Aktif |
| **Peringatan Keluar Sesi (*"Chotto Matte!"*)** | `lib/features/learn/screen_exercise.dart`, `lib/features/simulation/screen_simulation_test.dart` | Dialog konfirmasi yang memperingatkan bahwa keluar di tengah sesi akan menghanguskan progres kuis/simulasi yang sedang berjalan. | Aktif |
