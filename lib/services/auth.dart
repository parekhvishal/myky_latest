import 'dart:async';


import 'cart_service.dart';
import 'package:rxdart/rxdart.dart';
import 'storage.dart';

class Auth {
  static bool? _isLoggedIn;
  static Map? _user;
  static Map? _guestUser;
  static List? _packages;
  static String? _packageName;
  static String? _token;
  static int? _currentPackage;
  static int? _memberId;
  static bool? isUserVendor;
  static int? isAudio = 1;
  static bool? _isVendor;
  static bool? _isGuest;
  static int? _isMemberStatus;
  static bool? _profile;
  static StreamController? userStreamController;
  static Stream? userStream;
  static String? _userName;
  static bool? isMLMLoggedIn;
  static bool? isGuestLoggedIn = false;
  static Map? _userMLM;
  static String? _tokenMLM;
  static String appLanguage = 'en';
  static String? _tokenGuest;

  static Future<void> initialize() async {
    _user = await Storage.get('user');
    _guestUser = await Storage.get('userGuest');
    _token = await Storage.get('token');
    _tokenGuest = await Storage.get('tokenGuest');
    _currentPackage = await Storage.get('current_package');
    _memberId = await Storage.get('member_id');
    _packageName = await Storage.get('package');
    _isVendor = await Storage.get('isVendor');
    isUserVendor = await Storage.get('isVendor');
    _isGuest = await Storage.get('isGuest');
    _isMemberStatus = await Storage.get('isMemberStatus');
    _profile = await Storage.get('profile');
    _packages = await Storage.get("packages");
    _userName = await Storage.get("userName");
    _isLoggedIn = _token != null;
    isGuestLoggedIn = _tokenGuest != null;
    _userMLM = await Storage.get('userMLM');
    _tokenMLM = await Storage.get('tokenMLM');
    isMLMLoggedIn = _tokenMLM != null;

    _openUserStream();
  }

  static bool? check() {
    return _isLoggedIn;
  }

  static Map? user() {
    return _user;
  }

  static Map? userGuest() {
    return _guestUser;
  }

  static Map? userMLM() {
    return _userMLM;
  }

  static List? packages() {
    return _packages;
  }

  static token() {
    return _token;
  }

  static guestToken() {
    return _tokenGuest;
  }

  static String? tokenMLM() {
    return _tokenMLM;
  }

  static int? currentPackage() {
    return _currentPackage;
  }

  static int? memberId() {
    return _memberId;
  }

  static String? packageName() {
    return _packageName;
  }

  static String? userName() {
    return _userName;
  }

  static bool? isVendor() {
    return isUserVendor;
  }

  static bool? isGuest() {
    return isGuestLoggedIn;
  }

  static int? isMemberStatus() {
    return _isMemberStatus;
  }

  static bool? profile() {
    return _profile;
  }

  static Future<bool> setPackageName(String packageName) async {
    await Storage.set('package', packageName);
    return true;
  }

  static Future<bool> setCurrentPackage({int? package}) async {
    _currentPackage = package;
    await Storage.set('current_package', package);
    return true;
  }

  static Future<bool> setMemberId({int? memberId}) async {
    _memberId = memberId;
    await Storage.set('member_id', memberId);
    return true;
  }

  static Future<bool> setVendor({bool? isVendor}) async {
    isUserVendor = isVendor;
    await Storage.set('isVendor', isVendor);
    return true;
  }

  static Future<bool> setAudioSetting({int? audio}) async {
    isAudio = audio;
    await Storage.set('isAudio', isAudio);
    return true;
  }

  static Future<bool> setLanguage({required String language}) async {
    appLanguage = language;
    await Storage.set('appLanguage', appLanguage);
    return true;
  }

  static Future<bool> setGuest({bool? isGuest}) async {
    _isGuest = isGuest;
    await Storage.set('isGuest', isGuest);
    return true;
  }

  static Future<bool> setMemberStatus({int? isMemberStatus}) async {
    _isMemberStatus = isMemberStatus;
    await Storage.set('isMemberStatus', isMemberStatus);
    return true;
  }

  static Future<bool> setProfile(bool profile) async {
    await Storage.set('profile', profile);
    return true;
  }

  static Future<bool> setUsername(String userName) async {
    await Storage.set('userName', userName);
    return true;
  }

  static Future<bool> updateUser(Map? user) async {
    if (await Storage.get('user') != null) {
      _user = user;
      return await Storage.set('user', user);
    } else {
      return false;
    }
  }

  static Future<bool> login({
    Map? user,
    String? token,
    int? currentPackage,
    String? packageName,
    List? packages,
    bool? isVendor,
    bool? isGuest,
    profile,
  }) async {
    _user = user;
    _token = token;
    _currentPackage = currentPackage;
    _packageName = packageName;
    isUserVendor = isVendor;
    _isVendor = isVendor;
    _isGuest = isGuest;
    _profile = profile;
    _packages = packages;
    _isLoggedIn = true;
    await Storage.set('user', user);
    await Storage.set('token', token);
    await Storage.set('current_package', currentPackage);
    await Storage.set('package', packageName);
    await Storage.set('packages', packages);
    await Storage.set('isVendor', isVendor);
    await Storage.set('isGuest', isGuest);
    await Storage.set('profile', profile);
    _openUserStream();
    return true;
  }

  static Future<bool> guestLogin({Map? user, String? token}) async {
    _guestUser = user;
    _tokenGuest = token;
    isGuestLoggedIn = true;
    await Storage.set('userGuest', user);
    await Storage.set('tokenGuest', token);
    _openUserStream();
    return true;
  }

  static Future<bool> logout() async {
    _user = null;
    _token = null;
    _currentPackage = null;
    _memberId = null;
    isUserVendor = null;
    _isVendor = null;
    _isGuest = null;
    _isMemberStatus = null;
    _packages = null;
    _isLoggedIn = false;
    Cart.instance.reset();
    await Storage.delete('user');
    await Storage.delete('token');
    await Storage.delete('packages');
    await Storage.delete('current_package');
    await Storage.delete('isMemberStatus');
    await Storage.delete('package');
    await Storage.delete('isVendor');
    await Storage.delete('isGuest');
    await Storage.delete('profile');
    await Storage.delete('packages');

    await _closeUserStream();

    return true;
  }

  static Future<bool> loginMLM({Map? userMLM, String? tokenMLM}) async {
    _userMLM = userMLM;
    _tokenMLM = tokenMLM;
    isMLMLoggedIn = true;
    await Storage.set('userMLM', userMLM);
    await Storage.set('tokenMLM', tokenMLM);
    _openUserStream();
    return true;
  }

  static Future<bool> logoutMLM() async {
    _userMLM = null;
    _tokenMLM = null;
    isMLMLoggedIn = false;
    // pageName = "morado-ecommerce";
    // pageData = null;

    await Storage.delete('userMLM');
    await Storage.delete('tokenMLM');

    await _closeUserStream();

    return true;
  }

  static Future<bool> logoutGuest() async {
    _guestUser = null;
    _tokenGuest = null;
    isGuestLoggedIn = false;
    Cart.instance.reset();
    await Storage.delete('userGuest');
    await Storage.delete('tokenGuest');

    await _closeUserStream();

    return true;
  }

  static void _openUserStream() {
    if (userStreamController == null) {
      userStreamController = BehaviorSubject();
      userStream = userStreamController!.stream;
    }

    if (_user != null) {
      userStreamController!.add(_user);
    }
  }

  static Future<void> _closeUserStream() async {
    await userStreamController!.close();
    userStream = null;
    userStreamController = null;
  }
}
