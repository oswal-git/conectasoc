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
  String get noAssociationAvailable => 'No association available';

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

  @override
  String get usersListTitle => 'Users List';

  @override
  String get editUser => 'Edit User';

  @override
  String get verifyEmailTitle => 'Verify Email';

  @override
  String get verifyEmailHeadline => 'Verify your email address';

  @override
  String verifyEmailInstruction(Object email) {
    return 'We have sent a verification email to $email. Please check your inbox and follow the instructions to activate your account.';
  }

  @override
  String get resendEmail => 'Resend email';

  @override
  String get verificationEmailSent => 'Verification email resent.';

  @override
  String errorResendingEmail(Object error) {
    return 'Error resending email: $error';
  }

  @override
  String get status => 'Status';

  @override
  String get memberships => 'Memberships';

  @override
  String get userHasNoMemberships =>
      'This user does not belong to any association.';

  @override
  String get roleTitle => 'Role';

  @override
  String get addMembership => 'Add Membership';

  @override
  String get addMembershipDialogTitle => 'Add Membership';

  @override
  String get selectAssociation => 'Select association';

  @override
  String get add => 'Add';

  @override
  String get notifications => 'Notifications';

  @override
  String get never => 'Never';

  @override
  String get morning => 'Morning';

  @override
  String get afternoon => 'Afternoon';

  @override
  String get morningAndAfternoon => 'Morning and Afternoon';

  @override
  String get deleteUser => 'Delete User';

  @override
  String deleteUserConfirmation(String userName) {
    return 'Are you sure you want to delete $userName? This action is irreversible.';
  }

  @override
  String get createUser => 'Create User';

  @override
  String get password => 'Password';

  @override
  String get editMode => 'Edit Mode';

  @override
  String get all => 'All';

  @override
  String get createArticle => 'Create Article';

  @override
  String get editArticle => 'Edit Article';

  @override
  String get title => 'Title';

  @override
  String get abstractContent => 'Abstract';

  @override
  String get category => 'Category';

  @override
  String get subcategory => 'Subcategory';

  @override
  String get sections => 'Sections';

  @override
  String get publishDateLabel => 'Publication Date';

  @override
  String get effectiveDateLabel => 'Effective Date';

  @override
  String get expirationDateLabel => 'Expiration Date (optional)';

  @override
  String get requiredField => 'Required field';

  @override
  String get selectCoverImage => 'Select Cover Image';

  @override
  String get articles => 'Articles';

  @override
  String get deleteArticle => 'Delete Article';

  @override
  String get articleTitle => 'Article Title';

  @override
  String get articleAbstract => 'Article Abstract';

  @override
  String get coverImage => 'Cover Image';

  @override
  String get articleStatus => 'Status';

  @override
  String get addSection => 'Add Section';

  @override
  String get removeSection => 'Remove Section';

  @override
  String get reorderSections => 'Reorder Sections';

  @override
  String get statusRedaccion => 'Draft';

  @override
  String get statusPublicado => 'Published';

  @override
  String get statusRevision => 'In Review';

  @override
  String get statusExpirado => 'Expired';

  @override
  String get statusAnulado => 'Cancelled';

  @override
  String get statusNotificar => 'Publicar y Notificar';

  @override
  String get statusNotificarShort => 'Notificar';

  @override
  String get notificationFreqNone => 'No recibir notificaciones';

  @override
  String get notificationFreqOnce => 'Una vez al día (12:00)';

  @override
  String get notificationFreqTwice => 'Dos veces (10:00 y 20:00)';

  @override
  String get notificationFreqThrice => 'Tres veces (10:00, 15:00, 20:00)';

  @override
  String get categoryInformacion => 'Information';

  @override
  String get categoryNoticias => 'News';

  @override
  String get categoryActas => 'Minutes';

  @override
  String get subcategoryServicios => 'Services';

  @override
  String get subcategoryCultura => 'Culture';

  @override
  String get subcategoryReuniones => 'Meetings';

  @override
  String get subcategoryAsambleas => 'Assemblies';

  @override
  String get subcategoryMunicipio => 'Municipality';

  @override
  String get subcategoryUrbanizacion => 'Urbanization';

  @override
  String get searchArticles => 'Search articles...';

  @override
  String get filterByCategory => 'Filter by category';

  @override
  String get articleCreatedSuccess => 'Article created successfully.';

  @override
  String get articleUpdatedSuccess => 'Article updated successfully.';

  @override
  String get articleDeletedSuccess => 'Article deleted successfully.';

  @override
  String get titleRequired => 'Title is required.';

  @override
  String get abstractRequired => 'Abstract is required.';

  @override
  String get coverRequired => 'Cover image is required.';

  @override
  String get categoryRequired => 'Category is required.';

  @override
  String get subcategoryRequired => 'Subcategory is required.';

  @override
  String get publicationDateRequired => 'Publication date is required.';

  @override
  String get effectiveDateRequired => 'Effective date is required.';

  @override
  String get publicationDateInvalid =>
      'Publication date must be today or later.';

  @override
  String get effectiveDateInvalid =>
      'Effective date must be on or after publication date.';

  @override
  String get expirationDateInvalid =>
      'Expiration date must be on or after publication date.';

  @override
  String get sectionContentRequired =>
      'Each section must have content or an image.';

  @override
  String get readMode => 'Read Mode';

  @override
  String get section => 'Section';

  @override
  String get titleCharLimitExceeded => 'Title cannot exceed 100 characters.';

  @override
  String get abstractCharLimitExceeded =>
      'Abstract cannot exceed 200 characters.';

  @override
  String get removeSectionConfirmation =>
      'Are you sure you want to delete this section? This action cannot be undone.';

  @override
  String get previewMode => 'Preview';

  @override
  String get edit => 'Edit';

  @override
  String get draftFoundTitle => 'Draft Found';

  @override
  String get draftFoundMessage =>
      'We found an unsaved draft. Do you want to restore it?';

  @override
  String get discard => 'Discard';

  @override
  String get restore => 'Restore';

  @override
  String get configuration => 'Configuration';

  @override
  String get start => 'from';

  @override
  String get toThe => 'to';

  @override
  String get from => 'from';

  @override
  String get effectivePublishDate => 'Effective date of publication';

  @override
  String get personalData => 'Personal Data';

  @override
  String get emailHint => 'you@email.com';

  @override
  String get passwordMinLength => 'Minimum 6 characters';

  @override
  String get confirmPassword => 'Confirm Password *';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get createNewAssociation => 'Create new association';

  @override
  String get youWillBeAdmin =>
      'You will be the administrator of the association';

  @override
  String get createGeneralAssociation =>
      'Create General Association (SuperAdmin)';

  @override
  String get newAssociationData => 'New Association Data';

  @override
  String get shortNameHint => 'Ex: ASSOC2024';

  @override
  String get longNameHint => 'Ex: Neighbors Association 2024';

  @override
  String get contactEmail => 'Contact Email';

  @override
  String get optionalUseYourEmail => 'Optional (your email will be used)';

  @override
  String get optionalUseYourName => 'Optional (your name will be used)';

  @override
  String get contactPhone => 'Contact Phone';

  @override
  String get optionalUseYourPhone => 'Optional (your phone will be used)';

  @override
  String get noAssociationsAvailableToJoin =>
      'No associations available. You must create a new one.';

  @override
  String get register => 'Register';

  @override
  String get registrationSuccessMessage =>
      'Registration successful. Please check your email to verify your account.';

  @override
  String get genericError => 'A problem occurred while loading the data.';
}
