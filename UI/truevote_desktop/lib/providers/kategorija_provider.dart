import 'package:truevote_desktop/models/kategorija.dart';
import 'package:truevote_desktop/providers/base_provider.dart';

class KategorijaProvider extends BaseProvider<Kategorija> {
  KategorijaProvider() : super("Kategorija");

  @override
  Kategorija fromJson(data) {
    return Kategorija.fromJson(data);
  }
}