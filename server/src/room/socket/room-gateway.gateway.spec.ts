import { Test, TestingModule } from '@nestjs/testing';
import { RoomGateway } from './room.gateway';

describe('RoomGatewayGateway', () => {
  let gateway: RoomGateway;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [RoomGateway],
    }).compile();

    gateway = module.get<RoomGateway>(RoomGateway);
  });

  it('should be defined', () => {
    expect(gateway).toBeDefined();
  });
});
