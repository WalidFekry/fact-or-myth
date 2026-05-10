import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/admob_ids.dart';
/// Centralized AdMob Service
/// Handles all ad types: Banner, Interstitial, Rewarded, App Open
/// Implements singleton pattern for global access
class AdService {
  final SharedPreferences _prefs;
  
  // Ad instances
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  AppOpenAd? _appOpenAd;
  
  // Loading states
  bool _isInterstitialLoading = false;
  bool _isRewardedLoading = false;
  bool _isAppOpenLoading = false;
  
  // Interstitial ad cooldown and limits
  static const Duration _interstitialCooldown = Duration(minutes: 2, seconds: 30);
  static const int _maxInterstitialsPerHour = 3;
  DateTime? _lastInterstitialShow;
  int _interstitialHourlyCount = 0;
  DateTime? _interstitialHourReset;
  
  // App Open ad limits
  static const int _maxAppOpenPerHour = 3;
  int _appOpenHourlyCount = 0;
  DateTime? _appOpenHourReset;
  
  // First launch tracking
  bool _isFirstAppLaunch = true;
  bool _isFirstAppUsage = true;
  
  // Storage keys
  static const String _keyFirstOpenDone = 'ad_first_open_done';
  static const String _keyFirstUsageDone = 'ad_first_usage_done';
  static const String _keyInterstitialLastShow = 'ad_interstitial_last_show';
  static const String _keyInterstitialHourlyCount = 'ad_interstitial_hourly_count';
  static const String _keyInterstitialHourReset = 'ad_interstitial_hour_reset';
  static const String _keyAppOpenHourlyCount = 'ad_app_open_hourly_count';
  static const String _keyAppOpenHourReset = 'ad_app_open_hour_reset';

  AdService(this._prefs);

  /// Initialize AdMob SDK
  Future<void> initialize() async {
    try {
      MobileAds.instance.initialize();
      await _loadState();
      
      if (kDebugMode) {
        print('✅ AdMob initialized successfully');
        print('🧪 Test mode: ${AdMobIds.testAds}');
      }
      
      // Preload ads
      _preloadInterstitial();
      _preloadAppOpen();
      //_preloadRewarded();
    } catch (e) {
      if (kDebugMode) {
        print('❌ AdMob initialization error: $e');
      }
    }
  }

  /// Load saved state from SharedPreferences
  Future<void> _loadState() async {
    _isFirstAppLaunch = !(_prefs.getBool(_keyFirstOpenDone) ?? false);
    _isFirstAppUsage = !(_prefs.getBool(_keyFirstUsageDone) ?? false);
    
    final lastShowStr = _prefs.getString(_keyInterstitialLastShow);
    if (lastShowStr != null) {
      _lastInterstitialShow = DateTime.parse(lastShowStr);
    }
    
    _interstitialHourlyCount = _prefs.getInt(_keyInterstitialHourlyCount) ?? 0;
    final interstitialResetStr = _prefs.getString(_keyInterstitialHourReset);
    if (interstitialResetStr != null) {
      _interstitialHourReset = DateTime.parse(interstitialResetStr);
      _checkInterstitialHourlyReset();
    }
    
    _appOpenHourlyCount = _prefs.getInt(_keyAppOpenHourlyCount) ?? 0;
    final appOpenResetStr = _prefs.getString(_keyAppOpenHourReset);
    if (appOpenResetStr != null) {
      _appOpenHourReset = DateTime.parse(appOpenResetStr);
      _checkAppOpenHourlyReset();
    }
  }

  /// Mark first app launch as done
  Future<void> markFirstOpenDone() async {
    _isFirstAppLaunch = false;
    await _prefs.setBool(_keyFirstOpenDone, true);
  }

  /// Mark first app usage as done
  Future<void> markFirstUsageDone() async {
    _isFirstAppUsage = false;
    await _prefs.setBool(_keyFirstUsageDone, true);
  }

  /// Check and reset interstitial hourly counter
  void _checkInterstitialHourlyReset() {
    if (_interstitialHourReset == null) return;
    
    final now = DateTime.now();
    if (now.isAfter(_interstitialHourReset!)) {
      _interstitialHourlyCount = 0;
      _interstitialHourReset = now.add(const Duration(hours: 1));
      _prefs.setInt(_keyInterstitialHourlyCount, 0);
      _prefs.setString(_keyInterstitialHourReset, _interstitialHourReset!.toIso8601String());
    }
  }

