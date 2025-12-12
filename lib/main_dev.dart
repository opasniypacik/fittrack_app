import 'package:kpp_lab/core/config/env.dart';
import 'package:kpp_lab/main_common.dart';

void main() async {
  await mainCommon(AppConfig(
    supabaseUrl: EnvDev.supabaseUrl,
    supabaseKey: EnvDev.supabaseKey,
    sentryDsn: EnvDev.sentryDsn,
    appTitle: EnvDev.appTitle,
  ));
}
