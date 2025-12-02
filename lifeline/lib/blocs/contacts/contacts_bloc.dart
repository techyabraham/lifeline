import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/contacts_repository.dart';
import '../../models/contact_model.dart';

// Events
abstract class ContactsEvent {}
class LoadContacts extends ContactsEvent {
  final String lga;
  LoadContacts(this.lga);
}

// States
abstract class ContactsState {}
class ContactsInitial extends ContactsState {}
class ContactsLoading extends ContactsState {}
class ContactsLoaded extends ContactsState {
  final List<ContactModel> contacts;
  ContactsLoaded(this.contacts);
}
class ContactsError extends ContactsState {
  final String message;
  ContactsError(this.message);
}

// Bloc
class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final ContactsRepository repository;

  ContactsBloc({required this.repository}) : super(ContactsInitial()) {
    on<LoadContacts>((event, emit) async {
      emit(ContactsLoading());
      try {
        final contacts = await repository.getContacts(lga: event.lga);
        emit(ContactsLoaded(contacts));
      } catch (e) {
        emit(ContactsError('Failed to load contacts'));
      }
    });
  }
}
