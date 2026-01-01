import 'package:truevote_mobile/models/pitanje.dart';
import 'package:truevote_mobile/providers/base_provider.dart';

class PitanjeProvider extends BaseProvider<Pitanje> {
  PitanjeProvider() : super("Pitanje");

  @override
  Pitanje fromJson(data) {
    return Pitanje.fromJson(data);
  }
}