import 'package:truevote_mobile/models/kategorija.dart';
import 'package:truevote_mobile/providers/base_provider.dart';

class KategorijaProvider extends BaseProvider<Kategorija> {
  KategorijaProvider() : super("Kategorija");

  @override
  Kategorija fromJson(data) {
    return Kategorija.fromJson(data);
  }
}