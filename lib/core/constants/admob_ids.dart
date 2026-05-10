import 'dart:io';
/// AdMob Configuration
class AdMobIds {
  // ⚠️ IMPORTANT: Set to false before releasing to production
  static const bool testAds = true;
  
  // Test Ad IDs (provided by Google)
  static const String _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIOS = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIOS = 'ca-app-pub-3940256099942544/4411468910';
  static const String _testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedIOS = 'ca-app-pub-3940256099942544/1712485313';
  static const String _testAppOpenAndroid = 'ca-app-pub-3940256099942544/9257395921';
  static const String _testAppOpenIOS = 'ca-app-pub-3940256099942544/5575463023';
  
  // Production Ad IDs (Replace with your actual AdMob IDs)
  static const String _prodBannerAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _prodBannerIOS = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _prodInterstitialAndroid = 'ca-app-pub-3354189036871191/7611299263';
  static const String _prodInterstitialIOS = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _prodRewardedAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _prodRewardedIOS = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _prodAppOpenAndroid = 'ca-app-pub-3354189036871191/3139525612';
  static const String _prodAppOpenIOS = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  
  // Banner Ad ID
  static String get bannerAdUnitId {
    if (testAds) {
      return Platform.isAndroid ? _testBannerAndroid : _testBannerIOS;
    }
    return Platform.isAndroid ? _prodBannerAndroid : _prodBannerIOS;
  }
  
  // Interstitial Ad ID
  static String get interstitialAdUnitId {
    if (testAds) {
      return Platform.isAndroid ? _testInterstitialAndroid : _testInterstitialIOS;
    }
    return Platform.isAndroid ? _prodInterstitialAndroid : _prodInterstitialIOS;
  }
  
  // Rewarded Ad ID
  static String get rewardedAdUnitId {
    if (testAds) {
      return Platform.isAndroid ? _testRewardedAndroid : _testRewardedIOS;
    }
    return Platform.isAndroid ? _prodRewardedAndroid : _prodRewardedIOS;
  }
  
  // App Open Ad ID
  static String get appOpenAdUnitId {
    if (testAds) {
      return Platform.isAndroid ? _testAppOpenAndroid : _testAppOpenIOS;
    }
    return Platform.isAndroid ? _prodAppOpenAndroid : _prodAppOpenIOS;
  }
}
