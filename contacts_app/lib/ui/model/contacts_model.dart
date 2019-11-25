import 'package:contacts_app/data/contact.dart';
import 'package:contacts_app/data/db/contact_dao.dart';
import 'package:scoped_model/scoped_model.dart';

class ContactsModel extends Model {
  // In a more advanced app, we wouldn't instantiate ContactDao
  // directly in ContactsModel class.
  final ContactDao _contactDao = ContactDao();

  // underscore acts like a private access modifier
  List<Contact> _contacts;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // get only property, makes sure that we cannot overwrite contacts
  // from different classes
  List<Contact> get contacts => _contacts;

  Future loadContacts() async {
    _isLoading = true;
    notifyListeners();

    _contacts = await _contactDao.getAllInSortedOrder();
    // As soon as contacts are loaded, let listeners know
    _isLoading = false;
    notifyListeners();
  }

  Future addContact(Contact contact) async {
    await _contactDao.insert(contact);
    await loadContacts();
    notifyListeners();
  }

  Future updateContact(Contact contact) async {
    await _contactDao.update(contact);
    await loadContacts();
    notifyListeners();
  }

  Future deleteContact(Contact contact) async {
    await _contactDao.delete(contact);
    await loadContacts();
    notifyListeners();
  }

  Future changeFavoriteStatus(Contact contact) async {
    contact.isFavorite = !contact.isFavorite;
    await _contactDao.update(contact);
    _contacts = await _contactDao.getAllInSortedOrder();

    notifyListeners();
  }
}
