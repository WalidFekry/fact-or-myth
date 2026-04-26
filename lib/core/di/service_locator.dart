import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/api_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/network_service.dart';
import '../../data/services/offline_storage_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/question_repository.dart';
import '../../data/repositories/leaderboard_repository.dart';
import '../../data/repositories/comment_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/daily_question_viewmodel.dart';
import '../../viewmodels/free_questions_viewmodel.dart';
import '../../viewmodels/leaderboard_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/comment_viewmodel.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  
  // Initialize offline storage
  final offlineStorage = OfflineStorageService();
  await offlineStorage.init();
  getIt.registerSingleton<OfflineStorageService>(offlineStorage);
  
  // Services
  getIt.registerLazySingleton<StorageService>(
    () => StorageService(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<ApiService>(() => ApiService());
  getIt.registerLazySingleton<NetworkService>(() => NetworkService());
  
  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<ApiService>(), getIt<StorageService>()),
  );
  getIt.registerLazySingleton<QuestionRepository>(
    () => QuestionRepository(
      getIt<ApiService>(),
      getIt<OfflineStorageService>(),
      getIt<NetworkService>(),
    ),
  );
  getIt.registerLazySingleton<LeaderboardRepository>(
    () => LeaderboardRepository(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<CommentRepository>(
    () => CommentRepository(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(getIt<ApiService>(), getIt<StorageService>()),
  );
  
  // ViewModels
  getIt.registerLazySingleton<ThemeViewModel>(
    () => ThemeViewModel(getIt<StorageService>()),
  );
  getIt.registerLazySingleton<AuthViewModel>(
    () => AuthViewModel(getIt<AuthRepository>()),
  );
  getIt.registerFactory<DailyQuestionViewModel>(
    () => DailyQuestionViewModel(
      getIt<QuestionRepository>(),
      getIt<AuthRepository>(),
      getIt<NetworkService>(),
    ),
  );
  getIt.registerFactory<FreeQuestionsViewModel>(
    () => FreeQuestionsViewModel(
      getIt<QuestionRepository>(),
      getIt<NetworkService>(),
    ),
  );
  getIt.registerFactory<LeaderboardViewModel>(
    () => LeaderboardViewModel(
      getIt<LeaderboardRepository>(),
      getIt<NetworkService>(),
    ),
  );
  getIt.registerFactory<ProfileViewModel>(
    () => ProfileViewModel(
      getIt<ProfileRepository>(),
      getIt<AuthRepository>(),
      getIt<NetworkService>(),
    ),
  );
  getIt.registerFactory<CommentViewModel>(
    () => CommentViewModel(
      getIt<CommentRepository>(),
      getIt<AuthRepository>(),
      getIt<NetworkService>(),
    ),
  );
}
