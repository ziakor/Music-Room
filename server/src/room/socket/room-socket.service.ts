import { Injectable } from '@nestjs/common';
import { Server } from 'socket.io';
import { FirebaseService } from 'src/firebase/firebase.service';
@Injectable()
export class RoomSocketService {
  public socket: Server = null;
  constructor(private readonly firebaseService: FirebaseService) {}

  async updateCurrentMusicOnPlay(
    roomId: string,
    status: boolean,
    userId: string,
  ): Promise<boolean> {
    try {
      let snap: FirebaseFirestore.DocumentData =
        await this.firebaseService.getFirestoreData(roomId, 'Rooms');
      if (snap == undefined) {
        return false;
      } //error
      let elem = snap['users'].find((user) => user.id == userId);
      if (elem.role == 'Admin' || elem.role == 'Modo') {
        await this.firebaseService.updateFirestoreData('Rooms', roomId, {
          currentSong: { onPlay: status },
        });
        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }
  async updateCurrentSongTime(
    roomId: string,
    userId: string,
    time: number,
  ): Promise<boolean> {
    try {
      let snap: FirebaseFirestore.DocumentData =
        await this.firebaseService.getFirestoreData(roomId, 'Rooms');
      if (snap == undefined) {
        return false;
      } //error
      let elem = snap['users'].find((user) => user.id == userId);
      if (elem.role == 'Admin' || elem.role == 'Modo') {
        this.firebaseService.updateFirestoreData('Rooms', roomId, {
          currentSong: { time: time },
        });
        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }

  async updateCurrentSong(
    roomId: string,
    userId: string,
    songName: string,
    songUrl: string,
    songImage: string,
    songAuthor: string,
  ): Promise<any> {
    try {
      let snap: FirebaseFirestore.DocumentData =
        await this.firebaseService.getFirestoreData(roomId, 'Rooms');
      if (snap == undefined) {
        return null;
      } //error
      let userElem = snap['users'].find((user) => user.id == userId);
      if (userElem.role == 'Admin' || userElem.role == 'Modo') {
        let songElem = snap['songs'].find(
          (element) =>
            element.name == songName &&
            element.url == songUrl &&
            element.image == songImage &&
            element.author == songAuthor,
        );
        let previousSongIndex: number = snap['songs'].findIndex(
          (element) =>
            element.name == snap['currentSong'].song.name &&
            element.url == snap['currentSong'].song.url &&
            element.image == snap['currentSong'].song.image &&
            element.author == snap['currentSong'].song.author,
        );
        snap['songs'].splice(previousSongIndex, 1);

        if (songElem == null) {
          songElem = {
            name: songName,
            url: songUrl,
            author: songAuthor,
            image: songImage,
            grade: [],
          };
        }
        this.firebaseService.updateFirestoreData('Rooms', roomId, {
          currentSong: {
            onPlay: songElem.name == '' ? false : true,
            time: 0,
            song: {
              name: songElem.name,
              url: songElem.url,
              author: songElem.author,
              image: songElem.image,
              grade: songElem.grade,
            },
          },
          songs: snap['songs'],
        });
        return songElem;
      }
      return null;
    } catch (error) {
      return null;
    }
  }
  async addSongToWaitingList(
    roomId: string,
    userId: string,
    songName: string,
    songUrl: string,
    songImage: string,
    songAuthor: string,
  ): Promise<boolean> {
    try {
      let snap: FirebaseFirestore.DocumentData =
        await this.firebaseService.getFirestoreData(roomId, 'Rooms');

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

        await this.firebaseService.updateFirestoreData('Rooms', roomId, {
          songs: snap.songs,
        });
        if (snap['currentSong']['song'].name == '') {
          await this.firebaseService.updateFirestoreData('Rooms', roomId, {
            currentSong: {
              song: {
                name: songName,
                url: songUrl,
                author: songAuthor,
                image: songImage,
                grade: [{ fromId: userId, note: 1 }],
              },
            },
          });
        }
        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }

  async handleVotetoSong(
    roomId: string,
    userId: string,
    songName: string,
    songAuthor: string,
    note: number,
  ): Promise<any> {
    //!Change any
    try {
      let snap: FirebaseFirestore.DocumentData =
        await this.firebaseService.getFirestoreData(roomId, 'Rooms');

      if (snap == undefined) {
        return -1;
      }

      const index = snap.songs.findIndex(
        (elem) => elem.name == songName && elem.author == songAuthor,
      );
      if (index == -1) {
        return -1;
      } else {
        let indexVote = snap.songs[index].grade.findIndex(
          (elem) => elem.fromId == userId,
        );
        if (indexVote == -1) {
          snap.songs[index].grade.push({ fromId: userId, note: note });
          indexVote = snap.songs[index].grade.length;
        } else {
          snap.songs[index].grade[indexVote].note = note;
        }
        this.firebaseService.updateFirestoreData('Rooms', roomId, {
          songs: snap.songs,
        });
        return { index: index, voteIndex: indexVote };
      }
    } catch (error) {
      return -1;
    }
  }

  async leave(roomId: string, userId: string): Promise<boolean> {
    try {
      let snap: FirebaseFirestore.DocumentData =
        await this.firebaseService.getFirestoreData(roomId, 'Rooms');
      if (snap == undefined) {
        return false;
      } //error

      let newArray: [] = snap['users'].filter((elem) => elem['id'] != userId);
      snap['users'] = newArray;
      await this.firebaseService.updateFirestoreData('Rooms', roomId, {
        users: newArray,
      });
      return true;
    } catch (error) {
      return false;
    }
  }
}
