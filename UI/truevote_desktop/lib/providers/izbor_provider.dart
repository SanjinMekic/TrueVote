import 'package:truevote_desktop/models/izbor.dart';
import 'package:truevote_desktop/providers/base_provider.dart';

class IzborProvider extends BaseProvider<Izbor> {
  IzborProvider() : super("Izbor");

  @override
  Izbor fromJson(data) {
    return Izbor.fromJson(data);
  }
}