import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:music_room/src/data/model/return_repository.dart';
import 'package:music_room/src/data/model/room_user.dart';
import 'package:music_room/src/data/repository/playlist_repository.dart';
import 'package:music_room/src/data/repository/room_repository.dart';
import 'package:music_room/utils/utils.dart';

part 'users_settings_event.dart';
part 'users_settings_state.dart';

class UsersSettingsBloc extends Bloc<UsersSettingsEvent, UsersSettingsState> {
  final PlaylistRepository? _playlistRepository;
  final RoomRepository? _roomRepository;
  final String initialInvitationCode;
  final List<RoomUser> initialUsersList;

  UsersSettingsBloc(
      {required RoomRepository? roomRepository,
      required PlaylistRepository? playlistRepository,
      required this.initialInvitationCode,
      required this.initialUsersList})
      : _playlistRepository = playlistRepository,
        _roomRepository = roomRepository,
        super(UsersSettingsState(
          invitationCode: initialInvitationCode,
          listUser: initialUsersList,
        ));

  @override
  Stream<UsersSettingsState> mapEventToState(
    UsersSettingsEvent event,
  ) async* {
    if (event is UpdateInvitationCode) {
      yield await _updateInvitationCode(event.id);
    } else if (event is UpdateUserRole) {
      yield await _updateUserRole(event.id, event.index, event.newRole);
    }
  }

  Future<UsersSettingsState> _updateInvitationCode(String id) async {
    String newCode =
        "${getRandomString(6)}-${getRandomString(4)}-${getRandomString(2)}";
    if (_playlistRepository != null) {
      final ReturnRepository res = await _playlistRepository!
          .updatePlaylist(id, {'invitationCode': newCode}, true);
      if (res.status == false) {
        return (state.copyWith(error: res.message, status: false));
      }
    } else if (_roomRepository != null) {
      final ReturnRepository res = await _roomRepository!
          .updateRoom(id, {'invitationCode': newCode}, true);
      if (res.status == false) {
        return (state.copyWith(error: res.message, status: false));
      }
    }
    return (state.copyWith(invitationCode: newCode));
  }

  Future<UsersSettingsState> _updateUserRole(
      String id, int index, String newRole) async {
    List<RoomUser> newListUser = state.listUser;
    newListUser[index] = state.listUser[index].copyWith(role: newRole);

    final List<Map> test = [];
    for (var e in newListUser) {
      test.add(e.toMap());
    }
    if (_playlistRepository != null) {
      final ReturnRepository res =
          await _playlistRepository!.updatePlaylist(id, {'users': test}, true);
      if (res.status == false) {
        return (state.copyWith(error: res.message, status: false));
      }
    } else if (_roomRepository != null) {
      final ReturnRepository res =
          await _roomRepository!.updateRoom(id, {'users': test}, true);
      if (res.status == false) {
        return (state.copyWith(error: res.message, status: false));
      }
    }
    return (state.copyWith(status: true, listUser: newListUser));
  }
}
