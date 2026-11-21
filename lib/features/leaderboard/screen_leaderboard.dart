import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/game_manager.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_snackbar.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _rankings = [];
  String? _currentUserId;
  Map<String, dynamic>? _currentUserData;
  int _currentUserRank = 0;

  @override
  void initState() {
    super.initState();
    _currentUserId = _supabase.auth.currentUser?.id;
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _supabase
          .from('profiles')
          .select('id, display_name, avatar_url, gm_xp, gm_streak')
          .limit(20);

      if (mounted) {
        setState(() {
          final List<Map<String, dynamic>> data =
              List<Map<String, dynamic>>.from(response);

          data.sort(
            (a, b) => ((b['gm_xp'] as num?)?.toInt() ?? 0)
                .compareTo((a['gm_xp'] as num?)?.toInt() ?? 0),
          );

          _rankings = data;

          _currentUserData = null;
          _currentUserRank = 0;

          for (int i = 0; i < _rankings.length; i++) {
            if (_rankings[i]['id'] == _currentUserId) {
              _currentUserData = _rankings[i];
              _currentUserRank = i + 1;
              break;
            }
          }

          if (_currentUserData == null && _currentUserId != null) {
            _currentUserData = {
              'id': _currentUserId,
              'display_name': 'Kamu',
              'avatar_url': globalAvatarUrl.value,
              'gm_xp': globalXP.value,
              'gm_streak': globalStreak.value,
            };
            _currentUserRank = 0;
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Leaderboard Fetch Error: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
        AppSnackbar.showError(
          context,
          _t(
            "Connection error. Showing cached rankings.",
            "Gagal memuat peringkat. Menampilkan data tersimpan.",
          ),
        );
      }
    }
  }

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        final Color bgColor =
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
        final Color textColor =
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
        final Color accentColor =
            isDark ? AppColors.primaryDark : AppColors.primaryLight;

        return PopScope(
          canPop: true,
          child: Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
              backgroundColor: bgColor,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded, color: textColor),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                _t("Global Rankings", "Peringkat Global"),
                style: AppTextStyles.titleLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            body: _buildBody(isDark, accentColor, textColor),
          ),
        );
      },
    );
  }

  Widget _buildBody(bool isDark, Color accentColor, Color textColor) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final errorColor = isDark ? AppColors.errorDark : AppColors.errorLight;

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: accentColor));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: errorColor,
                size: 48,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: textColor),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: _t("Retry", "Coba Lagi"),
                expand: false,
                onPressed: _fetchLeaderboard,
              ),
            ],
          ),
        ),
      );
    }

    if (_rankings.isEmpty) {
      return Center(
        child: Text(
          _t("No players yet", "Belum ada pemain"),
          style: AppTextStyles.titleMedium.copyWith(color: textColor),
        ),
      );
    }

    return Stack(
      children: [
        Column(
          children: [
            if (_rankings.length >= 3)
              _buildPodium(isDark, reduceMotion)
            else if (_rankings.isNotEmpty)
              _buildMiniPodium(isDark),

            const SizedBox(height: AppSpacing.xl),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.radiusXxl),
                    topRight: Radius.circular(AppSpacing.radiusXxl),
                  ),
                  boxShadow: AppShadows.navBar(isDark),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xxl,
                    AppSpacing.xl,
                    120,
                  ),
                  itemCount: _rankings.length > 3 ? _rankings.length - 3 : 0,
                  separatorBuilder: (context, index) => Divider(
                    color:
                        isDark ? AppColors.borderDark : AppColors.borderLight,
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final listIndex = index + 3;
                    final user = _rankings[listIndex];
                    final bool isMe = user['id'] == _currentUserId;

                    if (reduceMotion) {
                      return _buildRankingRow(
                        listIndex + 1,
                        user,
                        isMe,
                        isDark,
                        accentColor,
                      );
                    }

                    return TweenAnimationBuilder<double>(
                      duration: AppSpacing.animSlow,
                      curve: Curves.easeOutCubic,
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 24 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: _buildRankingRow(
                        listIndex + 1,
                        user,
                        isMe,
                        isDark,
                        accentColor,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),

        if (_currentUserData != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildStickyUserBanner(isDark),
          ),
      ],
    );
  }

  Widget _buildMiniPodium(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _rankings.asMap().entries.map((entry) {
          final int idx = entry.key;
          final user = entry.value;
          final Color color = idx == 0
              ? AppColors.medalGold
              : (idx == 1 ? AppColors.medalSilver : AppColors.medalBronze);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: _buildPodiumItem(user, idx + 1, 150, color, isDark),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPodium(bool isDark, bool reduceMotion) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildAnimatedPodiumItem(
            _rankings[1],
            2,
            140,
            AppColors.medalSilver,
            isDark,
            150,
            reduceMotion,
          ),
          _buildAnimatedPodiumItem(
            _rankings[0],
            1,
            170,
            AppColors.medalGold,
            isDark,
            0,
            reduceMotion,
          ),
          _buildAnimatedPodiumItem(
            _rankings[2],
            3,
            130,
            AppColors.medalBronze,
            isDark,
            300,
            reduceMotion,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedPodiumItem(
    Map<String, dynamic> user,
    int rank,
    double height,
    Color color,
    bool isDark,
    int delayMs,
    bool reduceMotion,
  ) {
    if (reduceMotion) {
      return _buildPodiumItem(user, rank, height, color, isDark);
    }
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: delayMs)),
      builder: (context, snapshot) {
        return TweenAnimationBuilder<double>(
          duration: AppSpacing.animSlow,
          curve: Curves.easeOutBack,
          tween: snapshot.connectionState == ConnectionState.done
              ? Tween(begin: 0.0, end: 1.0)
              : Tween(begin: 0.0, end: 0.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: _buildPodiumItem(user, rank, height, color, isDark),
            );
          },
        );
      },
    );
  }

  Widget _buildPodiumItem(
    Map<String, dynamic> user,
    int rank,
    double height,
    Color color,
    bool isDark,
  ) {
    final String? avatarUrl = user['avatar_url'] as String?;
    final String displayName =
        (user['display_name'] as String?) ?? 'Pelajar Anonim';
    final int xp = (user['gm_xp'] as num?)?.toInt() ?? 0;
    final int streak = (user['gm_streak'] as num?)?.toInt() ?? 0;
    final Color textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final Color subTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Column(
      children: [
        Text(
          "$rank",
          style: AppTextStyles.headlineLarge.copyWith(
            fontSize: rank == 1 ? 28 : 22,
            color: color,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
              ),
              child: CircleAvatar(
                radius: rank == 1 ? 40 : 30,
                backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                    ? NetworkImage(avatarUrl)
                    : const AssetImage('assets/images/profileDefault.png')
                        as ImageProvider,
              ),
            ),
            if (rank == 1)
              const Positioned(
                top: -15,
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.medalGold,
                  size: 30,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          displayName,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: rank == 1 ? 16 : 14,
            color: textColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Column(
            children: [
              Text(
                "$xp XP",
                style: AppTextStyles.labelMedium.copyWith(
                  color: isDark ? color : textColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                "$streak ${_t("Days", "Hari")}",
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 10,
                  color: subTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRankingRow(
    int rank,
    Map<String, dynamic> user,
    bool isMe,
    bool isDark,
    Color accentColor,
  ) {
    final String? avatarUrl = user['avatar_url'] as String?;
    final String displayName =
        (user['display_name'] as String?) ?? 'Pelajar Anonim';
    final int xp = (user['gm_xp'] as num?)?.toInt() ?? 0;
    final int streak = (user['gm_streak'] as num?)?.toInt() ?? 0;
    final Color textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final Color subTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isMe ? accentColor.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border:
            isMe ? Border.all(color: accentColor.withValues(alpha: 0.3)) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              "$rank",
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w900,
                color: rank <= 3 ? accentColor : subTextColor,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          CircleAvatar(
            radius: 20,
            backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                ? NetworkImage(avatarUrl)
                : const AssetImage('assets/images/profileDefault.png')
                    as ImageProvider,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                Text(
                  "$xp XP • $streak ${_t("Days", "Hari")}",
                  style: AppTextStyles.labelMedium.copyWith(
                    color: subTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isMe)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      _t("YOU", "KAMU"),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppColors.starGold,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Colors.black,
              size: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyUserBanner(bool isDark) {
    final String? avatarUrl = _currentUserData?['avatar_url'] as String?;
    final String rankText = _currentUserRank > 0 ? "#$_currentUserRank" : "#-";
    final Color bannerColor =
        isDark ? AppColors.bannerPrimaryDark : AppColors.primaryLight;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusXl),
          topRight: Radius.circular(AppSpacing.radiusXl),
        ),
        boxShadow: AppShadows.navBar(isDark),
      ),
      child: Row(
        children: [
          Text(
            rankText,
            style: AppTextStyles.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          CircleAvatar(
            radius: 20,
            backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                ? NetworkImage(avatarUrl)
                : const AssetImage('assets/images/profileDefault.png')
                    as ImageProvider,
            backgroundColor: Colors.white24,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              (_currentUserData?['display_name'] as String?) ?? 'Kamu',
              style: AppTextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${_currentUserData?['gm_xp'] ?? 0} XP",
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (_currentUserData?['gm_streak'] != null)
                Text(
                  "${_currentUserData?['gm_streak'] ?? 0} ${_t("DAY STREAK", "HARI STREAK")}",
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
