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
      final tryOnUrl = await _tryOnWithFashn(
        personPhoto: personPhoto,
        dressImageUrl: dressImageUrl,
      );
      // Remove background from result
      final cleanUrl = await removeBg(tryOnUrl);
      return {'imageUrl': cleanUrl.isNotEmpty ? cleanUrl : tryOnUrl};
    } else {
      return {'description': 'AI try-on not configured.'};
    }
  }

  static Future<String> removeBg(String imageUrl) async {
    try {
      final startRes = await http.post(
        Uri.parse('https://api.fashn.ai/v1/run'),
        headers: {
          'Authorization': 'Bearer $_fashnApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model_name': 'background-remove',
          'inputs': {'image': imageUrl},
        }),
      );
      final startData = jsonDecode(startRes.body);
      print('BG_REMOVE_STATUS: ${startRes.statusCode}');
      print('BG_REMOVE_BODY: ${startRes.body}');
      if (startData['error'] != null) return imageUrl;
      final predictionId = startData['id'];
      for (int i = 0; i < 20; i++) {
        await Future.delayed(const Duration(seconds: 2));
        final pollRes = await http.get(
          Uri.parse('https://api.fashn.ai/v1/status/$predictionId'),
          headers: {'Authorization': 'Bearer $_fashnApiKey'},
        );
        final pollData = jsonDecode(pollRes.body);
        print('BG_POLL_$i: ${pollData['status']}');
        if (pollData['status'] == 'completed') return pollData['output'][0];
        if (pollData['status'] == 'failed') return imageUrl;
      }
      return imageUrl;
    } catch (e) {
      print('BG remove error: $e');
      return imageUrl;
    }
  }

  static Future<String> _tryOnWithFashn({
    required File personPhoto,
    required String dressImageUrl,
  }) async {
    try {
      final personBytes = await personPhoto.readAsBytes();
      final b64Person = base64Encode(personBytes);
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
      for (int i = 0; i < 30; i++) {
        await Future.delayed(const Duration(seconds: 2));
        final pollRes = await http.get(
          Uri.parse('https://api.fashn.ai/v1/status/$predictionId'),
          headers: {'Authorization': 'Bearer $_fashnApiKey'},
        );
        final pollData = jsonDecode(pollRes.body);
        print('FASHN_POLL_$i: ${pollData['status']}');
        if (pollData['status'] == 'completed') return pollData['output'][0];
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
