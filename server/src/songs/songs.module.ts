import { Module } from '@nestjs/common';
import { SongsService } from './songs.service';
import { SongsController } from './songs.controller';
import { FirebaseModule } from 'src/firebase/firebase.module';
import { SpotifyModule } from 'src/spotify/spotify.module';

@Module({
	imports:[FirebaseModule, SpotifyModule],
  controllers: [SongsController],
  providers: [SongsService]
})
export class SongsModule {}
