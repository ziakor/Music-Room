import { Test, TestingModule } from '@nestjs/testing';
import { FirebaseModule } from 'src/firebase/firebase.module';
import { FirebaseService } from 'src/firebase/firebase.service';
import { MailModule } from 'src/mail/mail.module';
import { MailService } from 'src/mail/mail.service';
import { UsersController } from './users.controller';
import { auth, firestore } from 'firebase-admin';

import { UsersService } from './users.service';
import { HttpException, HttpStatus } from '@nestjs/common';
import { mocked } from 'ts-jest/utils';
jest.mock('src/firebase/firebase.service');
jest.mock('src/mail/mail.service');
describe('UsersController', () => {
  let service: UsersService;
  let firebaseService: FirebaseService;
  let mailService: MailService;
  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      imports: [FirebaseModule, MailModule],
      providers: [UsersService],
    }).compile();

    service = module.get<UsersService>(UsersService);
    firebaseService = module.get<FirebaseService>(FirebaseService);
    mailService = module.get<MailService>(MailService);
  });
  afterEach(async () => {
    jest.resetAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('forgetPassword', () => {
    it('should return normally', async () => {
      mocked(firebaseService.getAuthUserWithEmail).mockResolvedValue({
        uid: 'some-uid',
      } as unknown as Promise<auth.UserRecord>);
      mocked(firebaseService.updateFirestoreUser).mockResolvedValue();
      mocked(mailService.sendEmail).mockResolvedValue();

      const res = await service.forgetPassword('dimitrihauet@gmail.com');
      expect(res).toEqual({ message: 'code generated', data: {} });
    });
    it('should throw an error', async () => {
      mocked(firebaseService.getAuthUserWithEmail).mockResolvedValue({
        uid: 'some-uid',
      } as unknown as Promise<auth.UserRecord>);
      mocked(firebaseService.updateFirestoreUser).mockResolvedValue();
      mocked(mailService.sendEmail).mockRejectedValueOnce('Server error');

      await expect(
        service.forgetPassword('dimitrihauet@gmail.com'),
      ).rejects.toThrowError('Server error');
    });
  });
  describe('forgetPasswordCode', () => {
    const code = 'abcdef';
    const email = 'dimitrihauet@gmail.com';
    const password = 'Abcdefghj42@';
    it('should return normally and update password', async () => {
      mocked(firebaseService.getAuthUserWithEmail).mockResolvedValue({
        uid: 'some-uid',
      } as unknown as Promise<auth.UserRecord>);
      mocked(firebaseService.getFirebaseUserData).mockResolvedValueOnce({
        code: 'abcdef',
      });
      const res = await service.forgetPasswordCode(email, code, password);
      expect(res).toEqual({ message: 'password updated', data: {} });
    });
    it('should throw an error password invalid', async () => {
      mocked(firebaseService.getAuthUserWithEmail).mockResolvedValue({
        uid: 'some-uid',
      } as unknown as Promise<auth.UserRecord>);
      mocked(firebaseService.getFirebaseUserData).mockResolvedValueOnce({
        code: 'abcdef',
      });
      await expect(
        service.forgetPasswordCode(email, code, 'abcdef'),
      ).rejects.toThrowError("This password doesn't fill all requirements.");
    });
    it('should throw error code doesnt match', async () => {
      mocked(firebaseService.getAuthUserWithEmail).mockResolvedValue({
        uid: 'some-uid',
      } as unknown as Promise<auth.UserRecord>);
      mocked(firebaseService.getFirebaseUserData).mockResolvedValueOnce({
        code: 'abcdef',
      });
      await expect(
        service.forgetPasswordCode(email, 'asd1485', password),
      ).rejects.toThrowError('Invalid code.');
    });
  });
});
