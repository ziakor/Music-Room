import { FirebaseModule } from 'src/firebase/firebase.module';
import { Global, Module } from '@nestjs/common';
import { FirebaseService } from 'src/firebase/firebase.service';
import { RoomSocketService } from './room-socket.service';

// @Global()
@Module({
  controllers: [],
  providers: [RoomSocketService],
  exports: [RoomSocketService],
  imports: [FirebaseModule],
})
export class RoomSocketModule {}
