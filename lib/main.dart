import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart'; // Tambahan import penting untuk HTTP Client

// Import Layer Data, Domain, & Presentation (Clean Architecture)
import 'core/network/network_info.dart';
import 'data/datasources/news_local_data_source.dart';
import 'data/datasources/news_remote_data_source.dart';
import 'data/models/news_model.dart'; // Membawa NewsModel dan NewsModelSchema dari generator
import 'data/repositories/news_repository_impl.dart';
import 'domain/repositories/news_repository.dart';
import 'domain/usecases/get_news_usecase.dart';
import 'presentation/blocs/news_cubit/news_cubit.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/theme/app_theme.dart'; 

// Inisialisasi Service Locator (GetIt) global
final sl = GetIt.instance;

void main() async {
  // Wajib dipanggil di awal jika main() berbentuk asynchronous sebelum runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Tempat Penyimpanan Database Isar
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [NewsModelSchema], // Pastikan build_runner sudah sukses dijalankan sebelumnya
    directory: dir.path,
  );

  // 2. Setup Dependency Injection (Mendaftarkan semua class ke GetIt)
  _setupDependencyInjection(isar);

  // 3. Jalankan Aplikasi Utama
  runApp(const MyApp());
}

/// Fungsi pembantu untuk mengelompokkan registrasi objek Clean Architecture
void _setupDependencyInjection(Isar isar) {
  // Core & External Utilities
  sl.registerLazySingleton<Isar>(() => isar);
  sl.registerLazySingleton<Dio>(() => Dio()); // Didaftarkan karena dibutuhkan oleh NetworkInfo dan RemoteDataSource

  // Memastikan registrasi NetworkInfo menggunakan parameter positional Dio
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl<Dio>())); 

  // Data Sources (Menggunakan parameter positional murni sesuai konstruktor asli)
  sl.registerLazySingleton<NewsRemoteDataSource>(() => NewsRemoteDataSourceImpl(sl<Dio>()));
  sl.registerLazySingleton<NewsLocalDataSource>(() => NewsLocalDataSourceImpl(sl<Isar>()));

  // Repositories
  sl.registerLazySingleton<NewsRepository>(() => NewsRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        networkInfo: sl(),
      ));

  // Use Cases (Menerima parameter positional instansiasi repository)
  sl.registerLazySingleton(() => GetNewsUseCase(sl()));

  // BLoC / Cubit (Menggunakan registerFactory agar state selalu ter-reset fresh)
  sl.registerFactory(() => NewsCubit(sl()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Menyuntikkan NewsCubit global ke seluruh aplikasi
        BlocProvider<NewsCubit>(
          create: (context) => sl<NewsCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'DigiNews Offline First',
        debugShowCheckedModeBanner: false,
        
        // Menggunakan konfigurasi Material 3 light theme buatan kita
        theme: AppTheme.lightTheme, 
        
        // Mengarahkan tampilan awal ke HomePage berita
        home: const HomePage(),
      ),
    );
  }
}