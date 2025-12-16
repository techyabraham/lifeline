// lib/blocs/contacts/contacts_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/contacts_repository.dart';
import '../../models/emergency_contact.dart';

/// ----------------------------
/// EVENTS
/// ----------------------------
abstract class ContactsEvent {}

class LoadContacts extends ContactsEvent {
  final int? categoryId;
  final int? stateId;
  final int? lgaId;

  LoadContacts({
    this.categoryId,
    this.stateId,
    this.lgaId,
  });
}

/// ----------------------------
/// STATES
/// ----------------------------
abstract class ContactsState {}

class ContactsInitial extends ContactsState {}

class ContactsLoading extends ContactsState {}

class ContactsLoaded extends ContactsState {
  final List<EmergencyContact> contacts;

  ContactsLoaded(this.contacts);
}

class ContactsEmpty extends ContactsState {}

class ContactsError extends ContactsState {
  final String message;

  ContactsError(this.message);
}

/// ----------------------------
/// BLOC
/// ----------------------------
class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final ContactsRepository repository;

  ContactsBloc({required this.repository}) : super(ContactsInitial()) {
    on<LoadContacts>(_onLoadContacts);
  }

  Future<void> _onLoadContacts(
    LoadContacts event,
    Emitter<ContactsState> emit,
  ) async {
    emit(ContactsLoading());

    try {
      final contacts = await repository.getContacts(
        categoryId: event.categoryId,
        stateId: event.stateId,
        lgaId: event.lgaId,
      );

      if (contacts.isEmpty) {
        emit(ContactsEmpty());
      } else {
        emit(ContactsLoaded(contacts));
      }
    } catch (e) {
      emit(ContactsError('Failed to load emergency contacts'));
    }
  }
}
