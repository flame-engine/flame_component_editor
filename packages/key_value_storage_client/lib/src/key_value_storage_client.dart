import 'package:shared_preferences/shared_preferences.dart';

/// {@template key_value_storage_client}
/// A client that persists string values under string keys.
/// {@endtemplate}
class KeyValueStorageClient {
  /// {@macro key_value_storage_client}
  new({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  /// Returns the value stored under [key], or `null` if there is none.
  Future<String?> read(String key) => _preferences.getString(key);

  /// Stores [value] under [key], replacing any previous value.
  Future<void> write(String key, String value) =>
      _preferences.setString(key, value);
}
