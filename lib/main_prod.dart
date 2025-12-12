import 'package:kpp_lab/core/config/env.dart';
import 'package:kpp_lab/main_common.dart';

void main() async {
  await mainCommon(AppConfig(
    supabaseUrl: EnvProd.supabaseUrl,
    supabaseKey: EnvProd.supabaseKey,
    sentryDsn: EnvProd.sentryDsn,
    appTitle: EnvProd.appTitle,
  ));
}
