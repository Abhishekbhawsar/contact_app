class AppStrings {
  const AppStrings._();

  static const String appName = 'Contacts';
  static const String contactsCollection = 'contacts';

  static const String firebaseNotConfiguredTitle = 'Firebase is not configured';
  static const String firebaseNotConfiguredMessage =
      'Run flutterfire configure, select your Firebase project, then restart the app.';

  static const String yourInternetIsOff = 'Your internet is off';
  static const String offlineSemanticMessage =
      'Your internet is off. Contacts cannot sync right now.';
  static const String offlineScreenMessage =
      'Please connect to Wi-Fi or mobile data to sync and manage contacts.';
  static const String offlineSnackbarMessage =
      'Your internet is off. Please connect to the internet and try again.';

  static const String refreshContacts = 'Refresh contacts';
  static const String searchContacts = 'Search contacts';
  static const String clearSearch = 'Clear search';
  static const String addContactTooltip = 'Add contact';
  static const String add = 'Add';
  static const String favorites = 'Favorites';

  static const String unableToLoadContacts = 'Unable to load contacts';
  static const String noContactsYet = 'No contacts yet';
  static const String noMatchingContacts = 'No matching contacts';
  static const String addContactEmptyMessage = 'Add a contact to see it here in real time.';
  static const String searchEmptyMessage = 'Try searching by name, phone, email, or company.';
  static const String noFavoritesYet = 'No favorites yet';
  static const String noFavoritesMessage = 'Star important people to keep them close at hand.';

  static const String addContact = 'Add contact';
  static const String editContact = 'Edit contact';
  static const String fullName = 'Full name';
  static const String phoneNumber = 'Phone number';
  static const String emailAddress = 'Email address';
  static const String company = 'Company';
  static const String address = 'Address';
  static const String notes = 'Notes';
  static const String favorite = 'Favorite';
  static const String favoriteSubtitle = 'Show this contact on the Favorites tab';
  static const String createContact = 'Create contact';
  static const String saveChanges = 'Save changes';
  static const String contactAdded = 'Contact added.';
  static const String contactUpdated = 'Contact updated.';
  static const String saveTimedOut = 'Save timed out. Check Firebase setup and internet.';
  static const String couldNotSaveContact = 'Could not save contact. Check Firebase setup.';
  static const String addContactHeader = 'Create new Contact';
  static const String editContactHeader = 'Keep contact details accurate.';

  static const String contactNotFound = 'Contact not found';
  static const String contactNotFoundMessage = 'This contact may have been deleted.';
  static const String contactDetails = 'Contact details';
  static const String addToFavorites = 'Add to favorites';
  static const String removeFromFavorites = 'Remove from favorites';
  static const String couldNotStartCall = 'Could not start a call.';
  static const String phone = 'Phone';
  static const String email = 'Email';
  static const String deleteContactQuestion = 'Delete contact?';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String contactDeleted = 'Contact deleted.';
  static const String couldNotDeleteContact = 'Could not delete contact.';
  static const String call = 'Call';
  static const String edit = 'Edit';

  static const String nameRequired = 'Full name is required';
  static const String phoneRequired = 'Phone number is required';
  static const String validPhoneRequired = 'Enter a valid phone number';
  static const String validEmailRequired = 'Enter a valid email address';
  static const String firestoreTimeout =
      'Firestore request timed out. Check Firebase setup and internet connection.';

  static String avatarLabel(String name) => '$name avatar';
  static String openContactLabel(String name) => 'Open $name';
  static String callContactLabel(String name) => 'Call $name';
  static String deleteContactMessage(String name) => 'This will permanently delete $name.';
}
