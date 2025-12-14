import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:productivity_app/models/github_repo_model.dart';

class GithubRepository {
  final String baseUrl = "https://api.github.com";

  Future<List<GithubRepoModel>> getRepositories(String username, {String? token}) async {
    final Map<String, String> headers = {
      "Accept": "application/vnd.github.v3+json",
    };

    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
      // Quand on est authentifié, on utilise l'endpoint /user/repos pour voir TOUS les repos (privés inclus)
      // au lieu de /users/USERNAME/repos qui ne montre que le public.
      final response = await http.get(
        Uri.parse("$baseUrl/user/repos?visibility=all&sort=updated"),
        headers: headers,
      );
      return _parseResponse(response);
    } else {
      // Mode public sans token
      final response = await http.get(
        Uri.parse("$baseUrl/users/$username/repos?sort=updated"),
        headers: headers,
      );
      return _parseResponse(response);
    }
  }

  List<GithubRepoModel> _parseResponse(http.Response response) {
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => GithubRepoModel.fromJson(item)).toList();
    } else {
      throw Exception("Failed to load repositories: ${response.statusCode}");
    }
  }
}
