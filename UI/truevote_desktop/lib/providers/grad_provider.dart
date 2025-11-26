import 'package:truevote_desktop/models/drzava.dart';
import 'package:truevote_desktop/models/grad.dart';
import 'package:truevote_desktop/models/korisnik.dart';
import 'package:truevote_desktop/providers/base_provider.dart';

class GradProvider extends BaseProvider<Grad> {
  GradProvider() : super("Grad");

  @override
  Grad fromJson(data) {
    return Grad.fromJson(data);
  }
}