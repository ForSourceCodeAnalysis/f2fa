part of 'deleted_restore_bloc.dart';

sealed class DeletedRestoreEvent {
  const DeletedRestoreEvent();
}

class DeletedRestoreInit extends DeletedRestoreEvent {
  const DeletedRestoreInit();
}

class DeletedRestoreRestore extends DeletedRestoreEvent {
  const DeletedRestoreRestore(this.id);

  final String id;
}

class DeletedRestoreDeletePermanently extends DeletedRestoreEvent {
  const DeletedRestoreDeletePermanently(this.id);

  final String id;
}

class DeletedRestoreClearAll extends DeletedRestoreEvent {
  const DeletedRestoreClearAll();
}
