import { Test, TestingModule } from '@nestjs/testing';
import { RoomSocketService } from './room-socket.service';

describe('RoomSocketService', () => {
  let service: RoomSocketService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [RoomSocketService],
    }).compile();

    service = module.get<RoomSocketService>(RoomSocketService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
