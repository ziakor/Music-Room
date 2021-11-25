import { Module } from '@nestjs/common';
import { RoomService } from './room.service';
import { RoomController } from './room.controller';
import { FirebaseModule } from 'src/firebase/firebase.module';
import { RoomGateway } from './socket/room.gateway';
import { RoomSocketModule } from './socket/room-socket.module';

@Module({
  imports: [FirebaseModule, RoomSocketModule],
  controllers: [RoomController],
  providers: [RoomService, RoomGateway],
})
export class RoomModule {}
