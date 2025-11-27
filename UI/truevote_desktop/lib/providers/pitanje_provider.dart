import 'package:truevote_desktop/models/pitanje.dart';
import 'package:truevote_desktop/providers/base_provider.dart';

class PitanjeProvider extends BaseProvider<Pitanje> {
  PitanjeProvider() : super("Pitanje");

  @override
  Pitanje fromJson(data) {
    return Pitanje.fromJson(data);
  }
}