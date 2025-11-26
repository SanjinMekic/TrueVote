import 'package:truevote_desktop/models/stranka.dart';
import 'package:truevote_desktop/providers/base_provider.dart';

class StrankaProvider extends BaseProvider<Stranka> {
  StrankaProvider() : super("Stranka");

  @override
  Stranka fromJson(data) {
    return Stranka.fromJson(data);
  }
}