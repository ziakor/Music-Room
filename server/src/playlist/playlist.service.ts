import { LeavePlaylistDto } from './dto/leave-playlist.dto';
import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { FirebaseService } from 'src/firebase/firebase.service';
import { JoinInvitedPlaylistDto } from './dto/join-invited-playlist.dto';
import { JoinPlaylistDto } from './dto/join-playlist.dto';

@Injectable()
export class PlaylistService {
  constructor(private readonly firebaseService: FirebaseService) {}

  async join(data: JoinPlaylistDto, playlistId: string, userId: string) {
    try {
      let snap: FirebaseFirestore.DocumentData =
        await this.firebaseService.getFirestoreData(playlistId, 'Playlist');
      if (snap == undefined) {
        throw new HttpException('invalid playlist id.', HttpStatus.BAD_REQUEST);
      } //error
      snap['users'].push({
        role: snap['creatorId'] == userId ? 'Admin' : 'User',
        pseudo: data.pseudo,
        id: userId,
        isInvited: false,
      });
      await this.firebaseService.updateFirestoreData('Playlist', playlistId, {
        users: snap['users'],
      });
      return snap;
    } catch (error) {
      throw new HttpException(error, HttpStatus.BAD_REQUEST);
    }
  }

  async joinInvited(data: JoinInvitedPlaylistDto, userId: string) {
    try {
      let snap: FirebaseFirestore.DocumentData =
        await this.firebaseService.getFirestoreDocumentWhere(
          'Playlist',
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
      await this.firebaseService.updateFirestoreData('Playlist', snap['id'], {
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
        await this.firebaseService.getFirestoreData(roomId, 'Playlist');
      if (snap == undefined) {
        throw new HttpException('invalid room id.', HttpStatus.BAD_REQUEST);
      } //error

      let newArray: [] = snap['users'].filter((elem) => elem['id'] != userId);
      snap['users'] = newArray;
      await this.firebaseService.updateFirestoreData('Playlist', roomId, {
        users: newArray,
      });
      return snap;
    } catch (error) {
      throw new HttpException(error, HttpStatus.BAD_REQUEST);
    }
  }
}
