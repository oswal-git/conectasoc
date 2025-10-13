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

  @override
  String get users => 'Users';

  @override
  String get associations => 'Associations';

  @override
  String get myProfile => 'My Profile';

  @override
  String get joinAssociation => 'Join Association';

  @override
  String get logout => 'Log Out';

  @override
  String get login => 'Login';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get profileSavedSuccess => 'Profile saved successfully';

  @override
  String get profileLoadError => 'Error loading profile.';

  @override
  String get name => 'Name';

  @override
  String get lastname => 'Last Name';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get language => 'Language';

  @override
  String get langSpanish => 'Español';

  @override
  String get langEnglish => 'English';

  @override
  String get langCatalan => 'Català';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get cropImage => 'Crop Image';

  @override
  String get association => 'Association';

  @override
  String get search => 'Search...';

  @override
  String get contact => 'Contact';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get associationsListTitle => 'Associations List';

  @override
  String get changesSavedSuccessfully => 'Changes saved successfully';

  @override
  String get shortName => 'Short name';

  @override
  String get longName => 'Long name';

  @override
  String get contactName => 'Contact name';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get associationIdCannotBeEmpty => 'Association ID cannot be empty.';

  @override
  String get shortAndLongNameRequired =>
      'Short name and long name are required.';

  @override
  String get invalidEmailFormat => 'Invalid email format.';

  @override
  String get errorUploadingLogo => 'Error uploading logo';

  @override
  String unexpectedErrorOcurred(Object error) {
    return 'An unexpected error occurred: $error';
  }

  @override
  String get incompleteAssociationData => 'New association data is incomplete.';

  @override
  String get mustSelectAnAssociation =>
      'You must select an association to join.';

  @override
  String get welcomeSubtitle => 'Associations Portal';

  @override
  String get welcomeReadOnlyTitle => 'Read Only';

  @override
  String get welcomeReadOnlyDescription =>
      'Explore content without registration';

  @override
  String get welcomeLoginTitle => 'Log In';

  @override
  String get welcomeLoginDescription => 'I already have an account';

  @override
  String get welcomeRegisterDescription =>
      'Full registration with notifications';

  @override
  String get exitReadOnlyMode => 'Exit Read-Only Mode';

  @override
  String get createAssociation => 'Create Association';

  @override
  String get deleteAssociation => 'Delete Association';

  @override
  String deleteAssociationConfirmation(Object associationName) {
    return 'Are you sure you want to delete the association \'$associationName\'? This action cannot be undone.';
  }

  @override
  String get associationHasUsersError =>
      'Cannot delete association because it has assigned users.';

  @override
  String get associationDeletedSuccessfully =>
      'Association deleted successfully.';

  @override
  String get delete => 'Delete';

  @override
  String get undo => 'Undo';

  @override
  String get contactPerson => 'Contact person';
}
