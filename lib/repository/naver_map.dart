
import '../RemoteDataSource/naver_map_search.dart';

class RepositoryNaverMap {

  final NaverMapSearch _naverMapSearch = NaverMapSearch();

  Future<Map<String, dynamic>> getFetchSearchData(String query) async {
    return await _naverMapSearch.fetchSearchData(query);
  }


}