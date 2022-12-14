import 'package:flutter_contacts/flutter_contacts.dart' show FlutterContacts;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_clone/shared/repositories/firebase_firestore.dart';
import 'package:whatsapp_clone/shared/models/contact.dart';
import 'package:whatsapp_clone/shared/models/user.dart';

final contactsRepositoryProvider = Provider((ref) => ContactsRepository(ref));

class ContactsRepository {
  final ProviderRef ref;

  ContactsRepository(this.ref);

  Future<void> openContacts() async {
    // For now
    FlutterContacts.openExternalPick();
  }

  Future<void> createNewContact() async {
    FlutterContacts.openExternalInsert();
  }

  Future<Contact?> getContactByPhone(String phoneNumber) async {
    if (!await Permission.contacts.isGranted) return null;

    final contacts = await FlutterContacts.getContacts(withProperties: true);

    for (var contact in contacts) {
      for (var phone in contact.phones) {
        String phoneNumberWithoutFormatting = phone.number
            .replaceAll(' ', '')
            .replaceAll('-', '')
            .replaceAll('(', '')
            .replaceAll(')', '');

        if (phoneNumberWithoutFormatting.contains(phoneNumber)) {
          return Contact(name: contact.displayName, phoneNumber: phoneNumber);
        }
      }
    }

    return null;
  }

  Future<Map<String, List<Contact>>> getContacts({required User self}) async {
    Map<String, List<Contact>> res = {'onWhatsApp': [], 'notOnWhatsApp': []};

    final contacts = await FlutterContacts.getContacts(withProperties: true);
    final firestoreRepo = ref.read(firebaseFirestoreRepositoryProvider);

    for (var contact in contacts) {
      for (var phone in contact.phones) {
        User? user = await firestoreRepo.getUserByPhone(phone.number);
        if (user != null && user.id != self.id) {
          res['onWhatsApp']!.add(
            Contact(
              name: contact.displayName,
              id: user.id,
              phoneNumber: phone.number,
              avatarUrl: user.avatarUrl,
            ),
          );
        } else {
          res['notOnWhatsApp']!.add(
            Contact(
              name: contact.displayName,
              phoneNumber: phone.number,
            ),
          );
        }
      }
    }

    return res;
  }
}
