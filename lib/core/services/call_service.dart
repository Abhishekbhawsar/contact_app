import 'package:url_launcher/url_launcher.dart';

class CallService {
  const CallService();

  Future<bool> call(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber.trim());
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri);
  }
}
