import { Injectable } from '@nestjs/common';
import { Server } from 'socket.io';
import { FirebaseService } from 'src/firebase/firebase.service';
@Injectable()
export class PlaylistSocketService {
  public socket: Server = null;
  constructor(private readonly firebaseService: FirebaseService) {}

  async addSongToWaitingList(
    playlistId: string,
    userId: string,
    songName: string,
    songUrl: string,
    songImage: string,
    songAuthor: string,
  ): Promise<boolean> {
    try {
      let snap: FirebaseFirestore.DocumentData =
        await this.firebaseService.getFirestoreData(playlistId, 'Playlist');

      if (snap == undefined) {
        return false;
      }

      if (
        snap.songs.find(
          (elem: {
            name: string;
            url: string;
            author: string;
            image: string;
          }) =>
            elem.name == songName &&
            elem.url == songUrl &&
            elem.author == songAuthor &&
            elem.image == songImage,
        ) == undefined
      ) {
        snap.songs.push({
          name: songName,
          url: songUrl,
          author: songAuthor,
          image: songImage,
          grade: [{ fromId: userId, note: 1 }],
        });

        await this.firebaseService.updateFirestoreData('Playlist', playlistId, {
          songs: snap.songs,
        });

        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }

  async leave(playlistId: string, userId: string): Promise<boolean> {
    try {
      let snap: FirebaseFirestore.DocumentData =
        await this.firebaseService.getFirestoreData(playlistId, 'Playlist');
      if (snap == undefined) {
        return false;
      } //error

      let newArray: [] = snap['users'].filter((elem) => elem['id'] != userId);
      snap['users'] = newArray;
      await this.firebaseService.updateFirestoreData('Playlist', playlistId, {
        users: newArray,
      });
      return true;
    } catch (error) {
      return false;
    }
  }
}
