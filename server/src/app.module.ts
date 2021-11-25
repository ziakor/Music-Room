import { Module } from '@nestjs/common';

import { ConfigModule } from '@nestjs/config';
import { UsersModule } from './users/users.module';
import { PlaylistModule } from './playlist/playlist.module';
import { RoomModule } from './room/room.module';
import { SongsModule } from './songs/songs.module';
import { SpotifyModule } from './spotify/spotify.module';
import { RoomSocketModule } from './room/socket/room-socket.module';
import { RoomGateway } from './room/socket/room.gateway';
import { LogModule } from './log/log.module';

@Module({
  imports: [
    ConfigModule.forRoot({ envFilePath: './config/.env' }),
    UsersModule,
    PlaylistModule,
    RoomModule,
    SongsModule,
    LogModule,
  ],
})
export class AppModule {}
