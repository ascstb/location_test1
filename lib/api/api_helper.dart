import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:location_test1/model/current_location_model.dart';

class ApiBaseHelper {
  static final String _baseUrl =
      'http://r2devpros.com/node/Botanas/api/locations/locations';

  static Future<dynamic> post(CurrentLocation body) async {
    var uri = Uri.parse(_baseUrl);
    try {
      final response = await http.post(uri, body: json.encode(body.toJson()), headers: {
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json'
      });
      if (response.statusCode == 201) {
        return true;
      }
    } catch (error) {
      print('Caught Error: $error');
    }
    return false;
  }
}
