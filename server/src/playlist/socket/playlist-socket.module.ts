import { FirebaseModule } from 'src/firebase/firebase.module';
import { Global, Module } from '@nestjs/common';
import { FirebaseService } from 'src/firebase/firebase.service';
import { PlaylistSocketService } from './playlist-socket.service';

// @Global()
@Module({
  controllers: [],
  providers: [PlaylistSocketService],
  exports: [PlaylistSocketService],
  imports: [FirebaseModule],
})
export class PlaylistSocketModule {}
