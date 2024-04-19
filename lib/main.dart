import 'package:bee2bee/constants/app_them_data.dart';
import 'package:bee2bee/screens/splash.dart';
import 'package:bee2bee/services/theme_provider_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';

bool? isViewd;
String? token;
bool? isDarkMode;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  isViewd = prefs.getBool('onBoard');
  token = prefs.getString("token");
  isDarkMode = prefs.getBool("THEMESTATUS");
  print("isviewd $isViewd");
  print("token $token");
  print("isDarkMode $isDarkMode");
  if (isDarkMode == null) {
    isDarkMode =
        SchedulerBinding.instance!.window.platformBrightness == Brightness.dark;
    ModeDataStorageService().setTheme(
        SchedulerBinding.instance!.window.platformBrightness ==
            Brightness.dark);
    // prefs.setBool("THEMESTATUS", SchedulerBinding.instance!.window.platformBrightness == Brightness.dark);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppThemeNotifier>(
      create: (context) => AppThemeNotifier(isDarkMode!),
      child: Consumer<AppThemeNotifier>(
        builder: (context, AppThemeNotifier appThemeNotifier, child) {
          return ConnectivityAppWrapper(
            app: MaterialApp(
              title: 'Bee2Bee',
              debugShowCheckedModeBanner: false,
              theme: appThemeNotifier.darkTheme
                  ? AppThemeData.darkTheme
                  : AppThemeData.lightTheme,
              // darkTheme: ThemeData.dark(),
              home: SplashScreen(
                isViewed: isViewd ?? false,
                token: token ?? "",
              ),
            ),
          );
        },
      ),
    );
  }
}
