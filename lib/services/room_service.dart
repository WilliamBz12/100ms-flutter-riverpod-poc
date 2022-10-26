import 'dart:convert';

//Package imports
import 'package:http/http.dart' as http;

import '../data_models/code_model.dart';

class RoomService {
  Future<String> generateToken({
    required String user,
    required String room,
  }) async {
    CodeModel codeAndDomain = getCode(room);
    Uri endPoint = Uri.parse('https://prod-in.100ms.live/hmsapi/get-token');

    http.Response response = await http.post(
      endPoint,
      body: {
        'code': codeAndDomain.code.trim(),
        'user_id': user,
        'role': 'member',
      },
      headers: {
        'subdomain': codeAndDomain.subDomain.trim(),
      },
    );

    var body = json.decode(response.body);

    return body['token'];
  }

  CodeModel getCode(String roomUrl) {
    String url = roomUrl;

    url = url.trim();
    bool isProdM = url.contains('.app.100ms.live/meeting/');
    bool isProdP = url.contains('.app.100ms.live/preview/');
    bool isQaM = url.contains('.qa-app.100ms.live/meeting/');
    bool isQaP = url.contains('.qa-app.100ms.live/preview/');

    if (!isProdM && !isQaM && isQaP && isProdP) throw Exception();

    List<String> codeAndDomain = [];
    String code = '';
    String subDomain = '';
    if (isProdM || isProdP) {
      codeAndDomain = isProdM
          ? url.split('.app.100ms.live/meeting/')
          : url.split('.app.100ms.live/preview/');
      code = codeAndDomain[1];
      subDomain = "${codeAndDomain[0].split("https://")[1]}.app.100ms.live";
    } else if (isQaM || isQaP) {
      codeAndDomain = isQaM
          ? url.split('.qa-app.100ms.live/meeting/')
          : url.split('.qa-app.100ms.live/preview/');
      code = codeAndDomain[1];
      subDomain = "${codeAndDomain[0].split("https://")[1]}.qa-app.100ms.live";
    }
    return CodeModel(code: code, subDomain: subDomain);
  }
}
