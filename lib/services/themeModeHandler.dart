import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_mode_handler/theme_mode_manager_interface.dart';

class ThemeModeManager implements IThemeModeManager {


  @override
  Future<String> loadThemeMode() async {
    final _prefs = await SharedPreferences.getInstance();

    return _prefs.getString('themeMode');
  }

  @override
  Future<bool> saveThemeMode(String value) async {
    final _prefs = await SharedPreferences.getInstance();

    return _prefs.setString('themeMode', value);
  }
}