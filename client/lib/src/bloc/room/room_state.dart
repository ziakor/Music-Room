part of 'room_bloc.dart';

class RoomState extends Equatable {
  final List<Room> listRooms;
  final Room currentRoom;
  final Room newRoom;
  final bool status;
  final String error;
  RoomState({
    this.listRooms = const [],
    this.currentRoom = const Room(),
    this.newRoom = const Room(),
    this.error = "",
    this.status = false,
  });
  bool get creationSuccess =>
      newRoom.isNotEmpty == true && status == true && error.isEmpty;
  bool get creationFailed =>
      newRoom.isNotEmpty == true && status == false && error.isNotEmpty;

  RoomState copyWith({
    List<Room>? listRooms,
    Room? currentRoom,
    Room? newRoom,
    bool? roomCreation,
    bool? status,
    String? error,
  }) {
    return RoomState(
      listRooms: listRooms ?? this.listRooms,
      currentRoom: currentRoom ?? this.currentRoom,
      newRoom: newRoom ?? this.newRoom,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  List<Object> get props => [
        listRooms,
        currentRoom,
        newRoom,
        status,
        error,
      ];
}
