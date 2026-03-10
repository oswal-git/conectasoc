// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get abstractCharLimitExceeded =>
      'Abstract cannot exceed 200 characters.';

  @override
  String get abstractContent => 'Abstract';

  @override
  String get abstractRequired => 'Abstract is required.';

  @override
  String get accept => 'Accept';

  @override
  String get add => 'Add';

  @override
  String get addMembership => 'Add Membership';

  @override
  String get addMembershipDialogTitle => 'Add Membership';

  @override
  String get addSection => 'Add Section';

  @override
  String get afternoon => 'Afternoon';

  @override
  String get all => 'All';

  @override
  String get appTitle => 'ConectAsoc';

  @override
  String get articleAbstract => 'Article Abstract';

  @override
  String get articleCreatedSuccess => 'Article created successfully.';

  @override
  String get articleDeletedSuccess => 'Article deleted successfully.';

  @override
  String get articleStatus => 'Status';

  @override
  String get articleTitle => 'Article';

  @override
  String get articleUpdatedSuccess => 'Article updated successfully.';

  @override
  String get articles => 'Articles';

  @override
  String get association => 'Association';

  @override
  String get associationDeletedSuccessfully =>
      'Association deleted successfully.';

  @override
  String get associationHasUsersError =>
      'Cannot delete association because it has assigned users.';

  @override
  String get associationIdCannotBeEmpty => 'Association ID cannot be empty.';

  @override
  String get associations => 'Associations';

  @override
  String get associationsListTitle => 'Associations List';

  @override
  String get camera => 'Camera';

  @override
  String get canDownload => 'Allow download';

  @override
  String get cancel => 'Cancel';

  @override
  String get category => 'Category';

  @override
  String get categoryActas => 'Minutes';

  @override
  String get categoryInformacion => 'Information';

  @override
  String get categoryNoticias => 'News';

  @override
  String get categoryRequired => 'Category is required.';

  @override
  String get changeAssociation => 'Change Association';

  @override
  String get changesSavedSuccessfully => 'Changes saved successfully';

  @override
  String get configuration => 'Configuration';

  @override
  String get confirmPassword => 'Confirm Password *';

  @override
  String get confirmSave => 'Confirm save';

  @override
  String get confirmSaveMessage => 'Are you sure you want to save the changes?';

  @override
  String get contact => 'Contact';

  @override
  String get contactEmail => 'Contact Email';

  @override
  String get contactName => 'Contact name';

  @override
  String get contactPerson => 'Contact person';

  @override
  String get contactPhone => 'Contact Phone';

  @override
  String get continueEditing => 'Continue editing';

  @override
  String get coverImage => 'Cover Image';

  @override
  String get coverRequired => 'Cover image is required.';

  @override
  String get createAccount => 'Create Account';

  @override
  String get createArticle => 'Create Article';

  @override
  String get createAssociation => 'Create Association';

  @override
  String get createGeneralAssociation =>
      'Create General Association (SuperAdmin)';

  @override
  String get createNewAssociation => 'Create new association';

  @override
  String get createUser => 'Create User';

  @override
  String get cropImage => 'Crop Image';

  @override
  String get delete => 'Delete';

  @override
  String get deleteArticle => 'Delete Article';

  @override
  String get deleteAssociation => 'Delete Association';

  @override
  String deleteAssociationConfirmation(Object associationName) {
    return 'Are you sure you want to delete the association \'$associationName\'? This action cannot be undone.';
  }

  @override
  String get deleteUser => 'Delete User';

  @override
  String deleteUserConfirmation(String userName) {
    return 'Are you sure you want to delete $userName? This action is irreversible.';
  }

  @override
  String get discard => 'Discard';

  @override
  String get discardChanges => 'Discard changes';

  @override
  String get documentDescription => 'Document description';

  @override
  String get documentDescriptionHint =>
      'Describe the document content (maximum 200 characters)';

  @override
  String get documentDetails => 'Document details';

  @override
  String get documentIncompatible =>
      'A section cannot have both a document and content (image/text)';

  @override
  String get documentList => 'Document list';

  @override
  String get documentNotAvailable => 'Document not available';

  @override
  String get documentUploaded => 'Document uploaded successfully';

  @override
  String get documents => 'Documents';

  @override
  String get downloadDocument => 'Download document';

  @override
  String get draftFoundMessage =>
      'We found an unsaved draft. Do you want to restore it?';

  @override
  String get draftFoundTitle => 'Draft Found';

  @override
  String get edit => 'Edit';

  @override
  String get editArticle => 'Edit Article';

  @override
  String get editMode => 'Edit Mode';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get editUser => 'Edit User';

  @override
  String get effectiveDateInvalid =>
      'Effective date must be on or after publication date.';

  @override
  String get effectiveDateLabel => 'Effective Date';

  @override
  String get effectiveDateRequired => 'Effective date is required.';

  @override
  String get effectivePublishDate => 'Effective date of publication';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'you@email.com';

  @override
  String errorLoadingAssociations(Object error) {
    return 'Error loading associations: $error';
  }

  @override
  String errorResendingEmail(Object error) {
    return 'Error resending email: $error';
  }

  @override
  String get errorUploadingLogo => 'Error uploading logo';

  @override
  String get exitReadOnlyMode => 'Exit Read-Only Mode';

  @override
  String get expirationDateInvalid =>
      'Expiration date must be on or after publication date.';

  @override
  String get expirationDateLabel => 'Expiration Date (optional)';

  @override
  String get fileSize => 'File size';

  @override
  String get filter => 'Filter';

  @override
  String get filterByCategory => 'Filter by category';

  @override
  String get from => 'from';

  @override
  String get gallery => 'Gallery';

  @override
  String get genericError => 'A problem occurred while loading the data.';

  @override
  String get homePage => 'Home';

  @override
  String get incompleteAssociationData => 'New association data is incomplete.';

  @override
  String get invalidEmailFormat => 'Invalid email format.';

  @override
  String get joinAssociation => 'Join Association';

  @override
  String get langCatalan => 'Català';

  @override
  String get langEnglish => 'English';

  @override
  String get langSpanish => 'Español';

  @override
  String get language => 'Language';

  @override
  String get lastname => 'Last Name';

  @override
  String get leave => 'Leave';

  @override
  String get leaveAssociation => 'Leave Association';

  @override
  String leaveAssociationConfirmationMessage(Object associationName) {
    return 'Are you sure you want to leave the association \'$associationName\'? This action cannot be undone.';
  }

  @override
  String get leaveAssociationConfirmationTitle => 'Confirm Leave';

  @override
  String get leaveWithoutSaving => 'Leave Without Saving';

  @override
  String get linkDocument => 'Link document';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Log Out';

  @override
  String get longName => 'Long name';

  @override
  String get longNameHint => 'Ex: Neighbors Association 2024';

  @override
  String get memberships => 'Memberships';

  @override
  String get morning => 'Morning';

  @override
  String get morningAndAfternoon => 'Morning and Afternoon';

  @override
  String get mustSelectAnAssociation =>
      'You must select an association to join.';

  @override
  String get myProfile => 'My Profile';

  @override
  String get name => 'Name';

  @override
  String get never => 'Never';

  @override
  String get newAssociationData => 'New Association Data';

  @override
  String get noArticlesYet => 'No articles yet.';

  @override
  String get noAssociationAvailable => 'No association available';

  @override
  String get noAssociationsAvailableToJoin =>
      'No associations available. You must create a new one.';

  @override
  String get noChangesToSave => 'Nothing modified to save';

  @override
  String get noDocumentsFound => 'No documents found';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get notificationFreqNone => 'No notifications';

  @override
  String get notificationFreqOnce => 'Once a day (12:00)';

  @override
  String get notificationFreqThrice =>
      'Three times a day (10:00, 15:00, 20:00)';

  @override
  String get notificationFreqTwice => 'Twice a day (10:00 and 20:00)';

  @override
  String get notifications => 'Notifications';

  @override
  String get optionalUseYourEmail => 'Optional (your email will be used)';

  @override
  String get optionalUseYourName => 'Optional (your name will be used)';

  @override
  String get optionalUseYourPhone => 'Optional (your phone will be used)';

  @override
  String get password => 'Password';

  @override
  String get passwordMinLength => 'Minimum 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get personalData => 'Personal Data';

  @override
  String get phone => 'Phone';

  @override
  String get preview => 'Preview Article';

  @override
  String get previewMode => 'Preview';

  @override
  String get profileLoadError => 'Error loading profile.';

  @override
  String get profileSavedSuccess => 'Profile saved successfully';

  @override
  String get publicationDateInvalid =>
      'Publication date must be today or later.';

  @override
  String get publicationDateRequired => 'Publication date is required.';

  @override
  String get publishDateLabel => 'Publication Date';

  @override
  String get readMode => 'Read Mode';

  @override
  String get readScope => 'Read scope';

  @override
  String get readScopeAdmin => 'Admin and above';

  @override
  String get readScopeAdminHelp =>
      'Visible to superadmin and association admin';

  @override
  String get readScopeAsociado => 'All association members';

  @override
  String get readScopeAsociadoHelp => 'Visible to all association members';

  @override
  String get readScopeEditor => 'Editor and above';

  @override
  String get readScopeEditorHelp => 'Visible to superadmin, admin and editors';

  @override
  String get readScopeSuperadmin => 'Superadmin only';

  @override
  String get readScopeSuperadminHelp => 'Visible only to superadmin';

  @override
  String get register => 'Register';

  @override
  String get registrationError => 'Registration Error';

  @override
  String get registrationSuccessMessage =>
      'Registration successful. Please check your email to verify your account.';

  @override
  String get removeDocumentLink => 'Remove document link';

  @override
  String get removeSection => 'Remove Section';

  @override
  String get removeSectionConfirmation =>
      'Are you sure you want to delete this section? This action cannot be undone.';

  @override
  String get reorderSections => 'Reorder Sections';

  @override
  String get requiredField => 'Required field';

  @override
  String get resendEmail => 'Resend email';

  @override
  String get restore => 'Restore';

  @override
  String get retry => 'Retry';

  @override
  String role(Object roleName) {
    return 'Role: $roleName';
  }

  @override
  String get roleTitle => 'Role';

  @override
  String get save => 'Save';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get search => 'Search...';

  @override
  String get searchArticles => 'Search articles...';

  @override
  String get searchDocument => 'Search document';

  @override
  String get section => 'Section';

  @override
  String get sectionContentRequired =>
      'Each section must have content or an image.';

  @override
  String get sections => 'Sections';

  @override
  String get selectAssociation => 'Select association';

  @override
  String get selectCoverImage => 'Select Cover Image';

  @override
  String get selectDocument => 'Select document';

  @override
  String get shortAndLongNameRequired =>
      'Short name and long name are required.';

  @override
  String get shortName => 'Short name';

  @override
  String get shortNameHint => 'Ex: ASSOC2024';

  @override
  String get start => 'from';

  @override
  String get status => 'Status';

  @override
  String get statusAnulado => 'Cancelled';

  @override
  String get statusExpirado => 'Expired';

  @override
  String get statusNotificar => 'Publish and Notify';

  @override
  String get statusNotificarShort => 'Notify';

  @override
  String get statusPublicado => 'Published';

  @override
  String get statusRedaccion => 'Draft';

  @override
  String get statusRevision => 'In Review';

  @override
  String get stay => 'Stay';

  @override
  String get subcategory => 'Subcategory';

  @override
  String get subcategoryAsambleas => 'Assemblies';

  @override
  String get subcategoryCultura => 'Culture';

  @override
  String get subcategoryMunicipio => 'Municipality';

  @override
  String get subcategoryRequired => 'Subcategory is required.';

  @override
  String get subcategoryReuniones => 'Meetings';

  @override
  String get subcategoryServicios => 'Services';

  @override
  String get subcategoryUrbanizacion => 'Urbanization';

  @override
  String get title => 'Title';

  @override
  String get titleCharLimitExceeded => 'Title cannot exceed 100 characters.';

  @override
  String get titleRequired => 'Title is required.';

  @override
  String get toThe => 'to';

  @override
  String get undo => 'Undo';

  @override
  String get unexpectedError => 'An unexpected error occurred.';

  @override
  String unexpectedErrorOcurred(Object error) {
    return 'An unexpected error occurred: $error';
  }

  @override
  String get unknownAssociation => 'Unknown Association';

  @override
  String get unsavedChanges => 'Unsaved changes';

  @override
  String get unsavedChangesMessage =>
      'You have unsaved changes. Do you want to leave without saving?';

  @override
  String get unsavedChangesTitle => 'Unsaved Changes';

  @override
  String get uploadDocuments => 'Upload documents';

  @override
  String get uploadNewDocument => 'Upload new document';

  @override
  String get uploadedBy => 'Uploaded by';

  @override
  String get uploadDateFormat => 'MMMM d\',\' y \'at\' HH:mm:ss';

  @override
  String userDeleted(Object userName) {
    return 'User $userName deleted';
  }

  @override
  String get userHasNoMemberships =>
      'This user does not belong to any association.';

  @override
  String get users => 'Users';

  @override
  String get usersListTitle => 'Users List';

  @override
  String get verificationEmailSent => 'Verification email resent.';

  @override
  String get verifyEmailHeadline => 'Verify your email address';

  @override
  String verifyEmailInstruction(Object email) {
    return 'We have sent a verification email to $email. Please check your inbox and follow the instructions to activate your account.';
  }

  @override
  String get verifyEmailTitle => 'Verify Email';

  @override
  String get viewDocument => 'View document';

  @override
  String get welcomeLoginDescription => 'I already have an account';

  @override
  String get welcomeLoginTitle => 'Log In';

  @override
  String get welcomeReadOnlyDescription =>
      'Explore content without registration';

  @override
  String get welcomeReadOnlyTitle => 'Read Only';

  @override
  String get welcomeRegisterDescription =>
      'Full registration with notifications';

  @override
  String get welcomeSubtitle => 'Associations Portal';

  @override
  String get youWillBeAdmin =>
      'You will be the administrator of the association';
}
