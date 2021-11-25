import { Test, TestingModule } from '@nestjs/testing';
import { FirebaseService } from './firebase.service';
import admin, { auth, firestore } from 'firebase-admin';
import { mocked } from 'ts-jest/utils';
jest.mock('firebase-admin', () => ({
  firestore: jest.fn(() => ({
    collection: (path) => ({
      doc: (uid) => ({
        get: jest.fn(() =>
          Promise.resolve({ data: () => ({ code: 'abcdef' }) }),
        ),
        update: () => Promise.resolve({ data: () => ({ code: 'abcdef' }) }),
      }),
    }),
  })),
  auth: jest.fn(() => ({
    getUserByEmail: () => ({
      uid: 'some-uid',
    }),
    updateUser: () => (uid, data) => {
      throw new Error('qwd');
    },
  })),
}));
describe('FirebaseService', () => {
  let service: FirebaseService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [FirebaseService],
    }).compile();
    service = module.get<FirebaseService>(FirebaseService);
  });

  // it('should be defined', () => {
  //   expect(service).toBeDefined();
  // });

  describe('getAuthUserWithEmail', () => {
    const email = 'test@gmail.com';

    it('should find a user', async () => {
      return await expect(
        service.getAuthUserWithEmail(email),
      ).resolves.not.toThrow();
    });
    it('should throw an error', async () => {
      (auth as unknown as jest.Mock).mockImplementationOnce(() => ({
        getUserByEmail: () => {
          throw new Error('Error');
        },
      }));
      return expect(service.getAuthUserWithEmail(email)).rejects.toThrow(
        'Error',
      );
    });
  });

  describe('getFirebaseUserData', () => {
    const uid = 'some-uid';
    it('should return user data', async () => {
      return expect(service.getFirebaseUserData(uid)).resolves.not.toThrow();
    });
    it('should throw an error', async () => {
      (firestore as unknown as jest.Mock).mockImplementationOnce(() => ({
        collection: (path) => {
          throw new Error('Error');
        },
      }));
      return expect(service.getFirebaseUserData(uid)).rejects.toThrow('Error');
    });
  });

  describe('updateAuthUser', () => {
    it('should update the user', async () => {
      (auth as unknown as jest.Mock).mockImplementationOnce(() => ({
        updateUser: (_, __) => ({
          uid: 'some-uid',
        }),
      }));
      return expect(
        service.updateAuthUser('uid', { email: 'new-email' }),
      ).resolves.not.toThrow();
    });
    it('should throw an error', async () => {
      (auth as unknown as jest.Mock).mockImplementationOnce(() => ({
        updateUser: (_, __) => {
          throw new Error('Error');
        },
      }));

      return expect(
        service.updateAuthUser('uid', { email: 'new-email' }),
      ).rejects.toThrow();
    });
  });
  describe('updateFirestoreUser', () => {
    it('should update firestore user', async () => {
      expect(service.updateFirestoreUser('uid', {})).resolves.not.toThrow();
    });
    it('should throw an error', async () => {
      (firestore as unknown as jest.Mock).mockImplementationOnce(() => ({
        collection: (path) => {
          throw new Error('Error');
        },
      }));
      expect(service.updateFirestoreUser('uid', {})).rejects.toThrow();
    });
  });
});
