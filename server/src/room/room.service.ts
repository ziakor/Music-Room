import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { GeoPoint } from 'firebase-admin/firestore';
import { FirebaseService } from 'src/firebase/firebase.service';
import { JoinInvitedRoomDto } from './dto/join-invited-room.dto';
import { JoinRoomDto } from './dto/join-room.dto';
import { LeaveRoomDto } from './dto/leave-room.dto';
import { RoomSocketService } from './socket/room-socket.service';

@Injectable()
export class RoomService {
  constructor(
    private readonly firebaseService: FirebaseService,
    private readonly roomSocketService: RoomSocketService,
  ) {}

  async join(data: JoinRoomDto, roomId: string, userId: string) {
    try {
      let snap: FirebaseFirestore.DocumentData =
        await this.firebaseService.getFirestoreData(roomId, 'Rooms');
      if (snap == undefined) {
        throw new HttpException('invalid room id.', HttpStatus.BAD_REQUEST);
      } //error
      snap['users'].push({
        role: snap['creatorId'] == userId ? 'Admin' : 'User',
        pseudo: data.pseudo,
        id: userId,
        isInvited: false,
      });
      await this.firebaseService.updateFirestoreData('Rooms', roomId, {
        users: snap['users'],
      });
      return snap;
    } catch (error) {
      throw new HttpException(error, HttpStatus.BAD_REQUEST);
    }
  }

  async joinInvited(data: JoinInvitedRoomDto, userId: string) {
    try {
      let snap: FirebaseFirestore.DocumentData =
        await this.firebaseService.getFirestoreDocumentWhere(
          'Rooms',
          'invitationCode',
          data.invitationCode,
        );

      if (snap == undefined) {
        return { id: '', data: {} };
      }
      snap['data']['users'].push({
        role: snap['creatorId'] == userId ? 'Admin' : 'User',
        pseudo: data.pseudo,
        id: userId,
        isInvited: true,
      });
      await this.firebaseService.updateFirestoreData('Rooms', snap['id'], {
        users: snap['data']['users'],
      });

      return snap;
    } catch (error) {
      throw new HttpException(error, HttpStatus.BAD_REQUEST);
    }
  }
  async leave(roomId: string, userId: string) {
    try {
      let snap: FirebaseFirestore.DocumentData =
        await this.firebaseService.getFirestoreData(roomId, 'Rooms');
      if (snap == undefined) {
        throw new HttpException('invalid room id.', HttpStatus.BAD_REQUEST);
      } //error

      let newArray: [] = snap['users'].filter((elem) => elem['id'] != userId);
      snap['users'] = newArray;
      await this.firebaseService.updateFirestoreData('Rooms', roomId, {
        users: newArray,
      });
      return snap;
    } catch (error) {
      throw new HttpException(error, HttpStatus.BAD_REQUEST);
    }
  }
}
