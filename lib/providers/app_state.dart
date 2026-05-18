import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/models.dart';

/// App State Provider - يدير حالة التطبيق الرئيسية
class AppState extends ChangeNotifier {
  // Language
  String _currentLanguage = 'ar'; // Default to Arabic

  // User Role
  String? _userRole; // 'parent', 'specialist', or null

  // Child Name
  String? _childName;
  int? _childAge;
  String? _childSchool;

  // Doctor Profile
  DoctorProfile? _currentDoctor;

  // Theme Mode
  bool _isDarkMode = false;

  // Loading States
  bool _isLoading = false;

  // People Management
  List<Person> _people = [];

  // Initialization
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // Getters
  String get currentLanguage => _currentLanguage;
  String? get userRole => _userRole;
  String? get childName => _childName;
  int? get childAge => _childAge;
  String? get childSchool => _childSchool;
  DoctorProfile? get currentDoctor => _currentDoctor;
  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  List<Person> get people => _people;

  bool get isLoggedIn => _userRole != null;

  /// Initialize the app state from storage
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    // Load saved values
    _currentLanguage = _prefs.getString('language') ?? 'ar';
    _userRole = _prefs.getString('userRole');
    _childName = _prefs.getString('childName');
    _childAge = _prefs.getInt('childAge');
    _childSchool = _prefs.getString('childSchool');
    _isDarkMode = _prefs.getBool('isDarkMode') ?? false;

    // Load people
    _loadPeople();

    // Initialize doctor profile with mock data for now
    if (_userRole == 'specialist') {
      _currentDoctor = DoctorProfile(
        id: '1',
        fullName: 'دكتور أحمد محمد',
        username: 'drahmed',
        password: 'password123',
        specialization: 'علاج النطق',
        email: 'ahmed@clinic.com',
        phone: '+201234567890',
      );
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Set the language
  Future<void> setLanguage(String language) async {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      await _prefs.setString('language', language);
      notifyListeners();
    }
  }

  /// Set the user role
  Future<void> setUserRole(String role) async {
    _userRole = role;
    await _prefs.setString('userRole', role);
    notifyListeners();
  }

  /// Set the child name
  Future<void> setChildName(String name) async {
    _childName = name;
    await _prefs.setString('childName', name);
    notifyListeners();
  }

  /// Set the child age
  Future<void> setChildAge(int age) async {
    _childAge = age;
    await _prefs.setInt('childAge', age);
    notifyListeners();
  }

  /// Set the child school
  Future<void> setChildSchool(String school) async {
    _childSchool = school;
    await _prefs.setString('childSchool', school);
    notifyListeners();
  }

  /// Set the current doctor profile
  Future<void> setCurrentDoctor(DoctorProfile? doctor) async {
    _currentDoctor = doctor;
    if (doctor != null) {
      await _prefs.setString('doctorFullName', doctor.fullName);
      await _prefs.setString('doctorUsername', doctor.username);
      await _prefs.setString('doctorEmail', doctor.email);
      await _prefs.setString('doctorPhone', doctor.phone);
    } else {
      await _prefs.remove('doctorFullName');
      await _prefs.remove('doctorUsername');
      await _prefs.remove('doctorEmail');
      await _prefs.remove('doctorPhone');
    }
    notifyListeners();
  }

  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  /// Set loading state
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Logout - clear all user data
  Future<void> logout() async {
    _userRole = null;
    _childName = null;
    _childAge = null;
    _childSchool = null;
    await _prefs.remove('userRole');
    await _prefs.remove('childName');
    await _prefs.remove('childAge');
    await _prefs.remove('childSchool');
    notifyListeners();
  }

  /// Reset app state
  Future<void> reset() async {
    await _prefs.clear();
    _currentLanguage = 'ar';
    _userRole = null;
    _childName = null;
    _childAge = null;
    _childSchool = null;
    _isDarkMode = false;
    _people = [];
    notifyListeners();
  }

  /// Add a new person
  void addPerson(Person person) {
    _people.add(person);
    _savePeople();
    notifyListeners();
  }

  /// Update an existing person
  void updatePerson(Person person) {
    final index = _people.indexWhere((p) => p.id == person.id);
    if (index != -1) {
      _people[index] = person;
      _savePeople();
      notifyListeners();
    }
  }

  /// Delete a person
  void deletePerson(String personId) {
    _people.removeWhere((p) => p.id == personId);
    _savePeople();
    notifyListeners();
  }

  /// Save people to SharedPreferences
  void _savePeople() {
    final peopleJson = _people
        .map((p) => {
              'id': p.id,
              'name': p.name,
              'relationship': p.relationship,
              'imageUrl': p.imageUrl,
            })
        .toList();
    _prefs.setString('people', jsonEncode(peopleJson));
  }

  /// Load people from SharedPreferences
  void _loadPeople() {
    final peopleString = _prefs.getString('people');
    if (peopleString != null) {
      try {
        final peopleJson = jsonDecode(peopleString) as List;
        _people = peopleJson
            .map((p) => Person(
                  id: p['id'],
                  name: p['name'],
                  relationship: p['relationship'],
                  imageUrl: p['imageUrl'],
                ))
            .toList();
      } catch (e) {
        _people = [];
      }
    }
  }
}
