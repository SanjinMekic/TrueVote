import 'package:truevote_desktop/models/drzava.dart';
import 'package:truevote_desktop/models/grad.dart';
import 'package:truevote_desktop/models/korisnik.dart';
import 'package:truevote_desktop/models/opstina.dart';
import 'package:truevote_desktop/providers/base_provider.dart';

class OpstinaProvider extends BaseProvider<Opstina> {
  OpstinaProvider() : super("Opstina");

  @override
  Opstina fromJson(data) {
    return Opstina.fromJson(data);
  }
}