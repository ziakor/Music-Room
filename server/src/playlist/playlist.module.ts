import { Module } from '@nestjs/common';
import { PlaylistService } from './playlist.service';
import { PlaylistController } from './playlist.controller';
import { FirebaseModule } from 'src/firebase/firebase.module';
import { PlaylistSocketModule } from './socket/playlist-socket.module';
import { PlaylistGateway } from './socket/playlist.gateway';

@Module({
  imports: [FirebaseModule, PlaylistSocketModule],
  controllers: [PlaylistController],
  providers: [PlaylistService, PlaylistGateway],
})
export class PlaylistModule {}
