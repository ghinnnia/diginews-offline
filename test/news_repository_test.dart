import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Import lokal menggunakan relative path agar aman dari perbedaan nama package di pubspec
import '../lib/core/network/network_info.dart';
import '../lib/data/models/news_model.dart';
import '../lib/data/repositories/news_repository_impl.dart';
import '../lib/data/datasources/news_remote_data_source.dart';
import '../lib/data/datasources/news_local_data_source.dart';

class MockRemoteDataSource extends Mock implements NewsRemoteDataSource {}
class MockLocalDataSource extends Mock implements NewsLocalDataSource {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late NewsRepositoryImpl repository;
  late MockRemoteDataSource mockRemote;
  late MockLocalDataSource mockLocal;
  late MockNetworkInfo mockNetwork;

  setUpAll(() {
    // Registrasi fallback value wajib mocktail agar parameter any() bekerja pada List<NewsModel>
    registerFallbackValue(<NewsModel>[]);
  });

  setUp(() {
    mockRemote = MockRemoteDataSource();
    mockLocal = MockLocalDataSource();
    mockNetwork = MockNetworkInfo();
    repository = NewsRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
      networkInfo: mockNetwork,
    );
  });

  test('Harus mengurutkan data berita secara Ascending (A-Z) sesuai NIM Genap', () async {
    // Arrange: Persiapan Data sesuai dengan struktur model Isar yang baru (menggunakan cascade operator)
    final dummyNews = [
      NewsModel()
        ..title = "Jakarta Dilanda Hujan"
        ..url = "https://jakarta.com",
      NewsModel()
        ..title = "Bandung Lautan Api"
        ..url = "https://bandung.com",
      NewsModel()
        ..title = "Aceh Indah Menawan"
        ..url = "https://aceh.com",
    ];
    
    when(() => mockNetwork.isConnected).thenAnswer((_) async => true);
    when(() => mockRemote.fetchTopHeadlines()).thenAnswer((_) async => dummyNews);
    when(() => mockLocal.cacheNews(any())).thenAnswer((_) async => {});

    // Act (Eksekusi fungsi)
    final result = await repository.getNews();

    // Assert (Validasi apakah hasil terurut secara Ascending: Aceh -> Bandung -> Jakarta)
    expect(result[0].title, "Aceh Indah Menawan");
    expect(result[1].title, "Bandung Lautan Api");
    expect(result[2].title, "Jakarta Dilanda Hujan");
  });
}