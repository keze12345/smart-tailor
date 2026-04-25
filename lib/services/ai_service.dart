import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const _useFashn = true;
  static const _fashnApiKey = 'fa-Uvo66vEH5k4t-HNajRFd2V4fYtnzXRIPQ01jV';

  static Future<Map<String, String>> tryOn({
    required File personPhoto,
    required String dressImageUrl,
  }) async {
    if (_useFashn) {
      final url = await _tryOnWithFashn(
        personPhoto: personPhoto,
        dressImageUrl: dressImageUrl,
      );
      return {'imageUrl': url};
    } else {
      return {'description': 'AI try-on not configured.'};
    }
  }

  static Future<String> _tryOnWithFashn({
    required File personPhoto,
    required String dressImageUrl,
  }) async {
    try {
      final personBytes = await personPhoto.readAsBytes();
      final b64Person = base64Encode(personBytes);

      // Step 1: Start job with correct API format
      final startRes = await http.post(
        Uri.parse('https://api.fashn.ai/v1/run'),
        headers: {
          'Authorization': 'Bearer $_fashnApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model_name': 'tryon-v1.6',
          'inputs': {
            'model_image': 'data:image/jpeg;base64,$b64Person',
            'garment_image': dressImageUrl,
          },
        }),
      );

      print('FASHN_STATUS: ${startRes.statusCode}');
      print('FASHN_BODY: ${startRes.body}');

      final startData = jsonDecode(startRes.body);

      if (startData['error'] != null) {
        throw Exception('Fashn error: ${startData['error']}');
      }

      final predictionId = startData['id'];
      print('FASHN_ID: $predictionId');

      // Step 2: Poll for result
      for (int i = 0; i < 30; i++) {
        await Future.delayed(const Duration(seconds: 2));
        final pollRes = await http.get(
          Uri.parse('https://api.fashn.ai/v1/status/$predictionId'),
          headers: {'Authorization': 'Bearer $_fashnApiKey'},
        );
        final pollData = jsonDecode(pollRes.body);
        print('FASHN_POLL_$i: ${pollData['status']}');

        if (pollData['status'] == 'completed') {
          return pollData['output'][0];
        }
        if (pollData['status'] == 'failed') {
          throw Exception('Fashn job failed: ${pollData['error']}');
        }
      }
      throw Exception('Fashn timed out');
    } catch (e) {
      throw Exception('Fashn try-on failed: $e');
    }
  }
}
