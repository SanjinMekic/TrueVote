import 'package:truevote_desktop/models/tip_izbora.dart';
import 'package:truevote_desktop/providers/base_provider.dart';

class TipIzboraProvider extends BaseProvider<TipIzbora> {
  TipIzboraProvider() : super("TipIzbora");

  @override
  TipIzbora fromJson(data) {
    return TipIzbora.fromJson(data);
  }
}