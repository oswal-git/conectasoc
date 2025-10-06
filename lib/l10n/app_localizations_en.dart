// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ConectAsoc';

  @override
  String get homePage => 'Home';

  @override
  String get noArticlesYet => 'No articles yet.';

  @override
  String get changeAssociation => 'Change Association';

  @override
  String get unknownAssociation => 'Unknown Association';

  @override
  String role(Object roleName) {
    return 'Role: $roleName';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String errorLoadingAssociations(Object error) {
    return 'Error loading associations: $error';
  }

  @override
  String get retry => 'Retry';

  @override
  String get createAccount => 'Create Account';

  @override
  String get registrationError => 'Registration Error';

  @override
  String get accept => 'Accept';

  @override
  String get unexpectedError => 'An unexpected error occurred.';

  @override
  String get leaveAssociation => 'Leave Association';

  @override
  String get leave => 'Leave';

  @override
  String get leaveAssociationConfirmationTitle => 'Confirm Leave';

  @override
  String leaveAssociationConfirmationMessage(Object associationName) {
    return 'Are you sure you want to leave the association \'$associationName\'? This action cannot be undone.';
  }
}
