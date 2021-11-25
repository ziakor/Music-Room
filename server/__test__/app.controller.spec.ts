import { Test, TestingModule } from '@nestjs/testing';
import { UsersModule } from 'src/users/users.module';

describe('UsersModule', () => {
  let userModule: UsersModule;

  beforeEach(async () => {
    const app: TestingModule = await Test.createTestingModule({
      imports: [UsersModule],
    }).compile();

    userModule = app.get<UsersModule>(UsersModule);
  });

  describe('root', () => {
    it('user module should be defined', () => {
      expect(userModule).toBeDefined();
    });
  });
});