  /// Check and reset app open hourly counter
  void _checkAppOpenHourlyReset() {
    if (_appOpenHourReset == null) return;
    
    final now = DateTime.now();
    if (now.isAfter(_appOpenHourReset!)) {
      _appOpenHourlyCount = 0;
      _appOpenHourReset = now.add(const Duration(hours: 1));
      _prefs.setInt(_keyAppOpenHourlyCount, 0);
      _prefs.setString(_keyAppOpenHourReset, _appOpenHourReset!.toIso8601String());
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // INTERSTITIAL ADS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Preload interstitial ad
  void _preloadInterstitial() {
    if (_isInterstitialLoading || _interstitialAd != null) return;
    
    _isInterstitialLoading = true;
    
    InterstitialAd.load(
      adUnitId: AdMobIds.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _preloadInterstitial(); // Preload next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              if (kDebugMode) {
                print('❌ Interstitial failed to show: $error');
              }
              ad.dispose();
              _interstitialAd = null;
              _preloadInterstitial();
            },
          );
          
          if (kDebugMode) {
            print('✅ Interstitial ad loaded');
          }
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoading = false;
          if (kDebugMode) {
            print('❌ Interstitial ad failed to load: $error');
          }
          // Retry after delay
          Future.delayed(const Duration(seconds: 30), _preloadInterstitial);
        },
      ),
    );
  }

  /// Check if interstitial ad can be shown
  bool _canShowInterstitial() {
    // Never show on first app usage
    if (_isFirstAppUsage) {
      markFirstUsageDone();
      if (kDebugMode) {
        print('⏭️ Skipping interstitial: First app usage');
      }
      return false;
    }
    
    // Check hourly limit
    _checkInterstitialHourlyReset();
    if (_interstitialHourlyCount >= _maxInterstitialsPerHour) {
      if (kDebugMode) {
        print('⏭️ Skipping interstitial: Hourly limit reached');
      }
      return false;
    }
    
    // Check cooldown
    if (_lastInterstitialShow != null) {
      final timeSinceLastShow = DateTime.now().difference(_lastInterstitialShow!);
      if (timeSinceLastShow < _interstitialCooldown) {
        final remaining = _interstitialCooldown - timeSinceLastShow;
        if (kDebugMode) {
          print('⏭️ Skipping interstitial: Cooldown (${remaining.inSeconds}s remaining)');
        }
        return false;
      }
    }
    
    return true;
  }

  /// Show interstitial ad
  Future<void> showInterstitialAd({VoidCallback? onAdDismissed}) async {
    if (!_canShowInterstitial()) {
      onAdDismissed?.call();
      return;
    }
    
    if (_interstitialAd == null) {
      if (kDebugMode) {
        print('⏭️ Interstitial ad not ready');
      }
      onAdDismissed?.call();
      _preloadInterstitial(); // Try to load
      return;
    }
    
    // Update tracking
    _lastInterstitialShow = DateTime.now();
    _interstitialHourlyCount++;
    
    _interstitialHourReset ??= DateTime.now().add(const Duration(hours: 1));
    
    await _prefs.setString(_keyInterstitialLastShow, _lastInterstitialShow!.toIso8601String());
    await _prefs.setInt(_keyInterstitialHourlyCount, _interstitialHourlyCount);
    await _prefs.setString(_keyInterstitialHourReset, _interstitialHourReset!.toIso8601String());
    
    // Set callback before showing
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _preloadInterstitial();
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        if (kDebugMode) {
          print('❌ Interstitial failed to show: $error');
        }
        ad.dispose();
        _interstitialAd = null;
        _preloadInterstitial();
        onAdDismissed?.call();
      },
    );
    
    await _interstitialAd!.show();
    
    if (kDebugMode) {
      print('📺 Interstitial ad shown (Count: $_interstitialHourlyCount/$_maxInterstitialsPerHour)');
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // APP OPEN ADS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Preload app open ad
  void _preloadAppOpen() {
    if (!_canShowAppOpen()) {
      return;
    }

    if (_isAppOpenLoading || _appOpenAd != null) return;
    
    _isAppOpenLoading = true;
    
    AppOpenAd.load(
      adUnitId: AdMobIds.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenLoading = false;
          showAppOpenAd();
          if (kDebugMode) {
            print('✅ App Open ad loaded');
          }
        },
        onAdFailedToLoad: (error) {
          _isAppOpenLoading = false;
          if (kDebugMode) {
            print('❌ App Open ad failed to load: $error');
          }
        },
      ),
    );
  }

  /// Check if app open ad can be shown
  bool _canShowAppOpen() {
    // Never show on first app launch
    if (_isFirstAppLaunch) {
      markFirstOpenDone();
      if (kDebugMode) {
        print('⏭️ Skipping app open: First app launch');
      }
      return false;
    }
    
    // Check hourly limit
    _checkAppOpenHourlyReset();
    if (_appOpenHourlyCount >= _maxAppOpenPerHour) {
      if (kDebugMode) {
        print('⏭️ Skipping app open: Hourly limit reached');
      }
      return false;
    }
    
    return true;
  }

  /// Show app open ad
  Future<void> showAppOpenAd({VoidCallback? onAdDismissed}) async {
    if (_appOpenAd == null) {
      if (kDebugMode) {
        print('⏭️ App Open ad not ready');
      }
      onAdDismissed?.call();
      _preloadAppOpen();
      return;
    }
    
    // Update tracking
    _appOpenHourlyCount++;
    
    _appOpenHourReset ??= DateTime.now().add(const Duration(hours: 1));
    
    await _prefs.setInt(_keyAppOpenHourlyCount, _appOpenHourlyCount);
    await _prefs.setString(_keyAppOpenHourReset, _appOpenHourReset!.toIso8601String());
    
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _appOpenAd = null;
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        if (kDebugMode) {
          print('❌ App Open ad failed to show: $error');
        }
        ad.dispose();
        _appOpenAd = null;
        onAdDismissed?.call();
      },
    );
    
    await _appOpenAd!.show();
    
    if (kDebugMode) {
      print('📺 App Open ad shown (Count: $_appOpenHourlyCount/$_maxAppOpenPerHour)');
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // REWARDED ADS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Preload rewarded ad
  void _preloadRewarded() {
    if (_isRewardedLoading || _rewardedAd != null) return;
    
    _isRewardedLoading = true;
    
    RewardedAd.load(
      adUnitId: AdMobIds.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
          
          if (kDebugMode) {
            print('✅ Rewarded ad loaded');
          }
        },
        onAdFailedToLoad: (error) {
          _isRewardedLoading = false;
          if (kDebugMode) {
            print('❌ Rewarded ad failed to load: $error');
          }
          // Retry after delay
          Future.delayed(const Duration(seconds: 30), _preloadRewarded);
        },
      ),
    );
  }

  /// Show rewarded ad
  Future<void> showRewardedAd({
    required Function(RewardItem) onRewardEarned,
    VoidCallback? onAdDismissed,
    VoidCallback? onAdFailed,
  }) async {
    if (_rewardedAd == null) {
      if (kDebugMode) {
        print('⏭️ Rewarded ad not ready');
      }
      onAdFailed?.call();
      _preloadRewarded();
      return;
    }
    
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _preloadRewarded();
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        if (kDebugMode) {
          print('❌ Rewarded ad failed to show: $error');
        }
        ad.dispose();
        _rewardedAd = null;
        _preloadRewarded();
        onAdFailed?.call();
      },
    );
    
    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        if (kDebugMode) {
          print('🎁 User earned reward: ${reward.amount} ${reward.type}');
        }
        onRewardEarned(reward);
      },
    );
    
    if (kDebugMode) {
      print('📺 Rewarded ad shown');
    }
  }

  /// Check if rewarded ad is ready
  bool isRewardedAdReady() => _rewardedAd != null;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // CLEANUP
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Dispose all ads
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _appOpenAd?.dispose();
    _interstitialAd = null;
    _rewardedAd = null;
    _appOpenAd = null;
  }
}
